const BloodRequest = require('../models/BloodRequest');
const Requester = require('../models/Requester');

const createBloodRequest = async (req, res) => {
    try {
        const {
            patientName,
            patientPhone,
            bloodGroup,
            hospitalName,
            location,
            contactNumber,
            additionalDetails,
            units,
            notifyViaEmergency,
            requesterId
        } = req.body;

        const existingRequest = await BloodRequest.findOne({
            requester: requesterId,
            status: { $in: ['pending', 'accepted'] }
        });

        if (existingRequest) {
            return res.status(400).json({ message: 'You already have an active blood request. Please cancel or complete it first.' });
        }

        const bloodRequest = new BloodRequest({
            patientName,
            patientPhone,
            bloodGroup,
            hospitalName,
            location,
            contactNumber,
            additionalDetails,
            units: units || 1,
            notifyViaEmergency,
            requester: requesterId,
            status: 'pending'
        });

        await bloodRequest.save();

        res.status(201).json({
            message: 'Blood request created successfully',
            request: bloodRequest
        });

    } catch (error) {
        res.status(500).json({ message: 'Failed to create blood request', error: error.message });
    }
};

const getAllBloodRequests = async (req, res) => {
    try {
        const { userId, userType } = req.user;
        let filter = { status: { $in: ['pending', 'accepted'] } };

        if (userType === 'donor') {
            const Donor = require('../models/Donor');
            const donor = await Donor.findById(userId);

            if (!donor) {
                return res.status(404).json({ message: 'Donor profile not found' });
            }

            // Removed 3-month waiting period check so requests are visible even if ineligible.
            // Logic to prevent donation is handled in acceptBloodRequest and frontend.

            // 2. Blood Compatibility Logic
            const donationCompatibility = {
                'A+': ['A+', 'AB+'],
                'O+': ['O+', 'A+', 'B+', 'AB+'],
                'B+': ['B+', 'AB+'],
                'AB+': ['AB+'],
                'A-': ['A+', 'A-', 'AB+', 'AB-'],
                'O-': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
                'B-': ['B+', 'B-', 'AB+', 'AB-'],
                'AB-': ['AB+', 'AB-']
            };

            const compatibleGroups = donationCompatibility[donor.bloodGroup] || [];
            filter.bloodGroup = { $in: compatibleGroups };
        }

        const requests = await BloodRequest.find(filter)
            .populate('requester', 'fullName')
            .sort({ createdAt: -1 });
        res.json(requests);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching blood requests', error: error.message });
    }
};

const getBloodRequestById = async (req, res) => {
    try {
        const request = await BloodRequest.findById(req.params.id).populate('requester', 'fullName');
        if (!request) {
            return res.status(404).json({ message: 'Blood request not found' });
        }
        res.json(request);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching blood request', error: error.message });
    }
};

const updateBloodRequest = async (req, res) => {
    try {
        const request = await BloodRequest.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );

        if (!request) {
            return res.status(404).json({ message: 'Blood request not found' });
        }

        res.json({ message: 'Blood request updated successfully' });
    } catch (error) {
        res.status(400).json({ message: 'Update failed', error: error.message });
    }
};

const deleteBloodRequest = async (req, res) => {
    try {
        const request = await BloodRequest.findByIdAndDelete(req.params.id);
        if (!request) {
            return res.status(404).json({ message: 'Blood request not found' });
        }
        res.json({ message: 'Blood request deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Delete failed', error: error.message });
    }
};

const cancelBloodRequest = async (req, res) => {
    try {
        const request = await BloodRequest.findByIdAndUpdate(
            req.params.id,
            { status: 'cancelled' },
            { new: true }
        );

        if (!request) {
            return res.status(404).json({ message: 'Blood request not found' });
        }

        res.json({ message: 'Blood request cancelled successfully', request });
    } catch (error) {
        res.status(500).json({ message: 'Cancellation failed', error: error.message });
    }
};

const getMyBloodRequests = async (req, res) => {
    try {
        const requests = await BloodRequest.find({ requester: req.params.requesterId })
            .populate('requester', 'fullName')
            .populate('donor', 'fullName')
            .sort({ createdAt: -1 });
        res.json(requests);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching blood requests', error: error.message });
    }
};

const getDonorHistory = async (req, res) => {
    try {
        // Find requests where this donor was the one fulfilling it
        const history = await BloodRequest.find({ 
            donor: req.params.donorId,
            status: 'fulfilled'
        })
        .sort({ updatedAt: -1 }); // Most recent first
        
        res.json(history);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching donation history', error: error.message });
    }
};

const acceptBloodRequest = async (req, res) => {
    try {
        const { requestId, donorId } = req.body;

        const request = await BloodRequest.findById(requestId);
        if (!request) {
            return res.status(404).json({ message: 'Blood request not found' });
        }

        if (request.status !== 'pending') {
            return res.status(400).json({ message: 'Request is no longer pending' });
        }

        const Donor = require('../models/Donor');
        const donor = await Donor.findById(donorId);
        if (!donor) {
            return res.status(404).json({ message: 'Donor not found' });
        }

        // Strict eligibility check when accepting
        if (donor.lastDonationDate) {
            const lastDonation = new Date(donor.lastDonationDate);
            const threeMonthsAgo = new Date();
            threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3);

            if (lastDonation > threeMonthsAgo) {
                const nextEligibleDate = new Date(lastDonation);
                nextEligibleDate.setMonth(nextEligibleDate.getMonth() + 3);
                return res.status(400).json({
                    message: `You are not eligible to donate yet. Next eligible date: ${nextEligibleDate.toDateString()}`
                });
            }
        }

        request.status = 'accepted';
        request.donor = donorId;
        await request.save();

        res.json({ message: 'Blood request accepted successfully', request });
    } catch (error) {
        res.status(500).json({ message: 'Failed to accept request', error: error.message });
    }
};

const fulfillBloodRequest = async (req, res) => {
    try {
        const { requestId, donorId } = req.body;

        const request = await BloodRequest.findById(requestId);
        if (!request) {
            return res.status(404).json({ message: 'Blood request not found' });
        }

        if (request.status !== 'accepted') {
            return res.status(400).json({ message: 'Request is not in accepted state' });
        }

        if (request.donor.toString() !== donorId) {
            return res.status(403).json({ message: 'You are not the donor for this request' });
        }

        request.status = 'fulfilled';
        await request.save();

        const Donor = require('../models/Donor');
        // Increment donation count and update date
        await Donor.findByIdAndUpdate(donorId, { 
            lastDonationDate: new Date(),
            $inc: { totalDonations: 1 } 
        });

        res.json({ message: 'Blood request fulfilled successfully', request });
    } catch (error) {
        res.status(500).json({ message: 'Failed to fulfill request', error: error.message });
    }
};

module.exports = {
    createBloodRequest,
    getAllBloodRequests,
    getBloodRequestById,
    updateBloodRequest,
    deleteBloodRequest,
    cancelBloodRequest,
    getMyBloodRequests,
    getDonorHistory,
    acceptBloodRequest,
    fulfillBloodRequest
};

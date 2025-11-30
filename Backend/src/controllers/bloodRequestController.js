const BloodRequest = require('../models/BloodRequest');
const Requester = require('../models/Requester');
const Donor = require('../models/Donor');

// Helper function to send notifications
const sendNotification = async (tokens, title, body, data) => {
    console.log("DEBUG: sendNotification called. Token count:", tokens ? tokens.length : 0);
    if (!tokens || tokens.length === 0) return;

    const message = {
        notification: { title, body },
        data: data || {},
        tokens: tokens,
        android: {
            priority: 'high', // Wakes up the device immediately
            notification: {
                channelId: 'high_importance_channel', // Matches the ID in AndroidManifest.xml
                priority: 'high',
                defaultSound: true,
            }
        },
        apns: {
            payload: {
                aps: {
                    sound: 'default',
                    contentAvailable: true, // Important for background updates
                }
            }
        }
    };

    try {
        // Ensure tokens is an array and remove nulls/undefined
        const cleanTokens = tokens.filter(t => t);
        if (cleanTokens.length > 0) {
            // Use the global firebaseAdmin instance
            if (global.firebaseAdmin) {
                console.log("DEBUG: Sending multicast message to Firebase...");
                const response = await global.firebaseAdmin.messaging().sendMulticast({ ...message, tokens: cleanTokens });
                console.log('DEBUG: Notifications sent:', response.successCount, 'failed:', response.failureCount);
                if (response.failureCount > 0) {
                    console.log("DEBUG: Failures:", JSON.stringify(response.responses));
                }
            } else {
                console.error("DEBUG: Firebase Admin not initialized");
            }
        } else {
            console.log("DEBUG: No valid tokens to send to.");
        }
    } catch (error) {
        console.error('DEBUG: Error sending notification:', error);
    }
};

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
        
        console.log("DEBUG: createBloodRequest called. Data:", req.body);

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

        // --- NOTIFICATION LOGIC START ---
        
        // TEST MODE: Notify ALL donors regardless of blood group
        console.log("DEBUG: TEST MODE ACTIVE - Fetching ALL donors with tokens...");
        
        const donors = await Donor.find({
            fcmToken: { $ne: null }, // Only those with tokens
        });
        
        console.log(`DEBUG: Found ${donors.length} potential donors (TEST MODE).`);

        const tokens = donors.map(d => d.fcmToken);
        
        if (tokens.length > 0) {
            await sendNotification(
                tokens,
                'Urgent Blood Request (TEST)',
                `${units} unit(s) of ${bloodGroup} blood needed at ${hospitalName}. Click to view details.`,
                { 
                    type: 'blood_request',
                    requestId: bloodRequest._id.toString() 
                }
            );
        }
        // --- NOTIFICATION LOGIC END ---

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

        // --- NOTIFICATION LOGIC START ---
        // Notify the Requester that a donor has accepted
        try {
            const requester = await Requester.findById(request.requester);
            if (requester && requester.fcmToken) {
                await sendNotification(
                    [requester.fcmToken],
                    'Donor Found!',
                    `${donor.fullName} has accepted your request for ${request.bloodGroup} blood. They will contact you soon.`,
                    {
                        type: 'request_accepted',
                        requestId: request._id.toString(),
                        donorId: donor._id.toString()
                    }
                );
            }
        } catch (notifError) {
            console.error("Failed to notify requester:", notifError);
        }
        // --- NOTIFICATION LOGIC END ---

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

        // Increment donation count and update date
        await Donor.findByIdAndUpdate(donorId, { 
            lastDonationDate: new Date(),
            $inc: { totalDonations: 1 } 
        });

        // --- NOTIFICATION LOGIC START ---
        // Notify Donor "Thank You"
        try {
             const donor = await Donor.findById(donorId);
             if (donor && donor.fcmToken) {
                 await sendNotification(
                     [donor.fcmToken],
                     'Donation Completed',
                     'Thank you for saving a life! Your donation has been recorded.',
                     {
                         type: 'request_fulfilled',
                         requestId: request._id.toString()
                     }
                 );
             }
        } catch (e) { console.log(e); }
        // --- NOTIFICATION LOGIC END ---

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

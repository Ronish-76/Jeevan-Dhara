const Hospital = require('../models/Hospital');
const BloodStock = require('../models/BloodStock');
const HospitalBloodRequest = require('../models/HospitalBloodRequest');
const HospitalDonation = require('../models/HospitalDonation');

const registerHospital = async (req, res) => {
  try {
    const existingHospital = await Hospital.findOne({ 
      $or: [{ email: req.body.email }, { hospitalRegistrationId: req.body.hospitalRegistrationId }]
    });
    
    if (existingHospital) {
      return res.status(400).json({ message: 'Hospital already exists with this email or registration ID' });
    }

    const hospital = new Hospital(req.body);
    await hospital.save();
    res.status(201).json({ message: 'Hospital registered successfully, verification pending' });
  } catch (error) {
    res.status(400).json({ message: 'Registration failed', error: error.message });
  }
};

const getAllHospitals = async (req, res) => {
  try {
    const { search } = req.query;
    const query = {};
    
    if (search) {
      query.$or = [
        { hospitalName: new RegExp(search, 'i') },
        { email: new RegExp(search, 'i') },
        { phoneNumber: new RegExp(search, 'i') }
      ];
    }

    const hospitals = await Hospital.find(query);
    res.json(hospitals);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

const requestBlood = async (req, res) => {
  try {
    const request = new HospitalBloodRequest({ ...req.body, hospital: req.params.hospitalId });
    await request.save();
    res.status(201).json({ message: 'Blood request created successfully', request });
  } catch (error) {
    res.status(400).json({ message: 'Request failed', error: error.message });
  }
};

const getBloodRequests = async (req, res) => {
  try {
    const requests = await HospitalBloodRequest.find({ hospital: req.params.hospitalId }).populate('hospital');
    res.json(requests);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

const updateBloodRequest = async (req, res) => {
  try {
    const request = await HospitalBloodRequest.findByIdAndUpdate(
      req.params.requestId,
      req.body,
      { new: true }
    );
    if (!request) return res.status(404).json({ message: 'Request not found' });
    res.json({ message: 'Request updated successfully', request });
  } catch (error) {
    res.status(400).json({ message: 'Update failed', error: error.message });
  }
};

const updateDeliveryStatus = async (req, res) => {
  try {
    const request = await HospitalBloodRequest.findByIdAndUpdate(
      req.params.requestId,
      { deliveryStatus: req.body.deliveryStatus },
      { new: true }
    );
    res.json({ message: 'Delivery status updated', request });
  } catch (error) {
    res.status(400).json({ message: 'Update failed', error: error.message });
  }
};

const getBloodStock = async (req, res) => {
  try {
    const stock = await BloodStock.find({ hospital: req.params.hospitalId });
    res.json(stock);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

const addBloodStock = async (req, res) => {
  try {
    // Create stock entry
    const stock = new BloodStock({ ...req.body, hospital: req.params.hospitalId });
    await stock.save();

    // Also create a HospitalDonation record if donor information is present
    if (req.body.donorName || req.body.donorId) {
       try {
         const donation = new HospitalDonation({
           hospital: req.params.hospitalId,
           donorName: req.body.donorName || 'Unknown',
           donorId: req.body.donorId,
           bloodGroup: req.body.bloodGroup,
           units: req.body.units,
           donationDate: req.body.collectionDate || new Date(),
           expiryDate: req.body.expiryDate,
           contactNumber: req.body.contactNumber,
           address: req.body.address
         });
         await donation.save();
       } catch (donError) {
         console.error("Failed to save donation record:", donError);
         // Don't fail the stock addition if donation record fails, but maybe log it
       }
    }

    res.status(201).json({ message: 'Blood stock added successfully', stock });
  } catch (error) {
    res.status(400).json({ message: 'Failed to add stock', error: error.message });
  }
};

const updateBloodStock = async (req, res) => {
  try {
    const stock = await BloodStock.findByIdAndUpdate(req.params.stockId, req.body, { new: true });
    res.json({ message: 'Blood stock updated successfully', stock });
  } catch (error) {
    res.status(400).json({ message: 'Update failed', error: error.message });
  }
};

const removeBloodStock = async (req, res) => {
  try {
    await BloodStock.findByIdAndDelete(req.params.stockId);
    res.json({ message: 'Blood stock removed successfully' });
  } catch (error) {
    res.status(400).json({ message: 'Removal failed', error: error.message });
  }
};

const getHospitalDonations = async (req, res) => {
  try {
    const donations = await HospitalDonation.find({ hospital: req.params.hospitalId }).sort({ donationDate: -1 });
    res.json(donations);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

module.exports = { 
  registerHospital, 
  getAllHospitals, 
  requestBlood, 
  getBloodRequests, 
  updateBloodRequest,
  updateDeliveryStatus, 
  getBloodStock, 
  addBloodStock, 
  updateBloodStock, 
  removeBloodStock,
  getHospitalDonations
};

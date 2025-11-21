const BloodBank = require('../models/BloodBank');

const registerBloodBank = async (req, res) => {
  try {
    const existingBloodBank = await BloodBank.findOne({ 
      $or: [{ email: req.body.email }, { registrationNumber: req.body.registrationNumber }]
    });
    
    if (existingBloodBank) {
      return res.status(400).json({ message: 'Blood bank already exists with this email or registration number' });
    }

    const bloodBank = new BloodBank(req.body);
    await bloodBank.save();
    res.status(201).json({ message: 'Blood bank registered successfully' });
  } catch (error) {
    res.status(400).json({ message: 'Registration failed', error: error.message });
  }
};

const getAllBloodBanks = async (req, res) => {
  try {
    const bloodBanks = await BloodBank.find();
    res.json(bloodBanks);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

module.exports = { registerBloodBank, getAllBloodBanks };
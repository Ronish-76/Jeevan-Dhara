const Donor = require('../models/Donor');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const registerDonor = async (req, res) => {
  try {
    const { password, ...donorData } = req.body;
    
    const existingDonor = await Donor.findOne({ email: donorData.email });
    if (existingDonor) {
      return res.status(400).json({ message: 'Donor already exists with this email' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    
    const donor = new Donor({
      ...donorData,
      password: hashedPassword
    });

    await donor.save();
    res.status(201).json({ message: 'Donor registered successfully' });
  } catch (error) {
    res.status(400).json({ message: 'Registration failed', error: error.message });
  }
};

const loginDonor = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    const donor = await Donor.findOne({ email });
    if (!donor) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, donor.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { userId: donor._id, userType: 'donor' },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({ token });
  } catch (error) {
    res.status(500).json({ message: 'Login failed', error: error.message });
  }
};

const getAllDonors = async (req, res) => {
  try {
    const donors = await Donor.find().select('-password');
    res.json(donors);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

const getDonorById = async (req, res) => {
  try {
    const donor = await Donor.findById(req.params.id).select('-password');
    if (!donor) {
      return res.status(404).json({ message: 'Donor not found' });
    }
    res.json(donor);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

const updateDonor = async (req, res) => {
  try {
    const donor = await Donor.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).select('-password');
    
    if (!donor) {
      return res.status(404).json({ message: 'Donor not found' });
    }
    
    res.json({ message: 'Donor updated successfully' });
  } catch (error) {
    res.status(400).json({ message: 'Update failed', error: error.message });
  }
};

const deleteDonor = async (req, res) => {
  try {
    const donor = await Donor.findByIdAndDelete(req.params.id);
    if (!donor) {
      return res.status(404).json({ message: 'Donor not found' });
    }
    res.json({ message: 'Donor deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Delete failed', error: error.message });
  }
};

const searchDonors = async (req, res) => {
  try {
    const { bloodGroup, location } = req.query;
    const query = {};
    
    if (bloodGroup) query.bloodGroup = bloodGroup;
    if (location) query.location = new RegExp(location, 'i');
    
    const donors = await Donor.find(query).select('-password');
    res.json(donors);
  } catch (error) {
    res.status(500).json({ message: 'Search failed', error: error.message });
  }
};

module.exports = { 
  registerDonor, 
  loginDonor, 
  getAllDonors, 
  getDonorById, 
  updateDonor, 
  deleteDonor, 
  searchDonors 
};
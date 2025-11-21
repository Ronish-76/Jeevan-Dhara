const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Requester = require('../models/Requester');
const Donor = require('../models/Donor');

const register = async (req, res) => {
  try {
    const { userType, password, ...userData } = req.body;

    // Check if email exists in either collection
    const existingRequester = await Requester.findOne({ email: userData.email });
    const existingDonor = await Donor.findOne({ email: userData.email });

    if (existingRequester || existingDonor) {
      return res.status(400).json({ message: 'Email already registered' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    if (userType === 'donor') {
      const donor = new Donor({ ...userData, password: hashedPassword });
      await donor.save();
      res.status(201).json({ message: 'Donor registered successfully' });
    } else {
      const requester = new Requester({ ...userData, password: hashedPassword });
      await requester.save();
      res.status(201).json({ message: 'Requester registered successfully' });
    }
  } catch (error) {
    res.status(400).json({ message: 'Registration failed', error: error.message });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Check in requesters first
    const requester = await Requester.findOne({ email });
    if (requester) {
      const isMatch = await bcrypt.compare(password, requester.password);
      if (isMatch) {
        const token = jwt.sign(
          { userId: requester._id, userType: 'requester' },
          process.env.JWT_SECRET,
          { expiresIn: '24h' }
        );
        return res.status(200).json({
          message: 'Login successful',
          token,
          userType: 'requester',
          user: {
            _id: requester._id,
            fullName: requester.fullName,
            email: requester.email,
            phone: requester.phone,
            location: requester.location,
            age: requester.age,
            gender: requester.gender,
            hospitalName: requester.hospitalName,
            hospitalLocation: requester.hospitalLocation,
            hospitalPhone: requester.hospitalPhone,
            bloodGroup: requester.bloodGroup,
            isEmergency: false,
            userType: 'requester'
          }
        });
      }
    }

    // Check in donors
    const donor = await Donor.findOne({ email });
    if (donor) {
      const isMatch = await bcrypt.compare(password, donor.password);
      if (isMatch) {
        const token = jwt.sign(
          { userId: donor._id, userType: 'donor' },
          process.env.JWT_SECRET,
          { expiresIn: '24h' }
        );
        return res.status(200).json({
          message: 'Login successful',
          token,
          userType: 'donor',
          user: {
            _id: donor._id,
            fullName: donor.fullName,
            email: donor.email,
            phone: donor.phone,
            location: donor.location,
            age: donor.age,
            gender: donor.gender,
            hospital: donor.hospital,
            bloodGroup: donor.bloodGroup,
            lastDonationDate: donor.lastDonationDate,
            isEmergency: false,
            userType: 'donor'
          }
        });
      }
    }

    res.status(401).json({ message: 'Invalid credentials' });
  } catch (error) {
    res.status(500).json({ message: 'Login failed', error: error.message });
  }
};

const getProfile = async (req, res) => {
  try {
    const { userId, userType } = req.params;

    if (userType === 'requester') {
      const requester = await Requester.findById(userId, '-password');
      if (!requester) {
        return res.status(404).json({ message: 'User not found' });
      }
      return res.status(200).json({
        _id: requester._id,
        fullName: requester.fullName,
        email: requester.email,
        phone: requester.phone,
        location: requester.location,
        age: requester.age,
        gender: requester.gender,
        hospital: null,
        bloodGroup: requester.bloodGroup,
        isEmergency: false,
        userType: 'requester'
      });
    } else {
      const donor = await Donor.findById(userId, '-password');
      if (!donor) {
        return res.status(404).json({ message: 'User not found' });
      }
      return res.status(200).json({
        _id: donor._id,
        fullName: donor.fullName,
        email: donor.email,
        phone: donor.phone,
        location: donor.location,
        age: donor.age,
        gender: donor.gender,
        hospital: donor.hospital,
        bloodGroup: donor.bloodGroup,
        lastDonationDate: donor.lastDonationDate,
        isEmergency: false,
        userType: 'donor'
      });
    }
  } catch (error) {
    res.status(500).json({ message: 'Failed to get profile', error: error.message });
  }
};

module.exports = { register, login, getProfile };
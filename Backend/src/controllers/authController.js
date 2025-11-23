const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Requester = require('../models/Requester');
const Donor = require('../models/Donor');
const Hospital = require('../models/Hospital');
const BloodBank = require('../models/BloodBank');

const register = async (req, res) => {
  try {
    const { userType, password, ...userData } = req.body;

    // Check if email exists in either collection
    const existingRequester = await Requester.findOne({ email: userData.email });
    const existingDonor = await Donor.findOne({ email: userData.email });
    const existingHospital = await Hospital.findOne({ email: userData.email });
    const existingBloodBank = await BloodBank.findOne({ email: userData.email });

    if (existingRequester || existingDonor || existingHospital || existingBloodBank) {
      return res.status(400).json({ message: 'Email already registered' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    if (userType === 'donor') {
      const donor = new Donor({ ...userData, password: hashedPassword });
      await donor.save();
      res.status(201).json({ message: 'Donor registered successfully' });
    } else if (userType === 'requester') {
      const requester = new Requester({ ...userData, password: hashedPassword });
      await requester.save();
      res.status(201).json({ message: 'Requester registered successfully' });
    } else {
       res.status(400).json({ message: 'Invalid user type for generic registration' });
    }
  } catch (error) {
    res.status(400).json({ message: 'Registration failed', error: error.message });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Check in requesters
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
            userType: 'donor'
          }
        });
      }
    }

    // Check in hospitals
    const hospital = await Hospital.findOne({ email });
    if (hospital) {
      // Checking plain text password as per current hospital registration implementation
      const isMatch = hospital.password === password; 
      
      if (isMatch) {
         const token = jwt.sign(
          { userId: hospital._id, userType: 'hospital' },
          process.env.JWT_SECRET,
          { expiresIn: '24h' }
        );
        return res.status(200).json({
          message: 'Login successful',
          token,
          userType: 'hospital',
          user: {
            _id: hospital._id,
            fullName: hospital.hospitalName,
            email: hospital.email,
            phone: hospital.phoneNumber,
            location: `${hospital.address}, ${hospital.city}`,
            hospitalName: hospital.hospitalName,
            hospitalLocation: `${hospital.address}, ${hospital.city}`,
            hospitalPhone: hospital.phoneNumber,
            hospitalRegistrationId: hospital.hospitalRegistrationId,
            contactPerson: hospital.contactPerson,
            hospitalType: hospital.hospitalType,
            bloodBankFacility: hospital.bloodBankFacility,
            emergencyService24x7: hospital.emergencyService24x7,
            isVerified: hospital.isVerified,
            userType: 'hospital'
          }
        });
      }
    }

    // Check in blood banks
    const bloodBank = await BloodBank.findOne({ email });
    if (bloodBank) {
       // Checking plain text password
       const isMatch = bloodBank.password === password;
       
       if (isMatch) {
        const token = jwt.sign(
          { userId: bloodBank._id, userType: 'blood_bank' },
          process.env.JWT_SECRET,
          { expiresIn: '24h' }
        );
        return res.status(200).json({
          message: 'Login successful',
          token,
          userType: 'blood_bank',
          user: {
            _id: bloodBank._id,
            fullName: bloodBank.bloodBankName,
            email: bloodBank.email,
            phone: bloodBank.phoneNumber,
            location: bloodBank.fullAddress,
            registrationId: bloodBank.licenseNumber,
            contactPerson: bloodBank.contactPerson,
            isVerified: bloodBank.isVerified,
            userType: 'blood_bank'
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
      if (!requester) return res.status(404).json({ message: 'User not found' });
      return res.status(200).json({ ...requester.toObject(), userType: 'requester' });
    } else if (userType === 'donor') {
      const donor = await Donor.findById(userId, '-password');
      if (!donor) return res.status(404).json({ message: 'User not found' });
      return res.status(200).json({ ...donor.toObject(), userType: 'donor' });
    } else if (userType === 'hospital') {
        const hospital = await Hospital.findById(userId, '-password');
        if (!hospital) return res.status(404).json({ message: 'User not found' });
        return res.status(200).json({ ...hospital.toObject(), userType: 'hospital' });
    } else if (userType === 'blood_bank') {
        const bloodBank = await BloodBank.findById(userId, '-password');
        if (!bloodBank) return res.status(404).json({ message: 'User not found' });
        return res.status(200).json({ ...bloodBank.toObject(), userType: 'blood_bank' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Failed to get profile', error: error.message });
  }
};

module.exports = { register, login, getProfile };
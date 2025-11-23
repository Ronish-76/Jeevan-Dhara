const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Requester = require('../models/Requester');

const getAllRequesters = async (req, res) => {
  try {
    const requesters = await Requester.find({}, '-password');
    res.json(requesters);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching requesters', error: error.message });
  }
};

const registerRequester = async (req, res) => {
  try {
    const { fullName, email, phone, hospitalName, location, age, gender, bloodGroup, password } = req.body;

    const existingRequester = await Requester.findOne({ email });
    if (existingRequester) {
      return res.status(400).json({ message: 'Requester already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const requester = new Requester({
      fullName,
      email,
      phone,
      hospitalName,
      location,
      age,
      gender,
      bloodGroup,
      password: hashedPassword
    });

    await requester.save();

    const token = jwt.sign(
      { userId: requester._id, userType: 'requester' },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.status(201).json({
      message: 'Requester registered successfully',
      token,
      user: {
        ...requester.toObject(),
        userType: 'requester'
      }
    });

  } catch (error) {
    res.status(500).json({ message: 'Registration failed', error: error.message });
  }
};

const updateRequesterProfile = async (req, res) => {
  try {
    const { hospitalName, hospitalLocation, hospitalPhone } = req.body;
    const requesterId = req.params.id;

    const requester = await Requester.findByIdAndUpdate(
      requesterId,
      { hospitalName, hospitalLocation, hospitalPhone },
      { new: true, runValidators: true }
    ).select('-password');

    if (!requester) {
      return res.status(404).json({ message: 'Requester not found' });
    }

    res.json({
      message: 'Profile updated successfully',
      user: {
        ...requester.toObject(),
        userType: 'requester'
      }
    });
  } catch (error) {
    res.status(500).json({ message: 'Update failed', error: error.message });
  }
};

const loginRequester = async (req, res) => {
  try {
    const { email, password } = req.body;

    const requester = await Requester.findOne({ email });
    if (!requester) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, requester.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { userId: requester._id, userType: 'requester' },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({
      token,
      user: {
        ...requester.toObject(),
        userType: 'requester'
      }
    });

  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getAllRequesters,
  registerRequester,
  loginRequester,
  updateRequesterProfile
};
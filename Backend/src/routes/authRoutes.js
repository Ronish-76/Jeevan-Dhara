const express = require('express');
const { register, login, getProfile, updateFCMToken } = require('../controllers/authController');

const router = express.Router();

router.post('/register', register);
router.post('/login', login);
router.get('/profile/:userType/:userId', getProfile);
router.post('/fcm-token', updateFCMToken);

module.exports = router;
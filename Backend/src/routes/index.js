const express = require('express');
const authRoutes = require('./authRoutes');
const requesterRoutes = require('./requesterRoutes');
const donorRoutes = require('./donorRoutes');
const hospitalRoutes = require('./hospitalRoutes');
const bloodBankRoutes = require('./bloodBankRoutes');
const bloodRequestRoutes = require('./bloodRequestRoutes');

const router = express.Router();

router.use('/auth', authRoutes);
router.use('/requesters', requesterRoutes);
router.use('/donors', donorRoutes);
router.use('/hospitals', hospitalRoutes);
router.use('/blood-banks', bloodBankRoutes);
router.use('/blood-requests', bloodRequestRoutes);

module.exports = router;

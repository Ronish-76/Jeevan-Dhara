
const express = require('express');
const router = express.Router();
const mapController = require('../controllers/map.controller');

// @route   GET /api/map/nearby
// @desc    Get nearby locations based on user's role and position
// @access  Public
router.get('/nearby', mapController.getNearbyLocations);

module.exports = router;

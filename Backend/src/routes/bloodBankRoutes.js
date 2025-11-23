const express = require('express');
const { registerBloodBank, getAllBloodBanks, getBloodBankProfile, seedData, recordDonation, getDonations, recordDistribution, getDistributions, getBloodBankRequests } = require('../controllers/bloodBankController');

const router = express.Router();

router.post('/register', registerBloodBank);
router.get('/', getAllBloodBanks);
router.get('/seed', seedData);
router.get('/:id', getBloodBankProfile);
router.post('/:id/donations', recordDonation);
router.get('/:id/donations', getDonations);
router.post('/:id/distributions', recordDistribution);
router.get('/:id/distributions', getDistributions);
router.get('/:id/requests', getBloodBankRequests); // Added new route

module.exports = router;
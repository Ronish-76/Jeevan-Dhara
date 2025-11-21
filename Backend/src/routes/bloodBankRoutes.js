const express = require('express');
const { registerBloodBank, getAllBloodBanks } = require('../controllers/bloodBankController');

const router = express.Router();

router.post('/register', registerBloodBank);
router.get('/', getAllBloodBanks);

module.exports = router;
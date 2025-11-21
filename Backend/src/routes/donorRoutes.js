const express = require('express');
const { 
  registerDonor, 
  loginDonor, 
  getAllDonors, 
  getDonorById, 
  updateDonor, 
  deleteDonor, 
  searchDonors 
} = require('../controllers/donorController');

const router = express.Router();

router.post('/register', registerDonor);
router.post('/login', loginDonor);
router.get('/', getAllDonors);
router.get('/search', searchDonors);
router.get('/:id', getDonorById);
router.put('/:id', updateDonor);
router.delete('/:id', deleteDonor);

module.exports = router;
const express = require('express');
const { 
  registerHospital, 
  getAllHospitals, 
  requestBlood, 
  getBloodRequests, 
  updateBloodRequest,
  updateDeliveryStatus, 
  getBloodStock, 
  addBloodStock, 
  updateBloodStock, 
  removeBloodStock,
  getHospitalDonations
} = require('../controllers/hospitalController');

const router = express.Router();

router.post('/register', registerHospital);
router.get('/', getAllHospitals);
router.post('/:hospitalId/blood-requests', requestBlood);
router.get('/:hospitalId/blood-requests', getBloodRequests);
router.put('/blood-requests/:requestId', updateBloodRequest);
router.put('/blood-requests/:requestId/delivery-status', updateDeliveryStatus);
router.get('/:hospitalId/blood-stock', getBloodStock);
router.post('/:hospitalId/blood-stock', addBloodStock);
router.put('/blood-stock/:stockId', updateBloodStock);
router.delete('/blood-stock/:stockId', removeBloodStock);
router.get('/:hospitalId/donations', getHospitalDonations);

module.exports = router;
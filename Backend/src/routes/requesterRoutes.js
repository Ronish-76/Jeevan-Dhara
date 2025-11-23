const express = require('express');
const {
  getAllRequesters,
  registerRequester,
  loginRequester,
  createBloodRequest,
  getAllBloodRequests,
  getBloodRequestById,
  updateBloodRequest,
  deleteBloodRequest,
  updateRequesterProfile,
} = require('../controllers/requesterController');
const { getMyBloodRequests } = require('../controllers/bloodRequestController');

const router = express.Router();

router.get('/', getAllRequesters);
router.post('/register', registerRequester);
router.post('/login', loginRequester);
router.put('/:id', updateRequesterProfile);
router.get('/:id/blood-requests', getMyBloodRequests);

module.exports = router;
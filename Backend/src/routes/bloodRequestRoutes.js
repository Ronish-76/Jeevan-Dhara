const express = require('express');
const {
  createBloodRequest,
  getAllBloodRequests,
  getBloodRequestById,
  updateBloodRequest,
  deleteBloodRequest,
  cancelBloodRequest,
  getMyBloodRequests,
  acceptBloodRequest,
  fulfillBloodRequest
} = require('../controllers/bloodRequestController');

const verifyToken = require('../middleware/auth');

const router = express.Router();

router.post('/', verifyToken, createBloodRequest);
router.get('/', verifyToken, getAllBloodRequests);
router.get('/requester/:requesterId', verifyToken, getMyBloodRequests);
router.get('/:id', verifyToken, getBloodRequestById);
router.put('/:id', verifyToken, updateBloodRequest);
router.put('/:id/cancel', verifyToken, cancelBloodRequest);
router.post('/accept', verifyToken, acceptBloodRequest);
router.post('/fulfill', verifyToken, fulfillBloodRequest);
router.delete('/:id', verifyToken, deleteBloodRequest);

module.exports = router;
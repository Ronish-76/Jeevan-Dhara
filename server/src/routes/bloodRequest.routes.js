import { Router } from 'express';
import { createRequestFromMap, getBloodRequests, getUrgentRequests } from '../controllers/bloodRequest.controller.js';

const router = Router();

router.post('/create-from-map', createRequestFromMap);
router.get('/', getBloodRequests);
router.get('/urgent', getUrgentRequests);

export default router;


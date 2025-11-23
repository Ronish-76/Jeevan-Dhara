import { Router } from 'express';
import { createRequest, getActiveRequests, respondToRequest } from '../controllers/request.controller.js';

const router = Router();

router.get('/active', getActiveRequests);
router.post('/create', createRequest);
router.post('/respond', respondToRequest);

export default router;

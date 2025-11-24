import { Router } from 'express';
import { acceptRequest } from '../controllers/donor.controller.js';

const router = Router();

router.post('/accept-request', acceptRequest);

export default router;


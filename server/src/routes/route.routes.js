import { Router } from 'express';
import { getSupplyRoutes } from '../controllers/route.controller.js';

const router = Router();

router.get('/supply', getSupplyRoutes);

export default router;


import { Router } from 'express';
import { getNearbyFacilities } from '../controllers/map.controller.js';

const router = Router();

router.get('/nearby', getNearbyFacilities);

export default router;

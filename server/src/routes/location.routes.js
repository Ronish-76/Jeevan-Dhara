import { Router } from 'express';
import { seedLocations, getNearbyLocations, getBloodBankInventory } from '../controllers/location.controller.js';
import { validateSeedingKey } from '../middlewares/auth.js';

const router = Router();

router.post('/seed', validateSeedingKey, seedLocations);
router.get('/nearby', getNearbyLocations);
router.get('/bloodbanks/:id/inventory', getBloodBankInventory);

export default router;


import express from 'express';
import {
    registerUser,
    getUserByUid,
    getUserById,
    updateUser,
    getDonors,
} from '../controllers/user.controller.js';

const router = express.Router();

/**
 * User Routes
 * All routes for user profile management
 */

// Register or update user profile
router.post('/register', registerUser);

// Get user by Firebase UID (used by Flutter app)
router.get('/:uid', getUserByUid);

// Get user by MongoDB ID
router.get('/profile/:id', getUserById);

// Update user profile
router.patch('/:uid', updateUser);

// Get all donors (for matching)
router.get('/donors/list', getDonors);

export default router;

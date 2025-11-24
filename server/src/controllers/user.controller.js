import createError from 'http-errors';
import User from '../models/user.model.js';

/**
 * User Controller
 * Handles user profile management for the Jeevan Dhara application.
 * Works with Firebase Auth - Firebase handles authentication, we handle user data.
 */

/**
 * Register a new user or create/update user profile
 * POST /api/users/register
 * Body: { uid, email, name, role, phone, bloodType?, address?, facilityId?, facilityName?, ... }
 */
export const registerUser = async (req, res, next) => {
    try {
        const { uid, email, name, role, phone, ...additionalData } = req.body;

        // Validate required fields
        if (!uid || !email || !name || !role) {
            throw createError(400, 'Missing required fields: uid, email, name, role');
        }

        // Validate role
        const validRoles = ['patient', 'requester', 'donor', 'hospital', 'blood_bank'];
        if (!validRoles.includes(role)) {
            throw createError(400, `Invalid role. Must be one of: ${validRoles.join(', ')}`);
        }

        // Check if user already exists
        let user = await User.findOne({ email });

        if (user) {
            // Update existing user
            user.name = name;
            user.role = role;
            if (phone) user.phone = phone;

            // Update role-specific fields
            if (role === 'donor' && additionalData.bloodType) {
                user.bloodType = additionalData.bloodType.toUpperCase();
            }

            if ((role === 'hospital' || role === 'blood_bank') && additionalData.facilityId) {
                user.facilityId = additionalData.facilityId;
            }

            if (additionalData.address) {
                user.address = additionalData.address;
            }

            if (additionalData.geo) {
                user.geo = additionalData.geo;
            }

            await user.save();

            return res.status(200).json({
                success: true,
                message: 'User profile updated successfully',
                user: sanitizeUser(user),
            });
        }

        // Create new user
        const userData = {
            email,
            name,
            phone: phone || email, // Use email as fallback for phone
            password: uid, // Store Firebase UID as password (not used for auth)
            role,
        };

        // Add role-specific fields
        if (role === 'donor' && additionalData.bloodType) {
            userData.bloodType = additionalData.bloodType.toUpperCase();
            userData.isAvailable = additionalData.isAvailable !== false;
        }

        if ((role === 'hospital' || role === 'blood_bank') && additionalData.facilityId) {
            userData.facilityId = additionalData.facilityId;
        }

        if (additionalData.address) {
            userData.address = additionalData.address;
        }

        if (additionalData.geo) {
            userData.geo = additionalData.geo;
        }

        user = await User.create(userData);

        res.status(201).json({
            success: true,
            message: 'User registered successfully',
            user: sanitizeUser(user),
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get user profile by Firebase UID
 * GET /api/users/:uid
 */
export const getUserByUid = async (req, res, next) => {
    try {
        const { uid } = req.params;

        if (!uid) {
            throw createError(400, 'User ID is required');
        }

        // Find user by email (we use Firebase UID as email lookup)
        // In a real implementation, you'd store the Firebase UID in a separate field
        const user = await User.findOne({ password: uid });

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found',
                user: null,
            });
        }

        res.status(200).json({
            success: true,
            user: sanitizeUser(user),
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get user profile by ID
 * GET /api/users/profile/:id
 */
export const getUserById = async (req, res, next) => {
    try {
        const { id } = req.params;

        const user = await User.findById(id);

        if (!user) {
            throw createError(404, 'User not found');
        }

        res.status(200).json({
            success: true,
            user: sanitizeUser(user),
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Update user profile
 * PATCH /api/users/:uid
 */
export const updateUser = async (req, res, next) => {
    try {
        const { uid } = req.params;
        const updates = req.body;

        // Don't allow updating certain fields
        delete updates.email;
        delete updates.password;
        delete updates.role;

        const user = await User.findOne({ password: uid });

        if (!user) {
            throw createError(404, 'User not found');
        }

        // Update allowed fields
        if (updates.name) user.name = updates.name;
        if (updates.phone) user.phone = updates.phone;
        if (updates.bloodType && user.role === 'donor') {
            user.bloodType = updates.bloodType.toUpperCase();
        }
        if (updates.isAvailable !== undefined && user.role === 'donor') {
            user.isAvailable = updates.isAvailable;
        }
        if (updates.address) {
            user.address = updates.address;
        }
        if (updates.geo) {
            user.geo = updates.geo;
        }
        if (updates.metadata) {
            user.metadata = { ...user.metadata, ...updates.metadata };
        }

        await user.save();

        res.status(200).json({
            success: true,
            message: 'User updated successfully',
            user: sanitizeUser(user),
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get all donors (for matching)
 * GET /api/users/donors
 */
export const getDonors = async (req, res, next) => {
    try {
        const { bloodType, isAvailable, limit = 50 } = req.query;

        const query = { role: 'donor' };

        if (bloodType) {
            query.bloodType = bloodType.toUpperCase();
        }

        if (isAvailable !== undefined) {
            query.isAvailable = isAvailable === 'true';
        }

        const donors = await User.find(query)
            .limit(parseInt(limit))
            .select('-password')
            .lean();

        res.status(200).json({
            success: true,
            count: donors.length,
            donors,
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Helper function to remove sensitive data from user object
 */
function sanitizeUser(user) {
    const userObj = user.toObject ? user.toObject() : user;
    delete userObj.password;
    return userObj;
}

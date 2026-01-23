import express from 'express';

import { requireAuth } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { createUserLimiter } from '../middleware/rateLimiter.js';
import { createUser, getUsers, getUser, patchUser, removeUser } from '../controllers/userController.js';
import { validate } from '../middleware/validate.js';
import { createUserSchema } from '../validators/userSchemas.js';

const router = express.Router();

// List all users (admin only)
router.get('/', requireAuth, requireRole(['admin']), getUsers);

// Get a single user by ID (admin only)
router.get('/:id', requireAuth, requireRole(['admin']), getUser);

// Admin can create staff users (doctor/nurse/admin) and assign hospital.
router.post('/', requireAuth, requireRole(['admin']), createUserLimiter, validate(createUserSchema), createUser);

// Update a user (admin only)
router.patch('/:id', requireAuth, requireRole(['admin']), patchUser);

// Delete a user (admin only)
router.delete('/:id', requireAuth, requireRole(['admin']), removeUser);

export default router;

import express from 'express';

import { requireAuth } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { createUserLimiter } from '../middleware/rateLimiter.js';
import { createUser } from '../controllers/userController.js';
import { validate } from '../middleware/validate.js';
import { createUserSchema } from '../validators/userSchemas.js';

const router = express.Router();

// Admin can create staff users (doctor/nurse/admin) and assign hospital.
router.post('/', requireAuth, requireRole(['admin']), createUserLimiter, validate(createUserSchema), createUser);

export default router;

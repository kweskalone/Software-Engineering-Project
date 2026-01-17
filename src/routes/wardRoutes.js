import express from 'express';
import { requireAuth } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { createWard, getWardAvailability, updateWardCapacity } from '../controllers/wardController.js';
import { validate } from '../middleware/validate.js';
import { createWardSchema, updateWardCapacitySchema } from '../validators/wardSchemas.js';

const router = express.Router();

router.get('/:id/availability', requireAuth, getWardAvailability);

// Admin management
router.post('/', requireAuth, requireRole(['admin']), validate(createWardSchema), createWard);
router.patch('/:id/capacity', requireAuth, requireRole(['admin']), validate(updateWardCapacitySchema), updateWardCapacity);

export default router;

import express from 'express';
import { requireAuth } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { createHospital, listHospitals, updateHospital } from '../controllers/hospitalController.js';
import { validate } from '../middleware/validate.js';
import { createHospitalSchema, updateHospitalSchema } from '../validators/hospitalSchemas.js';

const router = express.Router();

router.get('/', requireAuth, listHospitals);

// Admin management
router.post('/', requireAuth, requireRole(['admin']), validate(createHospitalSchema), createHospital);
router.patch('/:id', requireAuth, requireRole(['admin']), validate(updateHospitalSchema), updateHospital);

export default router;

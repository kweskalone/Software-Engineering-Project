import express from 'express';
import { requireAuth } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { dischargePatient } from '../controllers/dischargeController.js';
import { validate } from '../middleware/validate.js';
import { dischargeSchema } from '../validators/dischargeSchemas.js';

const router = express.Router();

router.post('/', requireAuth, requireRole(['admin', 'doctor', 'nurse']), validate(dischargeSchema), dischargePatient);

export default router;

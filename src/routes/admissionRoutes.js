import express from 'express';
import { requireAuth } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { createAdmission, listAdmissions, getAdmission } from '../controllers/admissionController.js';
import { validate } from '../middleware/validate.js';
import { createAdmissionSchema } from '../validators/admissionSchemas.js';

const router = express.Router();

// List admissions (paginated, filtered by hospital)
router.get('/', requireAuth, requireRole(['admin', 'doctor', 'nurse']), listAdmissions);

// Get single admission
router.get('/:id', requireAuth, requireRole(['admin', 'doctor', 'nurse']), getAdmission);

// Create admission
router.post('/', requireAuth, requireRole(['admin', 'doctor', 'nurse']), validate(createAdmissionSchema), createAdmission);

export default router;

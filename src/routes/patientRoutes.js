import express from 'express';
import { requireAuth } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { listPatients, getPatient } from '../controllers/patientController.js';

const router = express.Router();

// List patients (paginated, searchable)
router.get('/', requireAuth, requireRole(['admin', 'doctor', 'nurse']), listPatients);

// Get single patient with admission history
router.get('/:id', requireAuth, requireRole(['admin', 'doctor', 'nurse']), getPatient);

export default router;

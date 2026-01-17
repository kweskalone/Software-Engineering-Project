import express from 'express';
import { requireAuth } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { searchBeds } from '../controllers/bedController.js';

const router = express.Router();

// Search for available beds across all hospitals
// GET /beds/search?region=Greater Accra&ward_type=icu&min_beds=1
router.get('/search', requireAuth, requireRole(['admin', 'doctor', 'nurse']), searchBeds);

export default router;

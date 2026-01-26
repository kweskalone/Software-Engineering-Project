import express from 'express';
import { requireAuth } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { 
  searchBeds, 
  searchBedsPublic,
  reserveBed,
  getReservedBeds,
  completeReservation,
  cancelReservation
} from '../controllers/bedController.js';

const router = express.Router();

// Public endpoint - Search for available beds (no authentication required)
// GET /beds/public?region=Greater Accra&ward_type=icu
router.get('/public', searchBedsPublic);

// Search for available beds across all hospitals (authenticated)
// GET /beds/search?region=Greater Accra&ward_type=icu&min_beds=1
router.get('/search', requireAuth, requireRole(['admin', 'doctor', 'nurse']), searchBeds);

// Reserve a bed for emergency
// POST /beds/reserve
router.post('/reserve', requireAuth, requireRole(['admin', 'doctor', 'nurse']), reserveBed);

// Get all reserved beds
// GET /beds/reserved
router.get('/reserved', requireAuth, requireRole(['admin', 'doctor', 'nurse']), getReservedBeds);

// Complete a reservation (convert to admission)
// POST /beds/reserved/:reservationId/complete
router.post('/reserved/:reservationId/complete', requireAuth, requireRole(['admin', 'doctor', 'nurse']), completeReservation);

// Cancel a reservation
// DELETE /beds/reserved/:reservationId
router.delete('/reserved/:reservationId', requireAuth, requireRole(['admin', 'doctor', 'nurse']), cancelReservation);

export default router;

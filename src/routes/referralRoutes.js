import express from 'express';
import { requireAuth } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { 
  createReferral, 
  listReferrals, 
  getReferral, 
  acceptReferral, 
  rejectReferral, 
  completeReferral,
  cancelReferral 
} from '../controllers/referralController.js';
import { validate } from '../middleware/validate.js';
import { createReferralSchema, completeReferralSchema } from '../validators/referralSchemas.js';

const router = express.Router();

// List referrals (paginated, filtered by hospital)
router.get('/', requireAuth, requireRole(['admin', 'doctor', 'nurse']), listReferrals);

// Get single referral
router.get('/:id', requireAuth, requireRole(['admin', 'doctor', 'nurse']), getReferral);

// Create referral
router.post('/', requireAuth, requireRole(['admin', 'doctor']), validate(createReferralSchema), createReferral);

// Accept referral (receiving hospital)
router.patch('/:id/accept', requireAuth, requireRole(['admin', 'doctor']), acceptReferral);

// Reject referral (receiving hospital)
router.patch('/:id/reject', requireAuth, requireRole(['admin', 'doctor']), rejectReferral);

// Complete referral - admit patient at receiving hospital
router.post('/:id/complete', requireAuth, requireRole(['admin', 'doctor', 'nurse']), validate(completeReferralSchema), completeReferral);

// Cancel referral (sending hospital)
router.patch('/:id/cancel', requireAuth, requireRole(['admin', 'doctor']), cancelReferral);

export default router;

import { Router } from 'express';
import { submitContactRequest } from '../controllers/contactController.js';
import { passwordResetLimiter } from '../middleware/rateLimiter.js';

const router = Router();

// Submit a contact/support request (public with rate limiting)
router.post(
  '/',
  passwordResetLimiter, // Reuse the strict limiter to prevent spam
  submitContactRequest
);

export default router;

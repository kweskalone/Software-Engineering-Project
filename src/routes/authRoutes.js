import express from 'express';
import { login, refreshToken, logout, forgotPassword, resetPassword } from '../controllers/authController.js';
import { requireAuth } from '../middleware/auth.js';
import { authLimiter, passwordResetLimiter } from '../middleware/rateLimiter.js';
import { validate } from '../middleware/validate.js';
import { loginSchema, refreshTokenSchema, forgotPasswordSchema, resetPasswordSchema } from '../validators/authSchemas.js';

const router = express.Router();

// Auth endpoints with stricter rate limits
router.post('/login', authLimiter, validate(loginSchema), login);
router.post('/refresh', authLimiter, validate(refreshTokenSchema), refreshToken);
router.post('/logout', requireAuth, logout);
router.post('/forgot-password', passwordResetLimiter, validate(forgotPasswordSchema), forgotPassword);
router.post('/reset-password', passwordResetLimiter, validate(resetPasswordSchema), resetPassword);

export default router;

import express from 'express';
import { requireAuth } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { getDashboardStats, getSystemStats } from '../controllers/dashboardController.js';

const router = express.Router();

// Get dashboard stats for current user's hospital
router.get('/stats', requireAuth, requireRole(['admin', 'doctor', 'nurse']), getDashboardStats);

// Get system-wide stats (admin only)
router.get('/system-stats', requireAuth, requireRole(['admin']), getSystemStats);

export default router;

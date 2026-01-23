import express from 'express';
import { requireAuth } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import {
  listNotifications,
  getNotificationCount,
  markNotificationRead,
  markAllNotificationsRead,
} from '../controllers/notificationController.js';

const router = express.Router();

// Get all notifications for the authenticated user (paginated)
router.get('/', requireAuth, requireRole(['admin', 'doctor', 'nurse']), listNotifications);

// Get unread notification count
router.get('/unread-count', requireAuth, requireRole(['admin', 'doctor', 'nurse']), getNotificationCount);

// Mark all notifications as read
router.post('/mark-all-read', requireAuth, requireRole(['admin', 'doctor', 'nurse']), markAllNotificationsRead);

// Mark a single notification as read
router.patch('/:id/read', requireAuth, requireRole(['admin', 'doctor', 'nurse']), markNotificationRead);

export default router;

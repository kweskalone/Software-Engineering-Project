import { 
  getUserNotifications, 
  getUnreadCount, 
  markAsRead, 
  markAllAsRead 
} from '../services/notificationService.js';
import { parsePagination, buildPaginationMeta } from '../utils/pagination.js';

/**
 * Get notifications for the authenticated user
 * GET /notifications
 */
async function listNotifications(req, res, next) {
  try {
    const { page, limit, offset } = parsePagination(req.query);
    const unreadOnly = req.query.unread === 'true';

    const { notifications, totalCount } = await getUserNotifications({
      userId: req.auth.userId,
      limit,
      offset,
      unreadOnly,
    });

    return res.status(200).json({
      notifications,
      pagination: buildPaginationMeta({ page, limit, totalCount }),
    });
  } catch (err) {
    return next(err);
  }
}

/**
 * Get unread notification count
 * GET /notifications/unread-count
 */
async function getNotificationCount(req, res, next) {
  try {
    const count = await getUnreadCount(req.auth.userId);

    return res.status(200).json({
      unread_count: count,
    });
  } catch (err) {
    return next(err);
  }
}

/**
 * Mark a single notification as read
 * PATCH /notifications/:id/read
 */
async function markNotificationRead(req, res, next) {
  try {
    const { id } = req.params;
    const result = await markAsRead(id, req.auth.userId);

    return res.status(200).json(result);
  } catch (err) {
    return next(err);
  }
}

/**
 * Mark all notifications as read
 * POST /notifications/mark-all-read
 */
async function markAllNotificationsRead(req, res, next) {
  try {
    const result = await markAllAsRead(req.auth.userId);

    return res.status(200).json(result);
  } catch (err) {
    return next(err);
  }
}

export {
  listNotifications,
  getNotificationCount,
  markNotificationRead,
  markAllNotificationsRead,
};

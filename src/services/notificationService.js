import { getSupabaseClients } from '../config/supabaseClient.js';

/**
 * Notification types
 */
export const NOTIFICATION_TYPES = {
  REFERRAL_RECEIVED: 'referral_received',
  REFERRAL_ACCEPTED: 'referral_accepted',
  REFERRAL_REJECTED: 'referral_rejected',
  REFERRAL_COMPLETED: 'referral_completed',
  ADMISSION_CREATED: 'admission_created',
  DISCHARGE_CREATED: 'discharge_created',
  BED_AVAILABLE: 'bed_available',
  SYSTEM: 'system',
};

/**
 * Create a notification for a user
 * @param {Object} params
 * @param {string} params.userId - The users table ID (not auth_user_id)
 * @param {string} params.type - Notification type
 * @param {string} params.title - Short title
 * @param {string} params.message - Full message
 * @param {string} [params.referenceId] - Related entity UUID
 * @param {string} [params.referenceType] - Type of reference (referral, admission, etc.)
 */
export async function createNotification({ userId, type, title, message, referenceId, referenceType }) {
  const { supabaseService, supabaseAnon } = getSupabaseClients();
  const db = supabaseService || supabaseAnon;

  const { data, error } = await db
    .from('notifications')
    .insert({
      user_id: userId,
      type,
      title,
      message,
      reference_id: referenceId || null,
      reference_type: referenceType || null,
    })
    .select('id, type, title, message, is_read, created_at')
    .single();

  if (error) {
    console.error('Failed to create notification:', error);
    // Don't throw - notifications are non-critical
    return null;
  }

  return data;
}

/**
 * Create notifications for all users at a hospital
 * @param {Object} params
 * @param {string} params.hospitalId - Hospital UUID
 * @param {string[]} [params.roles] - Filter by roles (optional)
 * @param {string} params.type - Notification type
 * @param {string} params.title - Short title
 * @param {string} params.message - Full message
 * @param {string} [params.referenceId] - Related entity UUID
 * @param {string} [params.referenceType] - Type of reference
 * @param {string} [params.excludeUserId] - User ID to exclude (e.g., the actor)
 */
export async function notifyHospitalUsers({ 
  hospitalId, 
  roles, 
  type, 
  title, 
  message, 
  referenceId, 
  referenceType,
  excludeUserId 
}) {
  const { supabaseService, supabaseAnon } = getSupabaseClients();
  const db = supabaseService || supabaseAnon;

  // Get all users at the hospital
  let query = db
    .from('users')
    .select('id')
    .eq('hospital_id', hospitalId);

  if (roles && roles.length > 0) {
    query = query.in('role', roles);
  }

  if (excludeUserId) {
    query = query.neq('id', excludeUserId);
  }

  const { data: users, error: usersError } = await query;

  if (usersError) {
    console.error('Failed to get hospital users for notification:', usersError);
    return [];
  }

  if (!users || users.length === 0) {
    return [];
  }

  // Create notifications for all users
  const notifications = users.map(user => ({
    user_id: user.id,
    type,
    title,
    message,
    reference_id: referenceId || null,
    reference_type: referenceType || null,
  }));

  const { data, error } = await db
    .from('notifications')
    .insert(notifications)
    .select('id, user_id, type, title, message, is_read, created_at');

  if (error) {
    console.error('Failed to create hospital notifications:', error);
    return [];
  }

  return data || [];
}

/**
 * Get notifications for a user
 * @param {Object} params
 * @param {string} params.userId - The users table ID
 * @param {number} [params.limit=20] - Max results
 * @param {number} [params.offset=0] - Offset for pagination
 * @param {boolean} [params.unreadOnly=false] - Only return unread
 */
export async function getUserNotifications({ userId, limit = 20, offset = 0, unreadOnly = false }) {
  const { supabaseService, supabaseAnon } = getSupabaseClients();
  const db = supabaseService || supabaseAnon;

  let query = db
    .from('notifications')
    .select('id, type, title, message, reference_id, reference_type, is_read, created_at', { count: 'exact' })
    .eq('user_id', userId)
    .order('created_at', { ascending: false });

  if (unreadOnly) {
    query = query.eq('is_read', false);
  }

  const { data, count, error } = await query.range(offset, offset + limit - 1);

  if (error) {
    error.statusCode = 500;
    error.publicMessage = 'Failed to load notifications';
    throw error;
  }

  return { notifications: data || [], totalCount: count || 0 };
}

/**
 * Get unread notification count for a user
 * @param {string} userId - The users table ID
 */
export async function getUnreadCount(userId) {
  const { supabaseService, supabaseAnon } = getSupabaseClients();
  const db = supabaseService || supabaseAnon;

  const { count, error } = await db
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .eq('user_id', userId)
    .eq('is_read', false);

  if (error) {
    console.error('Failed to get unread count:', error);
    return 0;
  }

  return count || 0;
}

/**
 * Mark a notification as read
 * @param {string} notificationId - Notification UUID
 * @param {string} userId - User ID for ownership check
 */
export async function markAsRead(notificationId, userId) {
  const { supabaseService, supabaseAnon } = getSupabaseClients();
  const db = supabaseService || supabaseAnon;

  const { data, error } = await db
    .from('notifications')
    .update({ is_read: true })
    .eq('id', notificationId)
    .eq('user_id', userId)
    .select('id, is_read')
    .single();

  if (error) {
    if (error.code === 'PGRST116') {
      const err = new Error('Notification not found');
      err.statusCode = 404;
      err.publicMessage = 'Notification not found';
      throw err;
    }
    error.statusCode = 500;
    error.publicMessage = 'Failed to update notification';
    throw error;
  }

  return data;
}

/**
 * Mark all notifications as read for a user
 * @param {string} userId - User ID
 */
export async function markAllAsRead(userId) {
  const { supabaseService, supabaseAnon } = getSupabaseClients();
  const db = supabaseService || supabaseAnon;

  const { error } = await db
    .from('notifications')
    .update({ is_read: true })
    .eq('user_id', userId)
    .eq('is_read', false);

  if (error) {
    error.statusCode = 500;
    error.publicMessage = 'Failed to mark notifications as read';
    throw error;
  }

  return { success: true };
}

/**
 * Delete old notifications (cleanup job)
 * @param {number} daysOld - Delete notifications older than this many days
 */
export async function deleteOldNotifications(daysOld = 30) {
  const { supabaseService, supabaseAnon } = getSupabaseClients();
  const db = supabaseService || supabaseAnon;

  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - daysOld);

  const { error } = await db
    .from('notifications')
    .delete()
    .lt('created_at', cutoffDate.toISOString());

  if (error) {
    console.error('Failed to delete old notifications:', error);
    return false;
  }

  return true;
}

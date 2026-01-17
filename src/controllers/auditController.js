import { supabase } from '../config/supabaseClient.js';
import { AppError } from '../middleware/errorHandlers.js';
import { parsePagination, buildPaginationMeta } from '../utils/pagination.js';

/**
 * Get audit logs for the current user's hospital
 * GET /audit-logs
 * 
 * Query params:
 * - page, limit: pagination
 * - action: filter by action type (e.g., 'admission.create', 'referral.accept')
 * - entity_type: filter by entity (admission, referral, discharge, patient)
 * - user_id: filter by specific user who performed action
 * - start_date, end_date: date range filter
 */
export const listAuditLogs = async (req, res, next) => {
  try {
    const hospitalId = req.auth.hospitalId;
    const { page, limit, offset } = parsePagination(req.query);
    const { action, entity_type, user_id, start_date, end_date } = req.query;

    // Build query
    let query = supabase
      .from('audit_logs')
      .select('*', { count: 'exact' })
      .eq('hospital_id', hospitalId)
      .order('created_at', { ascending: false });

    // Apply filters
    if (action) {
      query = query.eq('action', action);
    }

    if (entity_type) {
      query = query.eq('entity_type', entity_type);
    }

    if (user_id) {
      query = query.eq('user_id', user_id);
    }

    if (start_date) {
      query = query.gte('created_at', `${start_date}T00:00:00`);
    }

    if (end_date) {
      query = query.lte('created_at', `${end_date}T23:59:59`);
    }

    // Apply pagination
    query = query.range(offset, offset + limit - 1);

    const { data, error, count } = await query;

    if (error) throw error;

    // Enrich logs with user names (optional - can be done on frontend)
    // For now, return raw data for simplicity

    res.json({
      success: true,
      data,
      pagination: buildPaginationMeta(count, page, limit)
    });
  } catch (error) {
    next(new AppError(error.message || 'Failed to fetch audit logs', 500));
  }
};

/**
 * Get a specific audit log entry
 * GET /audit-logs/:id
 */
export const getAuditLog = async (req, res, next) => {
  try {
    const { id } = req.params;
    const hospitalId = req.auth.hospitalId;

    const { data, error } = await supabase
      .from('audit_logs')
      .select('*')
      .eq('id', id)
      .eq('hospital_id', hospitalId)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return next(new AppError('Audit log entry not found', 404));
      }
      throw error;
    }

    res.json({
      success: true,
      data
    });
  } catch (error) {
    next(new AppError(error.message || 'Failed to fetch audit log', 500));
  }
};

/**
 * Get audit log summary/statistics
 * GET /audit-logs/summary
 * 
 * Returns counts by action type for reporting
 */
export const getAuditSummary = async (req, res, next) => {
  try {
    const hospitalId = req.auth.hospitalId;
    const { start_date, end_date } = req.query;

    // Default to last 7 days if no dates provided
    const endDate = end_date || new Date().toISOString().split('T')[0];
    const startDate = start_date || new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

    // Get all logs in the date range
    const { data, error } = await supabase
      .from('audit_logs')
      .select('action, entity_type')
      .eq('hospital_id', hospitalId)
      .gte('created_at', `${startDate}T00:00:00`)
      .lte('created_at', `${endDate}T23:59:59`);

    if (error) throw error;

    // Count by action
    const actionCounts = {};
    const entityCounts = {};

    (data || []).forEach(log => {
      actionCounts[log.action] = (actionCounts[log.action] || 0) + 1;
      entityCounts[log.entity_type] = (entityCounts[log.entity_type] || 0) + 1;
    });

    res.json({
      success: true,
      data: {
        period: {
          start: startDate,
          end: endDate
        },
        total_events: data?.length || 0,
        by_action: actionCounts,
        by_entity: entityCounts
      }
    });
  } catch (error) {
    next(new AppError(error.message || 'Failed to fetch audit summary', 500));
  }
};

import { supabase } from '../config/supabaseClient.js';
import { AppError } from '../middleware/errorHandlers.js';
import { parsePagination, buildPaginationMeta } from '../utils/pagination.js';

/**
 * Get audit logs (admin only)
 * GET /audit-logs
 * 
 * Query params:
 * - page, limit: pagination
 * - action: filter by action type (e.g., 'admission.create', 'referral.accept')
 * - table_name: filter by table (admissions, referrals, discharges, patients, users)
 * - user_id: filter by specific user who performed action
 * - start_date, end_date: date range filter
 */
export const listAuditLogs = async (req, res, next) => {
  try {
    const { page, limit, offset } = parsePagination(req.query);
    const { action, table_name, entity_type, user_id, start_date, end_date } = req.query;

    // Build query - audit_logs doesn't have hospital_id, so admin sees all logs
    let query = supabase
      .from('audit_logs')
      .select('*', { count: 'exact' })
      .order('created_at', { ascending: false });

    // Apply filters
    if (action) {
      query = query.eq('action', action);
    }

    // Support both table_name and entity_type (for backwards compatibility)
    const tableFilter = table_name || entity_type;
    if (tableFilter) {
      query = query.eq('table_name', tableFilter);
    }

    if (user_id) {
      query = query.eq('actor_auth_user_id', user_id);
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

    // Transform data to include entity_type for frontend compatibility
    const transformedData = (data || []).map(log => ({
      ...log,
      entity_type: log.table_name // Map table_name to entity_type for frontend
    }));

    res.json({
      success: true,
      data: transformedData,
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

    const { data, error } = await supabase
      .from('audit_logs')
      .select('*')
      .eq('id', id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return next(new AppError('Audit log entry not found', 404));
      }
      throw error;
    }

    // Add entity_type for frontend compatibility
    const transformedData = {
      ...data,
      entity_type: data.table_name
    };

    res.json({
      success: true,
      data: transformedData
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
    const { start_date, end_date } = req.query;

    // Default to last 7 days if no dates provided
    const endDate = end_date || new Date().toISOString().split('T')[0];
    const startDate = start_date || new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

    // Get all logs in the date range - use table_name (actual column name)
    const { data, error } = await supabase
      .from('audit_logs')
      .select('action, table_name')
      .gte('created_at', `${startDate}T00:00:00`)
      .lte('created_at', `${endDate}T23:59:59`);

    if (error) throw error;

    // Count by action and table_name
    const actionCounts = {};
    const entityCounts = {};

    (data || []).forEach(log => {
      actionCounts[log.action] = (actionCounts[log.action] || 0) + 1;
      entityCounts[log.table_name] = (entityCounts[log.table_name] || 0) + 1;
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

import { getSupabaseClients } from '../config/supabaseClient.js';
import { logAudit } from '../services/auditService.js';
import { parsePagination, buildPaginationMeta } from '../utils/pagination.js';

async function createHospital(req, res, next) {
  try {
    const { name, region, district } = req.body || {};
    if (!name) return res.status(400).json({ error: 'name is required' });

    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;

    const { data, error } = await db
      .from('hospitals')
      .insert({
        name,
        region: region || null,
        district: district || null
      })
      .select('id, name, region, district, created_at')
      .single();

    if (error) {
      error.statusCode = 500;
      error.publicMessage = 'Failed to create hospital';
      throw error;
    }

    await logAudit({
      actor: req.auth,
      action: 'hospital.create',
      tableName: 'hospitals',
      recordId: data?.id || null,
      newData: data
    });

    return res.status(201).json({ hospital: data });
  } catch (err) {
    return next(err);
  }
}

async function listHospitals(req, res, next) {
  try {
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;
    const { page, limit, offset } = parsePagination(req.query);

    // Get total count for pagination
    const { count, error: countError } = await db
      .from('hospitals')
      .select('*', { count: 'exact', head: true });

    if (countError) {
      countError.statusCode = 500;
      countError.publicMessage = 'Failed to load hospitals';
      throw countError;
    }

    // Fetch paginated data
    const { data, error } = await db
      .from('hospitals')
      .select('id, name, region, district')
      .order('name')
      .range(offset, offset + limit - 1);

    if (error) {
      error.statusCode = 500;
      error.publicMessage = 'Failed to load hospitals';
      throw error;
    }

    return res.status(200).json({
      hospitals: data,
      pagination: buildPaginationMeta({ page, limit, totalCount: count || 0 })
    });
  } catch (err) {
    return next(err);
  }
}

async function updateHospital(req, res, next) {
  try {
    const hospitalId = req.params.id;

    // Simple, realistic rule: an admin can manage their own hospital record.
    if (req.auth?.hospitalId && req.auth.hospitalId !== hospitalId) {
      return res.status(403).json({ error: 'You can only update your own hospital' });
    }

    const { name, region, district } = req.body || {};
    if (!name && !region && !district) {
      return res.status(400).json({ error: 'At least one of name, region, district is required' });
    }

    const patch = {};
    if (name !== undefined) patch.name = name;
    if (region !== undefined) patch.region = region;
    if (district !== undefined) patch.district = district;

    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;

    const { data, error } = await db
      .from('hospitals')
      .update(patch)
      .eq('id', hospitalId)
      .select('id, name, region, district, created_at')
      .single();

    if (error) {
      if (error.code === 'PGRST116') return res.status(404).json({ error: 'Hospital not found' });
      error.statusCode = 500;
      error.publicMessage = 'Failed to update hospital';
      throw error;
    }

    await logAudit({
      actor: req.auth,
      action: 'hospital.update',
      tableName: 'hospitals',
      recordId: data?.id || null,
      newData: data
    });

    return res.status(200).json({ hospital: data });
  } catch (err) {
    return next(err);
  }
}

export { createHospital, listHospitals, updateHospital };

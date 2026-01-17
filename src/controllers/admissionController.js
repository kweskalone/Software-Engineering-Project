import { createAdmission as createAdmissionService } from '../services/admissionService.js';
import { getSupabaseClients } from '../config/supabaseClient.js';
import { parsePagination, buildPaginationMeta } from '../utils/pagination.js';

async function createAdmission(req, res, next) {
  try {
    const { ward_id, patient } = req.body;

    const result = await createAdmissionService({
      actor: req.auth,
      wardId: ward_id,
      patient
    });

    return res.status(201).json(result);
  } catch (err) {
    return next(err);
  }
}

/**
 * List admissions for the user's hospital.
 * Supports pagination and filtering by status.
 */
async function listAdmissions(req, res, next) {
  try {
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;
    const { page, limit, offset } = parsePagination(req.query);
    const { status, ward_id } = req.query;

    // Build base query
    let countQuery = db
      .from('admissions')
      .select('*', { count: 'exact', head: true })
      .eq('hospital_id', req.auth.hospitalId);

    let dataQuery = db
      .from('admissions')
      .select(`
        id,
        status,
        admitted_at,
        discharged_at,
        patient_id,
        ward_id,
        hospital_id,
        patients (id, full_name, sex, date_of_birth, phone, national_id),
        wards (id, name, type)
      `)
      .eq('hospital_id', req.auth.hospitalId)
      .order('admitted_at', { ascending: false });

    // Apply filters
    if (status) {
      countQuery = countQuery.eq('status', status);
      dataQuery = dataQuery.eq('status', status);
    }
    if (ward_id) {
      countQuery = countQuery.eq('ward_id', ward_id);
      dataQuery = dataQuery.eq('ward_id', ward_id);
    }

    const { count, error: countError } = await countQuery;
    if (countError) {
      countError.statusCode = 500;
      countError.publicMessage = 'Failed to load admissions';
      throw countError;
    }

    const { data, error } = await dataQuery.range(offset, offset + limit - 1);
    if (error) {
      error.statusCode = 500;
      error.publicMessage = 'Failed to load admissions';
      throw error;
    }

    return res.status(200).json({
      admissions: data,
      pagination: buildPaginationMeta({ page, limit, totalCount: count || 0 })
    });
  } catch (err) {
    return next(err);
  }
}

/**
 * Get a single admission by ID.
 */
async function getAdmission(req, res, next) {
  try {
    const admissionId = req.params.id;
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;

    const { data, error } = await db
      .from('admissions')
      .select(`
        id,
        status,
        admitted_at,
        discharged_at,
        patient_id,
        ward_id,
        hospital_id,
        admitted_by_auth_user_id,
        discharged_by_auth_user_id,
        patients (id, full_name, sex, date_of_birth, phone, national_id),
        wards (id, name, type, hospital_id)
      `)
      .eq('id', admissionId)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return res.status(404).json({ error: 'Admission not found' });
      }
      error.statusCode = 500;
      error.publicMessage = 'Failed to load admission';
      throw error;
    }

    // Check hospital access
    if (data.hospital_id !== req.auth.hospitalId && req.auth.role !== 'admin') {
      return res.status(403).json({ error: 'Access denied to this admission' });
    }

    return res.status(200).json({ admission: data });
  } catch (err) {
    return next(err);
  }
}

export { createAdmission, listAdmissions, getAdmission };

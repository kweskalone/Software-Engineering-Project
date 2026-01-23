import { getSupabaseClients } from '../config/supabaseClient.js';
import { parsePagination, buildPaginationMeta } from '../utils/pagination.js';

// List patients with pagination and search support
async function listPatients(req, res, next) {
  try {
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;
    const { page, limit, offset } = parsePagination(req.query);
    const { search, national_id } = req.query;

    // Build base query
    let countQuery = db
      .from('patients')
      .select('*', { count: 'exact', head: true });

    let dataQuery = db
      .from('patients')
      .select('id, full_name, sex, date_of_birth, phone, national_id, created_at')
      .order('created_at', { ascending: false });

    // Apply search filter (name or national_id)
    if (search) {
      const searchPattern = `%${search}%`;
      countQuery = countQuery.or(`full_name.ilike.${searchPattern},national_id.ilike.${searchPattern}`);
      dataQuery = dataQuery.or(`full_name.ilike.${searchPattern},national_id.ilike.${searchPattern}`);
    }

    // Exact national_id lookup
    if (national_id) {
      countQuery = countQuery.eq('national_id', national_id);
      dataQuery = dataQuery.eq('national_id', national_id);
    }

    const { count, error: countError } = await countQuery;
    if (countError) {
      countError.statusCode = 500;
      countError.publicMessage = 'Failed to load patients';
      throw countError;
    }

    const { data, error } = await dataQuery.range(offset, offset + limit - 1);
    if (error) {
      error.statusCode = 500;
      error.publicMessage = 'Failed to load patients';
      throw error;
    }

    return res.status(200).json({
      patients: data,
      pagination: buildPaginationMeta({ page, limit, totalCount: count || 0 })
    });
  } catch (err) {
    return next(err);
  }
}

// Get a single patient by ID, including their admission history
async function getPatient(req, res, next) {
  try {
    const patientId = req.params.id;
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;

    // Get patient details
    const { data: patient, error: patientError } = await db
      .from('patients')
      .select('id, full_name, sex, date_of_birth, phone, national_id, created_at')
      .eq('id', patientId)
      .single();

    if (patientError) {
      if (patientError.code === 'PGRST116') {
        return res.status(404).json({ error: 'Patient not found' });
      }
      patientError.statusCode = 500;
      patientError.publicMessage = 'Failed to load patient';
      throw patientError;
    }

    // Get admission history for this patient (scoped to user's hospital)
    const { data: admissions, error: admissionsError } = await db
      .from('admissions')
      .select(`
        id,
        status,
        admitted_at,
        discharged_at,
        hospital_id,
        ward_id,
        wards (id, name, type),
        hospitals (id, name)
      `)
      .eq('patient_id', patientId)
      .eq('hospital_id', req.auth.hospitalId)
      .order('admitted_at', { ascending: false });

    if (admissionsError) {
      admissionsError.statusCode = 500;
      admissionsError.publicMessage = 'Failed to load patient admissions';
      throw admissionsError;
    }

    return res.status(200).json({
      patient,
      admissions: admissions || []
    });
  } catch (err) {
    return next(err);
  }
}

export { listPatients, getPatient };

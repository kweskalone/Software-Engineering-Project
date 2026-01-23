import { getSupabaseClients } from '../config/supabaseClient.js';
import { logAudit } from './auditService.js';

function mapRpcErrorToHttp(error) {
  // Postgres exceptions will show up in error.message
  const msg = (error && (error.message || error.details || '')).toString();

  if (msg.includes('NO_BEDS_AVAILABLE')) {
    return { statusCode: 409, publicMessage: 'No beds available in this ward' };
  }

  if (msg.includes('WARD_HOSPITAL_MISMATCH')) {
    return { statusCode: 403, publicMessage: 'Ward does not belong to your hospital' };
  }

  return { statusCode: 500, publicMessage: 'Failed to create admission' };
}

// Create admission with bed availability check
async function createAdmission({ actor, wardId, patient }) {
  const {
    full_name,
    sex,
    date_of_birth,
    phone,
    national_id
  } = patient || {};

  if (!full_name || !sex) {
    const err = new Error('Invalid patient object');
    err.statusCode = 400;
    err.publicMessage = 'patient.full_name and patient.sex are required';
    throw err;
  }

  const { supabaseService, supabaseAnon } = getSupabaseClients();
  const db = supabaseService || supabaseAnon;

  const { data, error } = await db.rpc('create_admission', {
    p_actor_hospital_id: actor.hospitalId,
    p_ward_id: wardId,
    p_patient_full_name: full_name,
    p_patient_sex: sex,
    p_patient_date_of_birth: date_of_birth || null,
    p_patient_phone: phone || null,
    p_patient_national_id: national_id || null,
    p_actor_auth_user_id: actor.user.id
  });

  if (error) {
    const mapped = mapRpcErrorToHttp(error);
    error.statusCode = mapped.statusCode;
    error.publicMessage = mapped.publicMessage;
    throw error;
  }

  // RPC returns a single row (json) with admission + updated ward availability
  await logAudit({
    actor,
    action: 'admission.create',
    tableName: 'admissions',
    recordId: data?.admission?.id || null,
    newData: data?.admission || null
  });

  return data;
}

export { createAdmission };

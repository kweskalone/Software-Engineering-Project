import { getSupabaseClients } from '../config/supabaseClient.js';
import { logAudit } from './auditService.js';

function mapRpcErrorToHttp(error) {
  const msg = (error && (error.message || '')).toString();

  if (msg.includes('ADMISSION_NOT_FOUND')) {
    return { statusCode: 404, publicMessage: 'Admission not found' };
  }
  if (msg.includes('ALREADY_DISCHARGED')) {
    return { statusCode: 409, publicMessage: 'Admission already discharged' };
  }
  if (msg.includes('ADMISSION_HOSPITAL_MISMATCH')) {
    return { statusCode: 403, publicMessage: 'Admission does not belong to your hospital' };
  }

  return { statusCode: 500, publicMessage: 'Failed to discharge patient' };
}

async function discharge({ actor, admissionId }) {
  const { supabaseService, supabaseAnon } = getSupabaseClients();
  const db = supabaseService || supabaseAnon;

  const { data, error } = await db.rpc('discharge_patient', {
    p_actor_hospital_id: actor.hospitalId,
    p_admission_id: admissionId,
    p_actor_auth_user_id: actor.user.id
  });

  if (error) {
    const mapped = mapRpcErrorToHttp(error);
    error.statusCode = mapped.statusCode;
    error.publicMessage = mapped.publicMessage;
    throw error;
  }

  await logAudit({
    actor,
    action: 'admission.discharge',
    tableName: 'admissions',
    recordId: data?.admission?.id || null,
    newData: data?.admission || null
  });

  return data;
}

export { discharge };

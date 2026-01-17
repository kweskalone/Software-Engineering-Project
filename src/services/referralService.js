import { getSupabaseClients } from '../config/supabaseClient.js';
import { logAudit } from './auditService.js';

async function createReferral({ actor, patientId, fromWardId, toHospitalId, reason }) {
  const { supabaseService, supabaseAnon } = getSupabaseClients();
  const db = supabaseService || supabaseAnon;

  // Rule: referrals can only be created when current hospital has no beds
  const { data: availabilityRows, error: availabilityError } = await db
    .from('wards')
    .select('available_beds')
    .eq('hospital_id', actor.hospitalId);

  if (availabilityError) {
    availabilityError.statusCode = 500;
    availabilityError.publicMessage = 'Failed to check hospital availability';
    throw availabilityError;
  }

  const totalAvailable = (availabilityRows || []).reduce((sum, w) => sum + Number(w.available_beds || 0), 0);
  if (totalAvailable > 0) {
    const err = new Error('Beds still available');
    err.statusCode = 409;
    err.publicMessage = 'Referral allowed only when hospital has no available beds';
    throw err;
  }

  // Basic ownership check (ward must belong to actor hospital)
  const { data: ward, error: wardError } = await db
    .from('wards')
    .select('id, hospital_id')
    .eq('id', fromWardId)
    .single();

  if (wardError) {
    if (wardError.code === 'PGRST116') {
      const err = new Error('Ward not found');
      err.statusCode = 404;
      err.publicMessage = 'Ward not found';
      throw err;
    }
    wardError.statusCode = 500;
    wardError.publicMessage = 'Failed to load ward';
    throw wardError;
  }

  if (ward.hospital_id !== actor.hospitalId && actor.role !== 'admin') {
    const err = new Error('Forbidden');
    err.statusCode = 403;
    err.publicMessage = 'Ward does not belong to your hospital';
    throw err;
  }

  const { data: referral, error } = await db
    .from('referrals')
    .insert({
      patient_id: patientId,
      from_hospital_id: actor.hospitalId,
      from_ward_id: fromWardId,
      to_hospital_id: toHospitalId,
      reason: reason,
      status: 'pending',
      created_by_auth_user_id: actor.user.id
    })
    .select('id, status, created_at, patient_id, from_hospital_id, from_ward_id, to_hospital_id, reason')
    .single();

  if (error) {
    error.statusCode = 500;
    error.publicMessage = 'Failed to create referral';
    throw error;
  }

  await logAudit({
    actor,
    action: 'referral.create',
    tableName: 'referrals',
    recordId: referral?.id || null,
    newData: referral
  });

  return { referral, hospital_available_beds: totalAvailable };
}

export { createReferral };

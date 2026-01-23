import { createReferral as createReferralService } from '../services/referralService.js';
import { getSupabaseClients } from '../config/supabaseClient.js';
import { parsePagination, buildPaginationMeta } from '../utils/pagination.js';
import { logAudit } from '../services/auditService.js';

async function createReferral(req, res, next) {
  try {
    const { patient_id, from_ward_id, to_hospital_id, reason } = req.body;

    const result = await createReferralService({
      actor: req.auth,
      patientId: patient_id,
      fromWardId: from_ward_id,
      toHospitalId: to_hospital_id,
      reason: reason || null
    });

    return res.status(201).json(result);
  } catch (err) {
    return next(err);
  }
}

// List referrals for the user's hospital (as sender or receiver)
async function listReferrals(req, res, next) {
  try {
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;
    const { page, limit, offset } = parsePagination(req.query);
    const { status, direction } = req.query;

    // Direction: 'outgoing' (from our hospital) or 'incoming' (to our hospital)
    const hospitalId = req.auth.hospitalId;
    const isOutgoing = direction !== 'incoming';

    // Build base query
    let countQuery = db
      .from('referrals')
      .select('*', { count: 'exact', head: true });

    let dataQuery = db
      .from('referrals')
      .select(`
        id,
        status,
        reason,
        created_at,
        patient_id,
        from_hospital_id,
        from_ward_id,
        to_hospital_id,
        patients (id, full_name, sex, date_of_birth),
        from_hospital:hospitals!referrals_from_hospital_id_fkey (id, name, region),
        from_ward:wards!referrals_from_ward_id_fkey (id, name, type),
        to_hospital:hospitals!referrals_to_hospital_id_fkey (id, name, region)
      `)
      .order('created_at', { ascending: false });

    // Filter by hospital direction
    if (isOutgoing) {
      countQuery = countQuery.eq('from_hospital_id', hospitalId);
      dataQuery = dataQuery.eq('from_hospital_id', hospitalId);
    } else {
      countQuery = countQuery.eq('to_hospital_id', hospitalId);
      dataQuery = dataQuery.eq('to_hospital_id', hospitalId);
    }

    // Apply status filter
    if (status) {
      countQuery = countQuery.eq('status', status);
      dataQuery = dataQuery.eq('status', status);
    }

    const { count, error: countError } = await countQuery;
    if (countError) {
      countError.statusCode = 500;
      countError.publicMessage = 'Failed to load referrals';
      throw countError;
    }

    const { data, error } = await dataQuery.range(offset, offset + limit - 1);
    if (error) {
      error.statusCode = 500;
      error.publicMessage = 'Failed to load referrals';
      throw error;
    }

    return res.status(200).json({
      referrals: data,
      direction: isOutgoing ? 'outgoing' : 'incoming',
      pagination: buildPaginationMeta({ page, limit, totalCount: count || 0 })
    });
  } catch (err) {
    return next(err);
  }
}

// Get a single referral by ID
async function getReferral(req, res, next) {
  try {
    const referralId = req.params.id;
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;

    const { data, error } = await db
      .from('referrals')
      .select(`
        id,
        status,
        reason,
        created_at,
        patient_id,
        from_hospital_id,
        from_ward_id,
        to_hospital_id,
        created_by_auth_user_id,
        patients (id, full_name, sex, date_of_birth, phone, national_id),
        from_hospital:hospitals!referrals_from_hospital_id_fkey (id, name, region, district),
        from_ward:wards!referrals_from_ward_id_fkey (id, name, type),
        to_hospital:hospitals!referrals_to_hospital_id_fkey (id, name, region, district)
      `)
      .eq('id', referralId)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return res.status(404).json({ error: 'Referral not found' });
      }
      error.statusCode = 500;
      error.publicMessage = 'Failed to load referral';
      throw error;
    }

    // Check hospital access (must be sender or receiver)
    const hospitalId = req.auth.hospitalId;
    if (data.from_hospital_id !== hospitalId && data.to_hospital_id !== hospitalId) {
      return res.status(403).json({ error: 'Access denied to this referral' });
    }

    return res.status(200).json({ referral: data });
  } catch (err) {
    return next(err);
  }
}

// Accept a referral (receiving hospital)
async function acceptReferral(req, res, next) {
  try {
    const referralId = req.params.id;
    const { ward_id, reservation_hours } = req.body || {};
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;

    // Ward ID is now required - must specify where the patient will go
    if (!ward_id) {
      return res.status(400).json({ 
        error: 'ward_id is required to accept a referral',
        hint: 'Specify which ward will receive the patient so a bed can be reserved'
      });
    }

    // Use the RPC function to atomically reserve the bed
    const { data: result, error: rpcError } = await db.rpc('reserve_bed_for_referral', {
      p_referral_id: referralId,
      p_ward_id: ward_id,
      p_hospital_id: req.auth.hospitalId,
      p_actor_auth_user_id: req.auth.user.id,
      p_reservation_hours: reservation_hours || 2  // Default 2 hours
    });

    if (rpcError) {
      const msg = (rpcError.message || '').toString();
      
      if (msg.includes('REFERRAL_NOT_FOUND')) {
        return res.status(404).json({ error: 'Referral not found' });
      }
      if (msg.includes('REFERRAL_NOT_PENDING')) {
        return res.status(409).json({ 
          error: 'Referral is not in pending status',
          hint: 'Only pending referrals can be accepted'
        });
      }
      if (msg.includes('HOSPITAL_MISMATCH')) {
        return res.status(403).json({ error: 'Only the receiving hospital can accept this referral' });
      }
      if (msg.includes('WARD_NOT_FOUND')) {
        return res.status(404).json({ error: 'Ward not found' });
      }
      if (msg.includes('WARD_HOSPITAL_MISMATCH')) {
        return res.status(403).json({ error: 'Ward does not belong to your hospital' });
      }
      if (msg.includes('NO_BEDS_AVAILABLE')) {
        return res.status(409).json({ 
          error: 'No beds available in the selected ward',
          hint: 'All beds are either occupied or already reserved for other referrals'
        });
      }
      
      rpcError.statusCode = 500;
      rpcError.publicMessage = 'Failed to accept referral';
      throw rpcError;
    }

    await logAudit({
      actor: req.auth,
      action: 'referral.accept',
      tableName: 'referrals',
      recordId: referralId,
      oldData: { status: 'pending' },
      newData: { 
        status: 'accepted',
        reservation_id: result?.reservation?.id,
        target_ward_id: ward_id
      }
    });

    return res.status(200).json({ 
      success: true,
      message: 'Referral accepted and bed reserved',
      referral: result?.referral,
      reservation: result?.reservation,
      ward: result?.ward,
      hint: `Bed reserved until ${result?.reservation?.expires_at}. Complete the referral before then to admit the patient.`
    });
  } catch (err) {
    return next(err);
  }
}

// Reject a referral (receiving hospital)
async function rejectReferral(req, res, next) {
  try {
    const referralId = req.params.id;
    const { rejection_reason } = req.body || {};
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;

    // Fetch the referral first
    const { data: referral, error: fetchError } = await db
      .from('referrals')
      .select('id, status, to_hospital_id, from_hospital_id')
      .eq('id', referralId)
      .single();

    if (fetchError) {
      if (fetchError.code === 'PGRST116') {
        return res.status(404).json({ error: 'Referral not found' });
      }
      fetchError.statusCode = 500;
      fetchError.publicMessage = 'Failed to load referral';
      throw fetchError;
    }

    // Only the receiving hospital can reject
    if (referral.to_hospital_id !== req.auth.hospitalId) {
      return res.status(403).json({ error: 'Only the receiving hospital can reject this referral' });
    }

    // Check current status (must be pending)
    if (referral.status !== 'pending') {
      return res.status(409).json({ 
        error: `Cannot reject referral with status '${referral.status}'`,
        current_status: referral.status
      });
    }

    // Update status to rejected
    const { data: updated, error: updateError } = await db
      .from('referrals')
      .update({ status: 'rejected' })
      .eq('id', referralId)
      .select('id, status, patient_id, from_hospital_id, to_hospital_id, reason, created_at')
      .single();

    if (updateError) {
      updateError.statusCode = 500;
      updateError.publicMessage = 'Failed to reject referral';
      throw updateError;
    }

    await logAudit({
      actor: req.auth,
      action: 'referral.reject',
      tableName: 'referrals',
      recordId: referralId,
      oldData: { status: 'pending' },
      newData: { status: 'rejected', rejection_reason }
    });

    return res.status(200).json({ 
      referral: updated,
      message: 'Referral rejected.'
    });
  } catch (err) {
    return next(err);
  }
}

// Complete a referral by admitting the patient at the receiving hospital
async function completeReferral(req, res, next) {
  try {
    const referralId = req.params.id;
    const { ward_id } = req.body;
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;

    // Fetch the referral with reservation info
    const { data: referral, error: fetchError } = await db
      .from('referrals')
      .select(`
        id, status, to_hospital_id, from_hospital_id, patient_id,
        reservation_id, target_ward_id,
        patients (id, full_name, sex, date_of_birth, phone, national_id)
      `)
      .eq('id', referralId)
      .single();

    if (fetchError) {
      if (fetchError.code === 'PGRST116') {
        return res.status(404).json({ error: 'Referral not found' });
      }
      fetchError.statusCode = 500;
      fetchError.publicMessage = 'Failed to load referral';
      throw fetchError;
    }

    // Only the receiving hospital can complete
    if (referral.to_hospital_id !== req.auth.hospitalId) {
      return res.status(403).json({ error: 'Only the receiving hospital can complete this referral' });
    }

    // Check current status (must be accepted)
    if (referral.status !== 'accepted') {
      return res.status(409).json({ 
        error: `Cannot complete referral with status '${referral.status}'. Must be 'accepted' first.`,
        current_status: referral.status
      });
    }

    // Use the reserved ward if no ward_id provided, otherwise use provided ward_id
    const targetWardId = ward_id || referral.target_ward_id;
    
    if (!targetWardId) {
      return res.status(400).json({ 
        error: 'ward_id is required to admit the patient',
        hint: 'Specify which ward will receive the patient'
      });
    }

    // Verify ward belongs to the receiving hospital
    const { data: ward, error: wardError } = await db
      .from('wards')
      .select('id, hospital_id, available_beds, reserved_beds')
      .eq('id', targetWardId)
      .single();

    if (wardError) {
      if (wardError.code === 'PGRST116') {
        return res.status(404).json({ error: 'Ward not found' });
      }
      wardError.statusCode = 500;
      wardError.publicMessage = 'Failed to load ward';
      throw wardError;
    }

    if (ward.hospital_id !== req.auth.hospitalId) {
      return res.status(403).json({ error: 'Ward does not belong to your hospital' });
    }

    // Check bed availability - if using the reserved ward, the reservation holds the bed
    const isUsingReservedWard = targetWardId === referral.target_ward_id && referral.reservation_id;
    
    if (!isUsingReservedWard && ward.available_beds <= (ward.reserved_beds || 0)) {
      return res.status(409).json({ 
        error: 'No beds available in the selected ward',
        hint: 'All beds are either occupied or reserved. Use the originally reserved ward if available.'
      });
    }

    // Complete the bed reservation if exists
    if (referral.reservation_id) {
      await db.rpc('complete_bed_reservation', {
        p_referral_id: referralId,
        p_ward_id: targetWardId,
        p_actor_hospital_id: req.auth.hospitalId,
        p_actor_auth_user_id: req.auth.user.id
      });
    }

    // Create admission at receiving hospital using RPC
    const { data: admissionResult, error: admissionError } = await db.rpc('create_admission', {
      p_actor_hospital_id: req.auth.hospitalId,
      p_ward_id: targetWardId,
      p_patient_full_name: referral.patients.full_name,
      p_patient_sex: referral.patients.sex,
      p_patient_date_of_birth: referral.patients.date_of_birth,
      p_patient_phone: referral.patients.phone,
      p_patient_national_id: referral.patients.national_id,
      p_actor_auth_user_id: req.auth.user.id
    });

    if (admissionError) {
      const msg = (admissionError.message || '').toString();
      if (msg.includes('NO_BEDS_AVAILABLE')) {
        return res.status(409).json({ error: 'No beds available in the selected ward' });
      }
      admissionError.statusCode = 500;
      admissionError.publicMessage = 'Failed to create admission';
      throw admissionError;
    }

    // Update referral status to completed
    const { data: updatedReferral, error: updateError } = await db
      .from('referrals')
      .update({ status: 'completed' })
      .eq('id', referralId)
      .select('id, status, patient_id, from_hospital_id, to_hospital_id, reason, created_at')
      .single();

    if (updateError) {
      updateError.statusCode = 500;
      updateError.publicMessage = 'Failed to complete referral';
      throw updateError;
    }

    await logAudit({
      actor: req.auth,
      action: 'referral.complete',
      tableName: 'referrals',
      recordId: referralId,
      oldData: { status: 'accepted' },
      newData: { status: 'completed', admission_id: admissionResult?.admission?.id }
    });

    return res.status(200).json({ 
      success: true,
      referral: updatedReferral,
      admission: admissionResult?.admission,
      ward: admissionResult?.ward,
      message: 'Referral completed. Patient has been admitted.'
    });
  } catch (err) {
    return next(err);
  }
}

// Cancel a referral (sender hospital)
async function cancelReferral(req, res, next) {
  try {
    const referralId = req.params.id;
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;

    // Fetch the referral first (including reservation info)
    const { data: referral, error: fetchError } = await db
      .from('referrals')
      .select('id, status, from_hospital_id, reservation_id')
      .eq('id', referralId)
      .single();

    if (fetchError) {
      if (fetchError.code === 'PGRST116') {
        return res.status(404).json({ error: 'Referral not found' });
      }
      fetchError.statusCode = 500;
      fetchError.publicMessage = 'Failed to load referral';
      throw fetchError;
    }

    // Only the sending hospital can cancel
    if (referral.from_hospital_id !== req.auth.hospitalId) {
      return res.status(403).json({ error: 'Only the sending hospital can cancel this referral' });
    }

    // Cannot cancel if already completed
    if (referral.status === 'completed') {
      return res.status(409).json({ 
        error: 'Cannot cancel a completed referral',
        current_status: referral.status
      });
    }

    // Cannot cancel if already cancelled
    if (referral.status === 'cancelled') {
      return res.status(409).json({ 
        error: 'Referral is already cancelled',
        current_status: referral.status
      });
    }

    // Release any active bed reservation
    let reservationReleased = false;
    if (referral.reservation_id) {
      const { data: releaseResult } = await db.rpc('release_bed_reservation', {
        p_reservation_id: referral.reservation_id,
        p_reason: 'cancelled'
      });
      reservationReleased = releaseResult?.success || false;
    }

    // Update status to cancelled
    const { data: updated, error: updateError } = await db
      .from('referrals')
      .update({ 
        status: 'cancelled',
        reservation_id: null,
        target_ward_id: null,
        reservation_expires_at: null
      })
      .eq('id', referralId)
      .select('id, status, patient_id, from_hospital_id, to_hospital_id, reason, created_at')
      .single();

    if (updateError) {
      updateError.statusCode = 500;
      updateError.publicMessage = 'Failed to cancel referral';
      throw updateError;
    }

    await logAudit({
      actor: req.auth,
      action: 'referral.cancel',
      tableName: 'referrals',
      recordId: referralId,
      oldData: { status: referral.status, reservation_id: referral.reservation_id },
      newData: { status: 'cancelled', reservation_released: reservationReleased }
    });

    return res.status(200).json({ 
      success: true,
      referral: updated,
      reservation_released: reservationReleased,
      message: reservationReleased 
        ? 'Referral cancelled and reserved bed released.' 
        : 'Referral cancelled.'
    });
  } catch (err) {
    return next(err);
  }
}

export { createReferral, listReferrals, getReferral, acceptReferral, rejectReferral, completeReferral, cancelReferral };

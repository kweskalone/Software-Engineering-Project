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

/**
 * List referrals for the user's hospital (as sender or receiver).
 * Supports pagination and filtering by status.
 */
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

/**
 * Get a single referral by ID.
 */
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

/**
 * Accept a referral (receiving hospital).
 * Only the TO hospital can accept.
 * Status: pending → accepted
 */
async function acceptReferral(req, res, next) {
  try {
    const referralId = req.params.id;
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;

    // Fetch the referral first
    const { data: referral, error: fetchError } = await db
      .from('referrals')
      .select('id, status, to_hospital_id, from_hospital_id, patient_id')
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

    // Only the receiving hospital can accept
    if (referral.to_hospital_id !== req.auth.hospitalId) {
      return res.status(403).json({ error: 'Only the receiving hospital can accept this referral' });
    }

    // Check current status (must be pending)
    if (referral.status !== 'pending') {
      return res.status(409).json({ 
        error: `Cannot accept referral with status '${referral.status}'`,
        current_status: referral.status
      });
    }

    // Update status to accepted
    const { data: updated, error: updateError } = await db
      .from('referrals')
      .update({ status: 'accepted' })
      .eq('id', referralId)
      .select('id, status, patient_id, from_hospital_id, to_hospital_id, reason, created_at')
      .single();

    if (updateError) {
      updateError.statusCode = 500;
      updateError.publicMessage = 'Failed to accept referral';
      throw updateError;
    }

    await logAudit({
      actor: req.auth,
      action: 'referral.accept',
      tableName: 'referrals',
      recordId: referralId,
      oldData: { status: 'pending' },
      newData: { status: 'accepted' }
    });

    return res.status(200).json({ 
      referral: updated,
      message: 'Referral accepted. Patient can now be transferred.'
    });
  } catch (err) {
    return next(err);
  }
}

/**
 * Reject a referral (receiving hospital).
 * Only the TO hospital can reject.
 * Status: pending → rejected
 */
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

/**
 * Complete a referral by admitting the patient at the receiving hospital.
 * Only the TO hospital can complete.
 * Status: accepted → completed
 * This also creates an admission at the receiving hospital.
 */
async function completeReferral(req, res, next) {
  try {
    const referralId = req.params.id;
    const { ward_id } = req.body;
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;

    if (!ward_id) {
      return res.status(400).json({ error: 'ward_id is required to admit the patient' });
    }

    // Fetch the referral
    const { data: referral, error: fetchError } = await db
      .from('referrals')
      .select(`
        id, status, to_hospital_id, from_hospital_id, patient_id,
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

    // Verify ward belongs to the receiving hospital
    const { data: ward, error: wardError } = await db
      .from('wards')
      .select('id, hospital_id, available_beds')
      .eq('id', ward_id)
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

    if (ward.available_beds <= 0) {
      return res.status(409).json({ error: 'No beds available in the selected ward' });
    }

    // Create admission at receiving hospital using RPC
    const { data: admissionResult, error: admissionError } = await db.rpc('create_admission', {
      p_actor_hospital_id: req.auth.hospitalId,
      p_ward_id: ward_id,
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
      referral: updatedReferral,
      admission: admissionResult?.admission,
      ward: admissionResult?.ward,
      message: 'Referral completed. Patient has been admitted.'
    });
  } catch (err) {
    return next(err);
  }
}

/**
 * Cancel a referral (sender hospital).
 * Only the FROM hospital can cancel.
 * Status: pending|accepted|rejected → cancelled
 */
async function cancelReferral(req, res, next) {
  try {
    const referralId = req.params.id;
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;

    // Fetch the referral first
    const { data: referral, error: fetchError } = await db
      .from('referrals')
      .select('id, status, from_hospital_id')
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

    // Update status to cancelled
    const { data: updated, error: updateError } = await db
      .from('referrals')
      .update({ status: 'cancelled' })
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
      oldData: { status: referral.status },
      newData: { status: 'cancelled' }
    });

    return res.status(200).json({ 
      referral: updated,
      message: 'Referral cancelled.'
    });
  } catch (err) {
    return next(err);
  }
}

export { createReferral, listReferrals, getReferral, acceptReferral, rejectReferral, completeReferral, cancelReferral };

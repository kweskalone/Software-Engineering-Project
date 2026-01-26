import { getSupabaseClients } from '../config/supabaseClient.js';
import { parsePagination, buildPaginationMeta } from '../utils/pagination.js';

// Search for available beds across ALL hospitals
async function searchBeds(req, res, next) {
  try {
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;
    const { page, limit, offset } = parsePagination(req.query);
    const { region, district, ward_type, min_beds } = req.query;

    const minBeds = parseInt(min_beds, 10) || 1;

    // Build query for wards with available beds, joined with hospital info
    let query = db
      .from('wards')
      .select(`
        id,
        name,
        type,
        total_beds,
        available_beds,
        hospital_id,
        hospitals (
          id,
          name,
          region,
          district
        )
      `)
      .gte('available_beds', minBeds)
      .order('available_beds', { ascending: false });

    // We need to filter by hospital fields, so we'll filter after fetch
    // or use a more complex approach. For simplicity, fetch and filter.

    const { data: allWards, error } = await query;

    if (error) {
      error.statusCode = 500;
      error.publicMessage = 'Failed to search beds';
      throw error;
    }

    // Filter by region/district/ward_type
    let filtered = allWards || [];

    if (region) {
      filtered = filtered.filter(w => 
        w.hospitals?.region?.toLowerCase() === region.toLowerCase()
      );
    }

    if (district) {
      filtered = filtered.filter(w => 
        w.hospitals?.district?.toLowerCase() === district.toLowerCase()
      );
    }

    if (ward_type) {
      filtered = filtered.filter(w => 
        w.type?.toLowerCase() === ward_type.toLowerCase()
      );
    }

    // Calculate totals before pagination
    const totalCount = filtered.length;
    const totalAvailableBeds = filtered.reduce((sum, w) => sum + (w.available_beds || 0), 0);

    // Apply pagination
    const paginated = filtered.slice(offset, offset + limit);

    // Transform response for cleaner output
    const results = paginated.map(w => ({
      ward_id: w.id,
      ward_name: w.name,
      ward_type: w.type,
      total_beds: w.total_beds,
      available_beds: w.available_beds,
      hospital: {
        id: w.hospitals?.id,
        name: w.hospitals?.name,
        region: w.hospitals?.region,
        district: w.hospitals?.district
      }
    }));

    return res.status(200).json({
      results,
      summary: {
        total_wards_with_beds: totalCount,
        total_available_beds: totalAvailableBeds
      },
      filters: {
        region: region || null,
        district: district || null,
        ward_type: ward_type || null,
        min_beds: minBeds
      },
      pagination: buildPaginationMeta({ page, limit, totalCount })
    });
  } catch (err) {
    return next(err);
  }
}

// Public endpoint - Search for available beds (no authentication required)
async function searchBedsPublic(req, res, next) {
  try {
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;
    const { page, limit, offset } = parsePagination(req.query);
    const { region, ward_type } = req.query;

    // Build query for wards with available beds, joined with hospital info
    let query = db
      .from('wards')
      .select(`
        id,
        name,
        type,
        total_beds,
        available_beds,
        hospital_id,
        hospitals (
          id,
          name,
          region,
          district
        )
      `)
      .gte('available_beds', 1)
      .order('available_beds', { ascending: false });

    const { data: allWards, error } = await query;

    if (error) {
      error.statusCode = 500;
      error.publicMessage = 'Failed to search beds';
      throw error;
    }

    // Filter by region/ward_type
    let filtered = allWards || [];

    if (region) {
      filtered = filtered.filter(w => 
        w.hospitals?.region?.toLowerCase() === region.toLowerCase()
      );
    }

    if (ward_type) {
      filtered = filtered.filter(w => 
        w.type?.toLowerCase() === ward_type.toLowerCase()
      );
    }

    // Calculate totals
    const totalCount = filtered.length;
    const totalAvailableBeds = filtered.reduce((sum, w) => sum + (w.available_beds || 0), 0);

    // Apply pagination
    const paginated = filtered.slice(offset, offset + limit);

    // Transform response (exclude sensitive info for public)
    const results = paginated.map(w => ({
      ward_id: w.id,
      ward_name: w.name,
      ward_type: w.type,
      total_beds: w.total_beds,
      available_beds: w.available_beds,
      hospital: {
        id: w.hospitals?.id,
        name: w.hospitals?.name,
        region: w.hospitals?.region,
        district: w.hospitals?.district
      }
    }));

    return res.status(200).json({
      results,
      summary: {
        total_wards_with_beds: totalCount,
        total_available_beds: totalAvailableBeds
      },
      pagination: buildPaginationMeta({ page, limit, totalCount })
    });
  } catch (err) {
    return next(err);
  }
}

// Reserve a bed for emergency
async function reserveBed(req, res, next) {
  try {
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;
    const { ward_id, duration_minutes, referral_id, notes, priority } = req.body;
    const authUserId = req.auth.user?.id;
    const userName = req.auth.user?.user_metadata?.first_name 
      ? `${req.auth.user.user_metadata.first_name} ${req.auth.user.user_metadata.last_name || ''}`
      : req.auth.user?.email || 'Unknown';

    if (!ward_id) {
      return res.status(400).json({ error: 'ward_id is required' });
    }

    // Check if ward exists and has available beds
    const { data: ward, error: wardError } = await db
      .from('wards')
      .select('id, name, available_beds, hospital_id, hospitals(id, name, region)')
      .eq('id', ward_id)
      .single();

    if (wardError || !ward) {
      return res.status(404).json({ error: 'Ward not found' });
    }

    if (ward.available_beds <= 0) {
      return res.status(409).json({ error: 'No beds available in this ward' });
    }

    // Calculate expiration time
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + (duration_minutes || 60));

    // Build insert data - supports both old schema (referral_id required) 
    // and new schema (referral_id optional with reservation_type)
    const insertData = {
      hospital_id: ward.hospital_id,
      ward_id,
      reserved_by_auth_user_id: authUserId,
      expires_at: expiresAt.toISOString(),
      status: 'active'
    };

    // Add referral_id if provided
    if (referral_id) {
      insertData.referral_id = referral_id;
    }

    // Add optional columns (will be ignored if they don't exist in schema)
    // These are added by 2026-01-24 migration
    insertData.reservation_type = referral_id ? 'referral' : 'emergency';
    insertData.reserved_by_name = userName;
    insertData.priority = priority || 'high';
    insertData.notes = notes || null;

    // Create reservation record
    const { data: reservation, error: reservationError } = await db
      .from('bed_reservations')
      .insert(insertData)
      .select()
      .single();

    if (reservationError) {
      // If table doesn't exist, return a friendly message
      if (reservationError.code === '42P01') {
        return res.status(501).json({ 
          error: 'Bed reservation feature is not yet configured. Please run migrations.' 
        });
      }
      reservationError.statusCode = 500;
      reservationError.publicMessage = 'Failed to create reservation';
      throw reservationError;
    }

    // Decrement available beds
    const { error: updateError } = await db
      .from('wards')
      .update({ available_beds: ward.available_beds - 1 })
      .eq('id', ward_id);

    if (updateError) {
      // Rollback reservation
      await db.from('bed_reservations').delete().eq('id', reservation.id);
      updateError.statusCode = 500;
      updateError.publicMessage = 'Failed to update bed availability';
      throw updateError;
    }

    return res.status(201).json({
      message: 'Bed reserved successfully',
      reservation: {
        ...reservation,
        ward: {
          id: ward.id,
          name: ward.name,
          hospital: ward.hospitals
        }
      }
    });
  } catch (err) {
    return next(err);
  }
}

// Get all reserved beds
async function getReservedBeds(req, res, next) {
  try {
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;
    const { region, status } = req.query;

    let query = db
      .from('bed_reservations')
      .select(`
        id,
        referral_id,
        hospital_id,
        ward_id,
        reserved_by_auth_user_id,
        reserved_by_name,
        reservation_type,
        priority,
        notes,
        reserved_at,
        expires_at,
        status,
        completed_at,
        cancelled_at,
        created_at,
        wards:ward_id (
          id,
          name,
          ward_type
        ),
        hospitals:hospital_id (
          id,
          name,
          region
        )
      `)
      .in('status', ['active', 'reserved'])
      .order('created_at', { ascending: false });

    const { data: reservations, error } = await query;

    if (error) {
      // If table doesn't exist, return empty array
      if (error.code === '42P01') {
        return res.status(200).json({ reservations: [] });
      }
      error.statusCode = 500;
      error.publicMessage = 'Failed to fetch reservations';
      throw error;
    }

    // Filter by region
    let filtered = reservations || [];

    if (region) {
      filtered = filtered.filter(r => 
        r.hospitals?.region?.toLowerCase() === region.toLowerCase()
      );
    }

    // Transform response
    const result = filtered.map(r => ({
      id: r.id,
      referral_id: r.referral_id,
      hospital_id: r.hospital_id,
      ward_id: r.ward_id,
      reserved_by_auth_user_id: r.reserved_by_auth_user_id,
      reserved_by_name: r.reserved_by_name,
      reservation_type: r.reservation_type,
      priority: r.priority,
      notes: r.notes,
      reserved_at: r.reserved_at || r.created_at,
      expires_at: r.expires_at,
      status: r.status,
      completed_at: r.completed_at,
      cancelled_at: r.cancelled_at,
      created_at: r.created_at,
      ward: {
        id: r.wards?.id,
        name: r.wards?.name,
        ward_type: r.wards?.ward_type
      },
      hospital: r.hospitals
    }));

    return res.status(200).json({ reservations: result });
  } catch (err) {
    return next(err);
  }
}

// Complete a reservation (convert to admission)
async function completeReservation(req, res, next) {
  try {
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;
    const { reservationId } = req.params;
    const { patient } = req.body;
    const userId = req.user.id;

    // Get reservation
    const { data: reservation, error: reservationError } = await db
      .from('bed_reservations')
      .select('*, wards(id, name, hospital_id)')
      .eq('id', reservationId)
      .eq('status', 'reserved')
      .single();

    if (reservationError || !reservation) {
      return res.status(404).json({ error: 'Reservation not found or already completed' });
    }

    // Create patient
    const { data: patientData, error: patientError } = await db
      .from('patients')
      .insert({
        full_name: patient.full_name,
        sex: patient.sex || 'M',
        date_of_birth: patient.date_of_birth || null,
        phone: patient.phone || null,
        national_id: patient.national_id || null
      })
      .select()
      .single();

    if (patientError) {
      patientError.statusCode = 500;
      patientError.publicMessage = 'Failed to create patient';
      throw patientError;
    }

    // Create admission
    const { data: admission, error: admissionError } = await db
      .from('admissions')
      .insert({
        patient_id: patientData.id,
        hospital_id: reservation.wards.hospital_id,
        ward_id: reservation.ward_id,
        status: 'admitted',
        admitted_by_auth_user_id: userId
      })
      .select()
      .single();

    if (admissionError) {
      admissionError.statusCode = 500;
      admissionError.publicMessage = 'Failed to create admission';
      throw admissionError;
    }

    // Update reservation status
    await db
      .from('bed_reservations')
      .update({ status: 'completed' })
      .eq('id', reservationId);

    return res.status(200).json({
      message: 'Reservation completed and patient admitted',
      admission,
      patient: patientData
    });
  } catch (err) {
    return next(err);
  }
}

// Cancel a reservation
async function cancelReservation(req, res, next) {
  try {
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;
    const { reservationId } = req.params;

    // Get reservation
    const { data: reservation, error: reservationError } = await db
      .from('bed_reservations')
      .select('*, wards(id, available_beds)')
      .eq('id', reservationId)
      .eq('status', 'reserved')
      .single();

    if (reservationError || !reservation) {
      return res.status(404).json({ error: 'Reservation not found or already cancelled' });
    }

    // Update reservation status
    const { error: updateError } = await db
      .from('bed_reservations')
      .update({ status: 'cancelled' })
      .eq('id', reservationId);

    if (updateError) {
      updateError.statusCode = 500;
      updateError.publicMessage = 'Failed to cancel reservation';
      throw updateError;
    }

    // Increment available beds
    await db
      .from('wards')
      .update({ available_beds: reservation.wards.available_beds + 1 })
      .eq('id', reservation.ward_id);

    return res.status(200).json({
      message: 'Reservation cancelled successfully'
    });
  } catch (err) {
    return next(err);
  }
}

export { 
  searchBeds, 
  searchBedsPublic,
  reserveBed,
  getReservedBeds,
  completeReservation,
  cancelReservation
};

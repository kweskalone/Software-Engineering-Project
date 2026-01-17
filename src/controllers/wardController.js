import { getSupabaseClients } from '../config/supabaseClient.js';
import { logAudit } from '../services/auditService.js';

async function createWard(req, res, next) {
  try {
    const { name, type, total_beds, hospital_id } = req.body || {};

    if (!name || !type || total_beds === undefined) {
      return res.status(400).json({ error: 'name, type, total_beds are required' });
    }

    const totalBeds = Number(total_beds);
    if (!Number.isInteger(totalBeds) || totalBeds < 0) {
      return res.status(400).json({ error: 'total_beds must be a non-negative integer' });
    }

    const hospitalId = hospital_id || req.auth?.hospitalId;
    if (!hospitalId) {
      return res.status(400).json({ error: 'hospital_id is required' });
    }

    // Simple scoping: admin can create wards for their own hospital.
    if (req.auth?.hospitalId && req.auth.hospitalId !== hospitalId) {
      return res.status(403).json({ error: 'You can only create wards for your own hospital' });
    }

    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;

    const { data, error } = await db
      .from('wards')
      .insert({
        hospital_id: hospitalId,
        name,
        type,
        total_beds: totalBeds,
        available_beds: totalBeds
      })
      .select('id, hospital_id, name, type, total_beds, available_beds, created_at')
      .single();

    if (error) {
      error.statusCode = 500;
      error.publicMessage = 'Failed to create ward';
      throw error;
    }

    await logAudit({
      actor: req.auth,
      action: 'ward.create',
      tableName: 'wards',
      recordId: data?.id || null,
      newData: data
    });

    return res.status(201).json({ ward: data });
  } catch (err) {
    return next(err);
  }
}

async function getWardAvailability(req, res, next) {
  try {
    const wardId = req.params.id;

    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;

    const { data, error } = await db
      .from('wards')
      .select('id, name, type, total_beds, available_beds, hospital_id')
      .eq('id', wardId)
      .single();

    if (error) {
      if (error.code === 'PGRST116') return res.status(404).json({ error: 'Ward not found' });
      error.statusCode = 500;
      error.publicMessage = 'Failed to load ward';
      throw error;
    }

    return res.status(200).json({ ward: data });
  } catch (err) {
    return next(err);
  }
}

async function updateWardCapacity(req, res, next) {
  try {
    const wardId = req.params.id;
    const { total_beds } = req.body || {};

    if (total_beds === undefined) {
      return res.status(400).json({ error: 'total_beds is required' });
    }

    const totalBeds = Number(total_beds);
    if (!Number.isInteger(totalBeds) || totalBeds < 0) {
      return res.status(400).json({ error: 'total_beds must be a non-negative integer' });
    }

    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;

    // Atomic rule: new total must be >= currently occupied beds.
    const { data, error } = await db.rpc('update_ward_capacity', {
      p_actor_hospital_id: req.auth.hospitalId,
      p_ward_id: wardId,
      p_new_total_beds: totalBeds,
      p_actor_auth_user_id: req.auth.user.id
    });

    if (error) {
      const msg = (error.message || '').toString();
      if (msg.includes('WARD_NOT_FOUND')) return res.status(404).json({ error: 'Ward not found' });
      if (msg.includes('WARD_HOSPITAL_MISMATCH')) return res.status(403).json({ error: 'Ward does not belong to your hospital' });
      if (msg.includes('CAPACITY_BELOW_OCCUPIED')) {
        return res.status(409).json({ error: 'New total_beds cannot be less than occupied beds' });
      }
      error.statusCode = 500;
      error.publicMessage = 'Failed to update ward capacity';
      throw error;
    }

    await logAudit({
      actor: req.auth,
      action: 'ward.capacity_update',
      tableName: 'wards',
      recordId: data?.ward?.id || null,
      newData: data?.ward || null
    });

    return res.status(200).json(data);
  } catch (err) {
    return next(err);
  }
}

export { createWard, getWardAvailability, updateWardCapacity };

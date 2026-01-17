import { getSupabaseClients } from '../config/supabaseClient.js';
import { logAudit } from './auditService.js';

const ALLOWED_ROLES = new Set(['admin', 'doctor', 'nurse']);

async function createUserWithProfile({ actor, email, password, role, hospitalId, staffId }) {
  if (actor?.role !== 'admin') {
    const err = new Error('Forbidden');
    err.statusCode = 403;
    err.publicMessage = 'Forbidden';
    throw err;
  }

  if (!ALLOWED_ROLES.has(role)) {
    const err = new Error('Invalid role');
    err.statusCode = 400;
    err.publicMessage = 'role must be one of admin, doctor, nurse';
    throw err;
  }

  const { supabaseService } = getSupabaseClients();
  if (!supabaseService) {
    const err = new Error('Missing SUPABASE_SERVICE_ROLE_KEY');
    err.statusCode = 500;
    err.publicMessage = 'Server is missing service role key for user provisioning';
    throw err;
  }

  // 1) Create Supabase Auth user
  const { data: created, error: createError } = await supabaseService.auth.admin.createUser({
    email,
    password,
    email_confirm: true
  });

  if (createError || !created?.user) {
    const err = createError || new Error('Failed to create auth user');
    err.statusCode = 500;
    err.publicMessage = 'Failed to create user account';
    throw err;
  }

  const authUserId = created.user.id;

  try {
    // 2) Provision app-level profile (public.users)
    const { data: profile, error: profileError } = await supabaseService
      .from('users')
      .insert({
        auth_user_id: authUserId,
        staff_id: staffId,
        role,
        hospital_id: hospitalId
      })
      .select('id, auth_user_id, staff_id, role, hospital_id, created_at')
      .single();

    if (profileError) {
      const err = profileError;
      err.statusCode = 500;
      err.publicMessage = 'Failed to provision user profile';
      throw err;
    }

    await logAudit({
      actor,
      action: 'user.create',
      tableName: 'users',
      recordId: profile?.id || null,
      newData: profile
    });

    return {
      auth_user: {
        id: authUserId,
        email: created.user.email
      },
      profile
    };
  } catch (e) {
    // Best-effort cleanup: if profile insert fails, remove auth user
    await supabaseService.auth.admin.deleteUser(authUserId);
    throw e;
  }
}

export { createUserWithProfile };

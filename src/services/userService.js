import { getSupabaseClients } from '../config/supabaseClient.js';
import { logAudit } from './auditService.js';

const ALLOWED_ROLES = new Set(['admin', 'doctor', 'nurse']);

/**
 * List all users with pagination (admin only)
 */
async function listUsers({ actor, page = 1, limit = 20, role, hospitalId }) {
  if (actor?.role !== 'admin') {
    const err = new Error('Forbidden');
    err.statusCode = 403;
    err.publicMessage = 'Forbidden';
    throw err;
  }

  const { supabaseService } = getSupabaseClients();
  if (!supabaseService) {
    const err = new Error('Missing SUPABASE_SERVICE_ROLE_KEY');
    err.statusCode = 500;
    err.publicMessage = 'Server configuration error';
    throw err;
  }

  const offset = (page - 1) * limit;

  let query = supabaseService
    .from('users')
    .select(`
      id,
      auth_user_id,
      staff_id,
      role,
      hospital_id,
      created_at,
      hospitals (
        id,
        name
      )
    `, { count: 'exact' });

  if (role) {
    query = query.eq('role', role);
  }

  if (hospitalId) {
    query = query.eq('hospital_id', hospitalId);
  }

  query = query.order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  const { data: users, error, count } = await query;

  if (error) {
    const err = error;
    err.statusCode = 500;
    err.publicMessage = 'Failed to fetch users';
    throw err;
  }

  // Fetch auth emails for each user
  const usersWithEmail = await Promise.all(
    users.map(async (user) => {
      try {
        const { data: authData } = await supabaseService.auth.admin.getUserById(user.auth_user_id);
        return {
          ...user,
          email: authData?.user?.email || null,
          first_name: authData?.user?.user_metadata?.first_name || null,
          last_name: authData?.user?.user_metadata?.last_name || null,
        };
      } catch {
        return { ...user, email: null };
      }
    })
  );

  return {
    success: true,
    data: usersWithEmail,
    pagination: {
      page,
      limit,
      total: count || 0,
      totalPages: Math.ceil((count || 0) / limit),
    },
  };
}

/**
 * Get a single user by ID (admin only)
 */
async function getUserById({ actor, userId }) {
  if (actor?.role !== 'admin') {
    const err = new Error('Forbidden');
    err.statusCode = 403;
    err.publicMessage = 'Forbidden';
    throw err;
  }

  const { supabaseService } = getSupabaseClients();

  const { data: user, error } = await supabaseService
    .from('users')
    .select(`
      id,
      auth_user_id,
      staff_id,
      role,
      hospital_id,
      created_at,
      hospitals (
        id,
        name
      )
    `)
    .eq('id', userId)
    .single();

  if (error || !user) {
    const err = new Error('User not found');
    err.statusCode = 404;
    err.publicMessage = 'User not found';
    throw err;
  }

  // Get email from auth
  try {
    const { data: authData } = await supabaseService.auth.admin.getUserById(user.auth_user_id);
    user.email = authData?.user?.email || null;
    user.first_name = authData?.user?.user_metadata?.first_name || null;
    user.last_name = authData?.user?.user_metadata?.last_name || null;
  } catch {
    user.email = null;
  }

  return user;
}

/**
 * Update a user (admin only)
 */
async function updateUser({ actor, userId, updates }) {
  if (actor?.role !== 'admin') {
    const err = new Error('Forbidden');
    err.statusCode = 403;
    err.publicMessage = 'Forbidden';
    throw err;
  }

  const { supabaseService } = getSupabaseClients();

  // Get current user first
  const { data: currentUser, error: fetchError } = await supabaseService
    .from('users')
    .select('*')
    .eq('id', userId)
    .single();

  if (fetchError || !currentUser) {
    const err = new Error('User not found');
    err.statusCode = 404;
    err.publicMessage = 'User not found';
    throw err;
  }

  // Update profile fields
  const profileUpdates = {};
  if (updates.role && ALLOWED_ROLES.has(updates.role)) {
    profileUpdates.role = updates.role;
  }
  if (updates.hospital_id) {
    profileUpdates.hospital_id = updates.hospital_id;
  }
  if (updates.staff_id) {
    profileUpdates.staff_id = updates.staff_id;
  }

  if (Object.keys(profileUpdates).length > 0) {
    const { error: updateError } = await supabaseService
      .from('users')
      .update(profileUpdates)
      .eq('id', userId);

    if (updateError) {
      const err = updateError;
      err.statusCode = 500;
      err.publicMessage = 'Failed to update user';
      throw err;
    }
  }

  // Update auth user if email/password provided
  if (updates.email || updates.password || updates.first_name || updates.last_name) {
    const authUpdates = {};
    if (updates.email) authUpdates.email = updates.email;
    if (updates.password) authUpdates.password = updates.password;
    if (updates.first_name || updates.last_name) {
      authUpdates.user_metadata = {
        first_name: updates.first_name,
        last_name: updates.last_name,
      };
    }

    const { error: authError } = await supabaseService.auth.admin.updateUserById(
      currentUser.auth_user_id,
      authUpdates
    );

    if (authError) {
      const err = authError;
      err.statusCode = 500;
      err.publicMessage = 'Failed to update user credentials';
      throw err;
    }
  }

  await logAudit({
    actor,
    action: 'user.update',
    tableName: 'users',
    recordId: userId,
    oldData: currentUser,
    newData: { ...currentUser, ...profileUpdates },
  });

  return getUserById({ actor, userId });
}

/**
 * Delete/deactivate a user (admin only)
 */
async function deleteUser({ actor, userId }) {
  if (actor?.role !== 'admin') {
    const err = new Error('Forbidden');
    err.statusCode = 403;
    err.publicMessage = 'Forbidden';
    throw err;
  }

  const { supabaseService } = getSupabaseClients();

  // Get user first
  const { data: user, error: fetchError } = await supabaseService
    .from('users')
    .select('*')
    .eq('id', userId)
    .single();

  if (fetchError || !user) {
    const err = new Error('User not found');
    err.statusCode = 404;
    err.publicMessage = 'User not found';
    throw err;
  }

  // Delete from auth
  const { error: authError } = await supabaseService.auth.admin.deleteUser(user.auth_user_id);

  if (authError) {
    const err = authError;
    err.statusCode = 500;
    err.publicMessage = 'Failed to delete user';
    throw err;
  }

  // The profile should be deleted via cascade or we can delete explicitly
  await supabaseService.from('users').delete().eq('id', userId);

  await logAudit({
    actor,
    action: 'user.delete',
    tableName: 'users',
    recordId: userId,
    oldData: user,
  });

  return { success: true, message: 'User deleted successfully' };
}

async function createUserWithProfile({ actor, email, password, role, hospitalId, staffId, firstName, lastName }) {
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
    email_confirm: true,
    user_metadata: {
      first_name: firstName,
      last_name: lastName,
    },
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

export { createUserWithProfile, listUsers, getUserById, updateUser, deleteUser };

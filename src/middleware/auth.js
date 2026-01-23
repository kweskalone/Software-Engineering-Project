import { getSupabaseClients } from '../config/supabaseClient.js';

function parseBearerToken(req) {
  const authHeader = req.headers.authorization || '';
  const [scheme, token] = authHeader.split(' ');
  if (scheme !== 'Bearer' || !token) return null;
  return token;
}

// Auth middleware: validates Supabase JWT and loads user role
async function requireAuth(req, res, next) {
  try {
    const token = parseBearerToken(req);
    if (!token) return res.status(401).json({ error: 'Missing Bearer token' });

    const { supabaseAnon, supabaseService } = getSupabaseClients();

    const { data: userData, error: userError } = await supabaseAnon.auth.getUser(token);
    if (userError || !userData?.user) {
      return res.status(401).json({ error: 'Invalid or expired token' });
    }

    // Use service role if available to read profile/role (simpler for undergraduate projects)
    const db = supabaseService || supabaseAnon;

    const { data: profile, error: profileError } = await db
      .from('users')
      .select('id, role, hospital_id, staff_id')
      .eq('auth_user_id', userData.user.id)
      .maybeSingle();

    if (profileError) {
      profileError.statusCode = 500;
      profileError.publicMessage = 'Failed to load user profile';
      throw profileError;
    }

    if (!profile) {
      return res.status(403).json({ error: 'User profile not provisioned' });
    }

    req.auth = {
      token,
      user: userData.user,
      userId: profile.id,
      role: profile.role,
      hospitalId: profile.hospital_id,
      staffId: profile.staff_id
    };

    return next();
  } catch (err) {
    return next(err);
  }
}

export { requireAuth };

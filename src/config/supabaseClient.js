import { createClient } from '@supabase/supabase-js';

function getSupabaseClients() {
  const supabaseUrl = process.env.SUPABASE_URL;
  const anonKey = process.env.SUPABASE_ANON_KEY;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!supabaseUrl || !anonKey) {
    throw new Error('Missing SUPABASE_URL or SUPABASE_ANON_KEY in environment');
  }

  const supabaseAnon = createClient(supabaseUrl, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false }
  });

  const supabaseService = serviceRoleKey
    ? createClient(supabaseUrl, serviceRoleKey, {
        auth: { persistSession: false, autoRefreshToken: false }
      })
    : null;

  return { supabaseAnon, supabaseService };
}

// Convenience getter for service client (or anon if service not available)
function getSupabase() {
  const { supabaseService, supabaseAnon } = getSupabaseClients();
  return supabaseService || supabaseAnon;
}

// Create a lazy-loaded singleton for direct imports
let _supabase = null;
const supabase = new Proxy({}, {
  get(target, prop) {
    if (!_supabase) {
      _supabase = getSupabase();
    }
    return _supabase[prop];
  }
});

export { getSupabaseClients, getSupabase, supabase };

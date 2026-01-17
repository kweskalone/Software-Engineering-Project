import { getSupabaseClients } from '../config/supabaseClient.js';

async function logAudit({
  actor,
  action,
  tableName,
  recordId,
  oldData = null,
  newData = null
}) {
  const { supabaseService, supabaseAnon } = getSupabaseClients();
  const db = supabaseService || supabaseAnon;

  const { error } = await db.from('audit_logs').insert({
    action,
    table_name: tableName,
    record_id: recordId,
    actor_auth_user_id: actor?.user?.id || null,
    old_data: oldData,
    new_data: newData
  });

  if (error) {
    // Audit failure should not break the main flow
    console.error('Audit log failed', error);
  }
}

export { logAudit };

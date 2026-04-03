// ─────────────────────────────────────────────────────────────
//  rsvp.js  — Supabase operations for the `rsvps` table
// ─────────────────────────────────────────────────────────────
import sb from './supabaseClient.js';

/**
 * Submit a new RSVP.
 * Fields: first_name, last_name, phone, email, event_id
 */
export async function submitRsvp({ first_name, last_name, phone, email, event_id }) {
  const { data, error } = await sb
    .from('rsvps')
    .insert([{ first_name, last_name, phone, email, event_id }])
    .select()
    .single();

  if (error) { console.error('submitRsvp:', error.message); return { data: null, error }; }
  return { data, error: null };
}

/**
 * Fetch RSVP count for a specific event_id.
 * Returns a number.
 */
export async function fetchRsvpCount(event_id) {
  const { count, error } = await sb
    .from('rsvps')
    .select('*', { count: 'exact', head: true })
    .eq('event_id', event_id);

  if (error) { console.error('fetchRsvpCount:', error.message); return 0; }
  return count ?? 0;
}

/**
 * Fetch RSVP counts for multiple event IDs at once.
 * Returns an object: { [event_id]: count }
 */
export async function fetchRsvpCounts(eventIds) {
  if (!eventIds || eventIds.length === 0) return {};

  const { data, error } = await sb
    .from('rsvps')
    .select('event_id')
    .in('event_id', eventIds);

  if (error) { console.error('fetchRsvpCounts:', error.message); return {}; }

  const counts = {};
  (data ?? []).forEach(row => {
    counts[row.event_id] = (counts[row.event_id] ?? 0) + 1;
  });
  return counts;
}

/**
 * Fetch all RSVPs with their related event info.
 * Admin-only — relies on RLS allowing authenticated reads.
 */
export async function fetchAllRsvps() {
  const { data, error } = await sb
    .from('rsvps')
    .select(`
      id,
      first_name,
      last_name,
      phone,
      email,
      created_at,
      event_id,
      events ( id, date, title, title_es, icon )
    `)
    .order('created_at', { ascending: false });

  if (error) { console.error('fetchAllRsvps:', error.message); return []; }
  return data ?? [];
}

/**
 * Fetch RSVPs for a specific event_id.
 * Admin-only.
 */
export async function fetchRsvpsForEvent(event_id) {
  const { data, error } = await sb
    .from('rsvps')
    .select('*')
    .eq('event_id', event_id)
    .order('created_at', { ascending: true });

  if (error) { console.error('fetchRsvpsForEvent:', error.message); return []; }
  return data ?? [];
}

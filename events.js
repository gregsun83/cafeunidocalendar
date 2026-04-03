// ─────────────────────────────────────────────────────────────
//  events.js  — Supabase CRUD for the `events` table
// ─────────────────────────────────────────────────────────────
import sb from './supabaseClient.js';

/**
 * Fetch all events ordered by date ascending.
 * Returns an array of event row objects.
 */
export async function fetchEvents() {
  const { data, error } = await sb
    .from('events')
    .select('*')
    .order('date', { ascending: true });

  if (error) { console.error('fetchEvents:', error.message); return []; }
  return data ?? [];
}

/**
 * Fetch events for a specific year-month range (YYYY-MM).
 * e.g. fetchEventsForMonth('2026-04')
 */
export async function fetchEventsForMonth(yearMonth) {
  const start = `${yearMonth}-01`;
  const end   = `${yearMonth}-31`;
  const { data, error } = await sb
    .from('events')
    .select('*')
    .gte('date', start)
    .lte('date', end)
    .order('date', { ascending: true });

  if (error) { console.error('fetchEventsForMonth:', error.message); return []; }
  return data ?? [];
}

/**
 * Insert a new event.
 * Required fields: date (YYYY-MM-DD), title, title_es,
 *   description, description_es, icon, color
 * Optional: subtitle, subtitle_es
 */
export async function createEvent(eventData) {
  const { data, error } = await sb
    .from('events')
    .insert([eventData])
    .select()
    .single();

  if (error) { console.error('createEvent:', error.message); return { data: null, error }; }
  return { data, error: null };
}

/**
 * Update an existing event by id.
 */
export async function updateEvent(id, updates) {
  const { data, error } = await sb
    .from('events')
    .update(updates)
    .eq('id', id)
    .select()
    .single();

  if (error) { console.error('updateEvent:', error.message); return { data: null, error }; }
  return { data, error: null };
}

/**
 * Delete an event by id.
 * Note: RLS should ensure only admins can delete.
 */
export async function deleteEvent(id) {
  const { error } = await sb
    .from('events')
    .delete()
    .eq('id', id);

  if (error) { console.error('deleteEvent:', error.message); return { error }; }
  return { error: null };
}

/**
 * Convert a Supabase events array into the keyed object
 * the calendar renderer expects:
 *   { "2026-04-03": { title, titleES, ... }, ... }
 */
export function eventsArrayToMap(rows) {
  const map = {};
  rows.forEach(row => {
    map[row.date] = {
      id:            row.id,
      title:         row.title,
      titleES:       row.title_es,
      subtitle:      row.subtitle  ?? '',
      subtitleES:    row.subtitle_es ?? '',
      description:   row.description,
      descriptionES: row.description_es,
      icon:          row.icon  ?? '📅',
      color:         row.color ?? 'caramel',
    };
  });
  return map;
}

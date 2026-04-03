// ─────────────────────────────────────────────────────────────
//  supabaseClient.js
//  ↳ Replace the two values below with your Supabase project's
//    URL and anon (public) key.
//    NEVER paste your service_role key here.
// ─────────────────────────────────────────────────────────────

const SUPABASE_URL  = 'https://YOUR_PROJECT_ID.supabase.co';
const SUPABASE_ANON = 'YOUR_ANON_PUBLIC_KEY';

// We load the Supabase JS client from CDN (see HTML files).
// This module just exports the initialised singleton.
const { createClient } = supabase;
const sb = createClient(SUPABASE_URL, SUPABASE_ANON);

export default sb;

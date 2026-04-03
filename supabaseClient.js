// ─────────────────────────────────────────
//  supabaseClient.js
// ─────────────────────────────────────────

const SUPABASE_URL = 'https://xmjnmlfekfiwtwhhzgko.supabase.co';

const SUPABASE_ANON = 'sb_publishable_2mWaIqWkH84TFNnIlER61A_QGPVIhVK';

const { createClient } = supabase;
const sb = createClient(SUPABASE_URL, SUPABASE_ANON);

export default sb;

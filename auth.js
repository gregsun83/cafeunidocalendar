// ─────────────────────────────────────────────────────────────
//  auth.js  — Admin authentication helpers
// ─────────────────────────────────────────────────────────────
import sb from './supabaseClient.js';

/** Returns the current session, or null if not logged in. */
export async function getSession() {
  const { data } = await sb.auth.getSession();
  return data.session;
}

/** Sign in with email + password. Returns { session, error }. */
export async function signIn(email, password) {
  const { data, error } = await sb.auth.signInWithPassword({ email, password });
  return { session: data?.session ?? null, error };
}

/** Sign out the current user. */
export async function signOut() {
  await sb.auth.signOut();
}

/**
 * Call this at the top of admin.html.
 * Redirects to index.html if no active session exists.
 */
export async function requireAuth() {
  const session = await getSession();
  if (!session) {
    window.location.href = 'index.html';
  }
  return session;
}

/**
 * Listen for auth state changes (login / logout).
 * Callback receives (event, session).
 */
export function onAuthChange(callback) {
  sb.auth.onAuthStateChange(callback);
}

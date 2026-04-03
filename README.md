# Café Unido — Setup & Deployment Guide

## Project Structure

```
/project
  index.html           ← Public-facing event calendar
  admin.html           ← Admin dashboard (login-protected)
  supabase_setup.sql   ← Run once in Supabase SQL Editor
  /js
    supabaseClient.js  ← ⚠️ Add your keys here
    auth.js            ← Supabase Auth helpers
    events.js          ← Events CRUD
    rsvp.js            ← RSVP read/write
    admin.js           ← (imported by admin.html inline script)
```

---

## Step 1 — Create a Supabase project

1. Go to https://supabase.com and sign in.
2. Click **New Project**, name it `cafe-unido`.
3. Choose a strong database password. Save it.
4. Wait for the project to provision (~1 min).

---

## Step 2 — Run the database setup

1. In the Supabase sidebar, go to **SQL Editor**.
2. Paste the full contents of `supabase_setup.sql`.
3. Click **Run**.
4. ✅ This creates: `events`, `rsvps`, `event_images` tables with RLS policies.

To seed April 2026 events: uncomment the `INSERT INTO events …` block and run again.

---

## Step 3 — Add your Supabase keys

1. In Supabase sidebar → **Settings → API**.
2. Copy:
   - **Project URL** (looks like `https://abcdefg.supabase.co`)
   - **anon / public key** (long JWT starting with `eyJ…`)
3. Open `js/supabaseClient.js` and replace:
   ```js
   const SUPABASE_URL  = 'https://YOUR_PROJECT_ID.supabase.co';
   const SUPABASE_ANON = 'YOUR_ANON_PUBLIC_KEY';
   ```
   ⚠️ **NEVER** paste your `service_role` key here. Use `anon` only.

---

## Step 4 — Create the first admin user

Supabase Auth handles this securely:

1. In the Supabase sidebar → **Authentication → Users**.
2. Click **Add user** → **Create new user**.
3. Enter an email (e.g. `admin@cafeunido.com`) and a strong password.
4. Click **Create user**.

That's it. Use these credentials to log into `admin.html`.

> **Multiple admins**: Repeat Step 4 for each admin account.
> There is no self-registration — only users you create can log in.

---

## Step 5 — Create the media storage bucket (optional, for future use)

1. In Supabase sidebar → **Storage**.
2. Click **New bucket**.
3. Name: `event-media`, set to **Public**.
4. Click **Save**.

The `event_images` table is already created and ready to be wired up when you build the gallery UI.

---

## Step 6 — Deploy

### Option A — Static hosting (recommended)

Since this is a plain HTML/JS/CSS project, deploy to any static host:

| Host | Command |
|---|---|
| **Netlify** | Drag the project folder to https://app.netlify.com/drop |
| **Vercel** | `vercel --prod` from the project folder |
| **Cloudflare Pages** | Connect GitHub repo, build command: none, output: `/` |
| **GitHub Pages** | Push to a repo, enable Pages on the `main` branch |

> ⚠️ **CORS**: Supabase allows requests from any origin by default. If you want to restrict it, go to **Settings → API → Allowed Origins** and add your domain.

### Option B — Local development

Just open `index.html` and `admin.html` directly in a browser.
Because the JS files use ES modules (`type="module"`), you need a local server:

```bash
# Python
python3 -m http.server 3000

# Node (npx)
npx serve .

# VS Code
Install the "Live Server" extension and click "Go Live"
```

---

## Security notes

- The `anon` key is safe to expose in frontend code — it only grants what RLS allows.
- `service_role` key bypasses RLS entirely. **Never put it in any frontend file.**
- Admin routes are protected by Supabase Auth JWT — unauthenticated users are redirected.
- RLS policies ensure:
  - Anyone can **read** events and **submit** RSVPs.
  - Only authenticated admins can **create/edit/delete** events.
  - Only authenticated admins can **read** RSVP contact details.

---

## Adding events via the Admin dashboard

1. Navigate to `/admin.html`.
2. Log in with your admin credentials.
3. Click the **📅 Events** tab.
4. Click **+ New Event**.
5. Fill in the form and click **Save Event**.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Calendar shows "Loading…" forever | Check your Supabase URL & anon key in `supabaseClient.js` |
| RSVP submit fails | Verify `rsvps` table exists and RLS INSERT policy is active |
| Admin login fails | Confirm the user exists in Supabase Auth → Users |
| CORS error | Add your domain to Supabase → Settings → API → Allowed Origins |
| Module import errors | Serve from a local server (not `file://`) |

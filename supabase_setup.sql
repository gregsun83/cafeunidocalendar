-- ═══════════════════════════════════════════════════════════
--  Café Unido — Supabase Database Setup
--  Run this in your Supabase SQL Editor (project → SQL Editor)
-- ═══════════════════════════════════════════════════════════

-- ─── 1. EVENTS TABLE ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS events (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date           date         NOT NULL,          -- YYYY-MM-DD
  title          text         NOT NULL,
  title_es       text,
  subtitle       text,
  subtitle_es    text,
  description    text         NOT NULL,
  description_es text,
  icon           text         DEFAULT '📅',
  color          text         DEFAULT 'caramel'  -- caramel | bark | espresso
                              CHECK (color IN ('caramel', 'bark', 'espresso')),
  created_at     timestamptz  DEFAULT now(),
  updated_at     timestamptz  DEFAULT now()
);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER events_updated_at
  BEFORE UPDATE ON events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ─── 2. RSVPS TABLE ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS rsvps (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id    uuid         NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  first_name  text         NOT NULL,
  last_name   text         NOT NULL,
  phone       text         NOT NULL,
  email       text         NOT NULL,
  created_at  timestamptz  DEFAULT now()
);

-- Index for fast per-event lookups
CREATE INDEX IF NOT EXISTS rsvps_event_id_idx ON rsvps(event_id);
CREATE INDEX IF NOT EXISTS rsvps_email_idx    ON rsvps(email);

-- ─── 3. EVENT_IMAGES TABLE (future — not UI-wired yet) ────
-- Prepared for image gallery feature.
-- Each event can have many images stored in Supabase Storage.
CREATE TABLE IF NOT EXISTS event_images (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id    uuid         NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  storage_key text         NOT NULL,   -- path inside the storage bucket
  caption     text,
  sort_order  int          DEFAULT 0,
  created_at  timestamptz  DEFAULT now()
);

-- ─── 4. ROW LEVEL SECURITY ────────────────────────────────

-- EVENTS: public read, authenticated write
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can read events"
  ON events FOR SELECT
  USING (true);

CREATE POLICY "Admins can insert events"
  ON events FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Admins can update events"
  ON events FOR UPDATE
  TO authenticated
  USING (true) WITH CHECK (true);

CREATE POLICY "Admins can delete events"
  ON events FOR DELETE
  TO authenticated
  USING (true);


-- RSVPS: anyone can insert; only authenticated (admin) can read
ALTER TABLE rsvps ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can submit RSVPs"
  ON rsvps FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Admins can read all RSVPs"
  ON rsvps FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can delete RSVPs"
  ON rsvps FOR DELETE
  TO authenticated
  USING (true);

-- Allow anon to COUNT rsvps per event (for the public counter)
-- This lets unauthenticated users see rsvp counts on the calendar.
-- If you want to hide counts, remove this policy.
CREATE POLICY "Public can count RSVPs"
  ON rsvps FOR SELECT
  USING (true);

-- NOTE: If you enable the public count policy AND the admin read policy,
-- Supabase will merge them (OR logic). That means the admin policy above
-- is redundant when the public policy also allows SELECT — but it's good
-- to have for clarity when you later restrict public access.


-- EVENT_IMAGES: same as events
ALTER TABLE event_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can read event images"
  ON event_images FOR SELECT USING (true);

CREATE POLICY "Admins can manage event images"
  ON event_images FOR ALL
  TO authenticated
  USING (true) WITH CHECK (true);


-- ─── 5. SAMPLE DATA (optional — remove before production) ──
-- Uncomment to seed April 2026 events matching the original site.

/*
INSERT INTO events (date, title, title_es, description, description_es, icon, color) VALUES
  ('2026-04-03','Game Night: Meet & Play','Noche de Juegos: Conoce y Juega','Board games, card games, and new friends. Bring your A-game — or just show up and learn.','Juegos de mesa, cartas y nuevos amigos. Ven a ganar o simplemente a aprender.','🎲','bark'),
  ('2026-04-04','Themed Trivia Night','Trivia Temática','All 90s everything — music, TV, pop culture, fashion. How well do you remember the decade?','Todo de los 90s — música, televisión, cultura pop y moda. ¿Cuánto recuerdas de esa época?','📼','espresso'),
  ('2026-04-07','Coffee & Connections','Café & Conexiones','Casual networking with rotating conversations. Great for meeting new people in a relaxed setting.','Conversaciones rotativas en un ambiente relajado. Perfecto para conocer gente nueva.','☕','caramel'),
  ('2026-04-10','Singles Night','Noche de Solteros','A fun, low-pressure evening to meet new people. Conversation starters provided.','Una noche divertida y sin presión para conocer personas nuevas.','💛','caramel'),
  ('2026-04-11','Comedy Night','Noche de Comedia','Local comedians bring the laughs — totally clean, totally fun.','Comediantes locales traen las risas — apta para todo público.','😂','bark'),
  ('2026-04-14','Coffee & Connections','Café & Conexiones','Casual networking with rotating conversations.','Conversaciones rotativas en un ambiente relajado.','☕','caramel'),
  ('2026-04-17','Mario Kart Tournament','Torneo de Mario Kart','Blue shells, banana peels, and serious competition. Prizes for the top 3 racers.','Caparazones azules, cáscaras de plátano y competencia seria.','🏎️','espresso'),
  ('2026-04-18','Murder Mystery Night','Noche de Misterio','You''re invited to a dinner party... and someone won''t make it out alive.','Estás invitado a una cena... y alguien no saldrá vivo.','🔍','espresso'),
  ('2026-04-21','Trivia Night','Noche de Trivia','General knowledge, pop culture, and a few curveballs.','Conocimiento general, cultura pop y sorpresas.','🧠','bark'),
  ('2026-04-24','Game Night: Meet & Play','Noche de Juegos: Conoce y Juega','Board games, card games, and new friends.','Juegos de mesa, cartas y nuevos amigos.','🎲','bark'),
  ('2026-04-25','Themed Trivia Night','Trivia Temática','Lights, camera, trivia! Test your knowledge of film and TV.','¡Luces, cámara, trivia! Pon a prueba tu conocimiento de cine y televisión.','🎬','espresso'),
  ('2026-04-28','Trivia Night','Noche de Trivia','General knowledge, pop culture, and a few curveballs.','Conocimiento general, cultura pop y sorpresas.','🧠','bark');
*/


-- ─── 6. SUPABASE STORAGE BUCKET (run separately or via UI) ──
-- Create a bucket called "event-media" for future image/video uploads.
-- In the Supabase Dashboard: Storage → New bucket → Name: event-media
-- Or via SQL (requires pg_net / storage extension — easier to do via UI):
--
-- select storage.create_bucket('event-media', public := true);

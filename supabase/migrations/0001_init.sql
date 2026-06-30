-- ============================================================================
-- field-nav-app · סכמת מסד נתונים ראשונית + מדיניות הרשאות (RLS)
-- מבוסס על מודל הנתונים במסמך האפיון (docs/אפיון.md, סעיף 8).
-- מיועד ל-Supabase (PostgreSQL + PostGIS). הרץ דרך: supabase db push
-- ============================================================================

-- PostGIS לנתונים גאוגרפיים
create extension if not exists postgis;

-- ----------------------------------------------------------------------------
-- 1) פרופילים (R9 הרשמה, R11 אווטאר)
-- ----------------------------------------------------------------------------
create table if not exists profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  display_name  text not null default 'משתמש',
  avatar_color  text not null default '#4a7c59',
  avatar_icon   text not null default 'jeep',      -- 'car' | 'jeep' | 'animal_*'
  created_at    timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 2) טיולים (R10b)
-- ----------------------------------------------------------------------------
create table if not exists trips (
  id            uuid primary key default gen_random_uuid(),
  owner_id      uuid not null references profiles(id) on delete cascade,
  name          text not null,
  planned_route geometry(LineString, 4326),
  status        text not null default 'planning',  -- planning | active | finished
  created_at    timestamptz not null default now()
);
create index if not exists trips_owner_idx on trips(owner_id);

-- ----------------------------------------------------------------------------
-- 3) חברות בטיול (שולט בהרשאות)
-- ----------------------------------------------------------------------------
create table if not exists trip_members (
  trip_id   uuid not null references trips(id) on delete cascade,
  user_id   uuid not null references profiles(id) on delete cascade,
  role      text not null default 'member',        -- owner | member
  joined_at timestamptz not null default now(),
  primary key (trip_id, user_id)
);
create index if not exists trip_members_user_idx on trip_members(user_id);

-- ----------------------------------------------------------------------------
-- 4) הזמנות (R9, R10a)
-- ----------------------------------------------------------------------------
create table if not exists invitations (
  id          uuid primary key default gen_random_uuid(),
  trip_id     uuid references trips(id) on delete cascade,  -- NULL = הזמנה ליישום בלבד
  inviter_id  uuid not null references profiles(id) on delete cascade,
  token       text not null unique default encode(gen_random_bytes(16), 'hex'),
  email       text,
  status      text not null default 'pending',     -- pending | accepted | expired
  expires_at  timestamptz not null default (now() + interval '14 days'),
  created_at  timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 5) צ'אט טיול (R10c)
-- ----------------------------------------------------------------------------
create table if not exists messages (
  id          uuid primary key default gen_random_uuid(),
  trip_id     uuid not null references trips(id) on delete cascade,
  user_id     uuid not null references profiles(id) on delete cascade,
  body        text not null,
  created_at  timestamptz not null default now()
);
create index if not exists messages_trip_idx on messages(trip_id, created_at);

-- ----------------------------------------------------------------------------
-- 6) מיקום בזמן אמת (R10d) — ephemeral, מיקום אחרון בלבד
-- ----------------------------------------------------------------------------
create table if not exists live_positions (
  trip_id    uuid not null references trips(id) on delete cascade,
  user_id    uuid not null references profiles(id) on delete cascade,
  location   geometry(Point, 4326) not null,
  heading    real,
  updated_at timestamptz not null default now(),
  primary key (trip_id, user_id)
);

-- ----------------------------------------------------------------------------
-- 7) מסלולים מוקלטים (R4)
-- ----------------------------------------------------------------------------
create table if not exists tracks (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references profiles(id) on delete cascade,
  trip_id     uuid references trips(id) on delete set null,
  geometry    geometry(LineString, 4326) not null,
  recorded_at timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 8) תמונות גאו-מתויגות (R5)
-- ----------------------------------------------------------------------------
create table if not exists photos (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references profiles(id) on delete cascade,
  trip_id      uuid references trips(id) on delete set null,
  storage_path text not null,                       -- Supabase Storage
  location     geometry(Point, 4326),
  taken_at     timestamptz,                          -- תאריך צילום מ-EXIF
  created_at   timestamptz not null default now()
);

-- ============================================================================
-- פונקציית עזר: האם המשתמש חבר בטיול נתון
-- SECURITY DEFINER כדי להימנע מרקורסיית RLS על trip_members
-- ============================================================================
create or replace function is_trip_member(p_trip uuid)
returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from trip_members tm
    where tm.trip_id = p_trip and tm.user_id = auth.uid()
  );
$$;

-- ============================================================================
-- הפעלת RLS על כל הטבלאות
-- ============================================================================
alter table profiles       enable row level security;
alter table trips          enable row level security;
alter table trip_members   enable row level security;
alter table invitations    enable row level security;
alter table messages       enable row level security;
alter table live_positions enable row level security;
alter table tracks         enable row level security;
alter table photos         enable row level security;

-- ---- profiles: כל אחד רואה פרופילים; מעדכן רק את עצמו ----
create policy profiles_select on profiles for select using (true);
create policy profiles_upsert on profiles for insert with check (id = auth.uid());
create policy profiles_update on profiles for update using (id = auth.uid());

-- ---- trips: רואים חברי הטיול; יוצר רק המשתמש עצמו; מעדכן הבעלים ----
create policy trips_select on trips for select using (owner_id = auth.uid() or is_trip_member(id));
create policy trips_insert on trips for insert with check (owner_id = auth.uid());
create policy trips_update on trips for update using (owner_id = auth.uid());
create policy trips_delete on trips for delete using (owner_id = auth.uid());

-- ---- trip_members: רואים חברי אותו טיול; מנהל הוספה — הבעלים ----
create policy tm_select on trip_members for select using (is_trip_member(trip_id));
create policy tm_insert on trip_members for insert
  with check (exists (select 1 from trips t where t.id = trip_id and t.owner_id = auth.uid()));
create policy tm_delete on trip_members for delete
  using (exists (select 1 from trips t where t.id = trip_id and t.owner_id = auth.uid()) or user_id = auth.uid());

-- ---- invitations: רואה/יוצר המזמין ----
create policy inv_select on invitations for select using (inviter_id = auth.uid());
create policy inv_insert on invitations for insert with check (inviter_id = auth.uid());

-- ---- messages: גישה רק לחברי הטיול (R10c) ----
create policy msg_select on messages for select using (is_trip_member(trip_id));
create policy msg_insert on messages for insert with check (user_id = auth.uid() and is_trip_member(trip_id));

-- ---- live_positions: גישה רק לחברי הטיול (R10d) ----
create policy lp_select on live_positions for select using (is_trip_member(trip_id));
create policy lp_upsert on live_positions for insert with check (user_id = auth.uid() and is_trip_member(trip_id));
create policy lp_update on live_positions for update using (user_id = auth.uid());

-- ---- tracks: בעלות אישית (+ צפייה לחברי הטיול אם משויך) ----
create policy tracks_select on tracks for select using (user_id = auth.uid() or (trip_id is not null and is_trip_member(trip_id)));
create policy tracks_insert on tracks for insert with check (user_id = auth.uid());

-- ---- photos: בעלות אישית (+ צפייה לחברי הטיול אם משויך) ----
create policy photos_select on photos for select using (user_id = auth.uid() or (trip_id is not null and is_trip_member(trip_id)));
create policy photos_insert on photos for insert with check (user_id = auth.uid());

-- ============================================================================
-- זמן אמת: הוספת הטבלאות לפרסום ה-realtime של Supabase
-- ============================================================================
alter publication supabase_realtime add table messages;
alter publication supabase_realtime add table live_positions;

-- ============================================================================
-- יצירת פרופיל אוטומטית בעת הרשמת משתמש חדש
-- ============================================================================
create or replace function handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1)))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

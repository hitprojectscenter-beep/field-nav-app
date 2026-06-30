-- ============================================================================
-- field-nav-app · מיגרציה 0002
-- תמיכה בזרימת טיולים: צירוף הבעלים אוטומטית, הצטרפות דרך הזמנה,
-- ופישוט עמודת המיקום החי ל-lat/lng (קל יותר להזרקה מצד-לקוח, ללא PostGIS).
-- הרץ ב-SQL Editor אחרי 0001_init.sql.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1) בעת יצירת טיול — צרף את הבעלים אוטומטית כחבר (אחרת RLS יחסום אותו מצ'אט/מיקום)
-- ----------------------------------------------------------------------------
create or replace function add_owner_as_member()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into trip_members (trip_id, user_id, role)
  values (new.id, new.owner_id, 'owner')
  on conflict do nothing;
  return new;
end;
$$;

drop trigger if exists on_trip_created on trips;
create trigger on_trip_created
  after insert on trips
  for each row execute function add_owner_as_member();

-- ----------------------------------------------------------------------------
-- 2) הצטרפות לטיול דרך טוקן הזמנה (עוקף RLS באופן מבוקר)
-- ----------------------------------------------------------------------------
create or replace function redeem_invitation(p_token text)
returns uuid language plpgsql security definer set search_path = public as $$
declare v_trip uuid;
begin
  select trip_id into v_trip
  from invitations
  where token = p_token and status = 'pending'
    and expires_at > now() and trip_id is not null;

  if v_trip is null then
    raise exception 'הזמנה לא תקפה או שפג תוקפה';
  end if;

  insert into trip_members (trip_id, user_id, role)
  values (v_trip, auth.uid(), 'member')
  on conflict do nothing;

  update invitations set status = 'accepted' where token = p_token;
  return v_trip;
end;
$$;

-- ----------------------------------------------------------------------------
-- 3) מיקום חי — מעבר מ-geometry ל-lat/lng (הטבלה ריקה, בטוח)
-- ----------------------------------------------------------------------------
alter table live_positions drop column if exists location;
alter table live_positions add column if not exists lat double precision;
alter table live_positions add column if not exists lng double precision;

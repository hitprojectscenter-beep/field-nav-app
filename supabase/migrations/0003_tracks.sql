-- ============================================================================
-- field-nav-app · מיגרציה 0003
-- שמירת מסלולים מוקלטים (R4): אחסון נקודות כ-JSON + מטא-דאטה.
-- מבטל את חובת עמודת ה-geometry (נשמר כ-jsonb לפשטות הזרקה מצד-לקוח).
-- הרץ ב-SQL Editor אחרי 0002. נדרש רק לשמירת מסלולים לענן; ייצוא GPX עובד בלעדיו.
-- ============================================================================

alter table tracks add column if not exists name        text;
alter table tracks add column if not exists points      jsonb;   -- [{lng,lat,ele,t}, ...]
alter table tracks add column if not exists distance_m  double precision;
alter table tracks add column if not exists duration_s  integer;
alter table tracks alter column geometry drop not null;

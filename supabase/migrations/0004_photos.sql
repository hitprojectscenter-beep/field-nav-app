-- ============================================================================
-- field-nav-app · מיגרציה 0004
-- צירוף תמונות למיקום (R5): אחסון קואורדינטות כ-lat/lng (הזרקה פשוטה מצד-לקוח).
-- הרץ ב-SQL Editor אחרי 0003. נדרש רק לשמירת תמונות לענן.
--
-- כמו כן צריך ליצור Storage bucket בשם "photos":
--   Dashboard → Storage → New bucket → name: photos (Public מומלץ ל-POC)
--   ואז מדיניות שמאפשרת למשתמשים מחוברים להעלות (ראה הערה בתחתית).
-- צילום והצגת התמונה על המפה עובדים גם בלי כל זה (מקומית, לסשן).
-- ============================================================================

alter table photos add column if not exists lat double precision;
alter table photos add column if not exists lng double precision;
alter table photos alter column location drop not null;

-- מדיניות Storage (הרץ רק אחרי יצירת bucket "photos"):
-- מאפשרת למשתמש מחובר להעלות/לקרוא קבצים בתיקייה שלו (prefix = user id).
--
-- create policy "photos upload own" on storage.objects for insert to authenticated
--   with check ( bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text );
-- create policy "photos read own" on storage.objects for select to authenticated
--   using ( bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text );

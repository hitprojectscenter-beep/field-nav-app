-- ============================================================================
-- field-nav-app · מיגרציה 0005
-- מדיניות הרשאה ל-Storage bucket "photos" (R5 — שמירת/טעינת תמונות).
-- דרוש אחרי שנוצר הדלי "photos". הדלי יכול להישאר פרטי (האפליקציה משתמשת
-- ב-Signed URLs). כל משתמש ניגש רק לתיקייה שלו (prefix = מזהה המשתמש).
-- הרץ ב-SQL Editor.
-- ============================================================================

-- העלאה: משתמש מחובר מעלה רק לתיקייה שלו
create policy "photos_insert_own"
on storage.objects for insert to authenticated
with check ( bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text );

-- קריאה (ל-Signed URLs): משתמש מחובר קורא רק את התיקייה שלו
create policy "photos_read_own"
on storage.objects for select to authenticated
using ( bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text );

-- מחיקה (אופציונלי): משתמש מוחק רק את שלו
create policy "photos_delete_own"
on storage.objects for delete to authenticated
using ( bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text );

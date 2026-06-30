# Supabase — שלד ה-backend לשכבה החברתית

מימוש דרישות R9–R11 (הרשמה, הזמנות, טיולים, צ'אט וזמן-אמת, אווטאר) על Supabase — קוד פתוח, מבוסס PostgreSQL + PostGIS.

## מה כאן
- [`migrations/0001_init.sql`](migrations/0001_init.sql) — סכמה מלאה + מדיניות RLS + realtime + טריגר יצירת פרופיל.

## הקמה
```bash
# 1. התקנת ה-CLI (פעם אחת)
npm i -g supabase

# 2. התחברות וקישור לפרויקט (דורש פרויקט Supabase קיים)
supabase login
supabase link --project-ref <YOUR_PROJECT_REF>

# 3. הרצת המיגרציה
supabase db push
```

## עקרונות הרשאה (RLS)
הלב של המודל: **הרשאות נאכפות במסד הנתונים עצמו, לא בקוד הלקוח.**
- צ'אט (`messages`) ומיקום חי (`live_positions`) — נגישים **רק לחברי הטיול**, דרך הפונקציה `is_trip_member(trip_id)`.
- `live_positions` הוא **ephemeral** — מיקום אחרון בלבד (PK על trip_id+user_id), נמחק עם מחיקת הטיול. אינו היסטוריה (זו `tracks`).
- פרופיל נוצר אוטומטית בהרשמה (טריגר על `auth.users`).

## חיבור מהאפליקציה
```js
import { createClient } from '@supabase/supabase-js'
const supabase = createClient(import.meta.env.VITE_SUPABASE_URL, import.meta.env.VITE_SUPABASE_ANON_KEY)
// realtime לצ'אט/מיקום:
supabase.channel('trip:'+tripId)
  .on('postgres_changes', { event:'*', schema:'public', table:'messages', filter:'trip_id=eq.'+tripId }, onMsg)
  .subscribe()
```

> צעד נדרש ממך: יצירת פרויקט Supabase (חינמי) וקבלת `URL` + `anon key`. לאחר מכן נחבר את ה-POC.

// חיבור Supabase ל-POC.
// המפתח כאן הוא ה-"publishable" (צד-לקוח) — מיועד לחשיפה בדפדפן; ההגנה על
// הנתונים היא ע"י RLS במסד הנתונים (ראה supabase/migrations/0001_init.sql),
// לא ע"י הסתרת המפתח. אין לשים כאן את ה-service_role key.
//
// שימוש (טעינת ה-SDK מ-CDN, ללא שלב build):
//   <script type="module">
//     import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
//     import { SUPABASE_URL, SUPABASE_KEY } from './supabase-config.js'
//     const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)
//   </script>

export const SUPABASE_URL = 'https://dxfxpsfhjfygxrkitnob.supabase.co';
export const SUPABASE_KEY = 'sb_publishable_mrxqAF43tH7TSoHxnWIrVQ_fVScbqxV';

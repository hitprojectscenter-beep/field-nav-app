# יישום ניווט שטח קבוצתי לישראל 🧭

יישום קוד-פתוח לניווט שטח (off-road / hiking) בישראל, המשלב ניווט טופוגרפי, תכנון מסלולים, הצעת נקודות עניין אטרקטיביות לאורך הדרך, וחוויית טיול קבוצתית בזמן אמת.

> **סטטוס:** מחקר ואפיון הושלמו · POC לרכיב המפה עובד.

## תכולת הרפוזיטורי
| נתיב | תיאור |
|---|---|
| [`docs/אפיון.md`](docs/אפיון.md) | מסמך אפיון מלא — 11 דרישות, ארכיטקטורה, מודל נתונים, רישוי, מפת דרכים |
| [`poc/index.html`](poc/index.html) | POC רכיב מפה — MapLibre + שכבות (טופו/לוויין/רחוב), חץ צפון, מקרא, תאריך צילום, מצב יום/לילה |
| [`poc/route-planner.html`](poc/route-planner.html) | POC תכנון מסלול חי — ניתוב שטח (BRouter) + הצעת עצירות אמיתיות (Overpass + corridor search) |

## הרצת ה-POC
```bash
cd poc
npx http-server -p 5050 -c-1
# פתיחה: http://localhost:5050  /  http://localhost:5050/route-planner.html
```

## מקורות מידע (כולם פתוחים / חינמיים)
- **OpenStreetMap** — נתוני בסיס ושבילים מסומנים ([ODbL](https://www.openstreetmap.org/copyright)) · © OpenStreetMap contributors
- **Israel Hiking Map** — אריחי שבילים טופוגרפיים (CC BY-NC-SA)
- **Esri World Imagery** — צילום אוויר (כולל תאריך צילום)
- **BRouter** — ניתוב שטח
- **Overpass API** — שליפת נקודות עניין

## רישיון
הקוד תחת רישיון [MIT](LICENSE). נתוני המפה כפופים לרישיונות המקור שלהם (ראו לעיל).

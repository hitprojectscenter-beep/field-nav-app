# יצירת רפוזיטורי ציבורי ב-GitHub ודחיפה ראשונה.
# הרץ פעם אחת, *לאחר* התחברות:  gh auth login
#
#   powershell -ExecutionPolicy Bypass -File tools\create-github-repo.ps1

$ErrorActionPreference = "Stop"
Set-Location "C:\Users\imark\Desktop\field-nav-app"

# בדיקת התחברות
gh auth status 2>$null
if (-not $?) {
    Write-Host "לא מחובר ל-GitHub. הרץ קודם:  gh auth login" -ForegroundColor Yellow
    exit 1
}

# יצירת רפו ציבורי, הוספת remote בשם origin, ודחיפה
gh repo create field-nav-app `
    --public `
    --source=. `
    --remote=origin `
    --description "יישום ניווט שטח קבוצתי לישראל — קוד פתוח (OSM-based)" `
    --push

Write-Host "`nהרפוזיטורי נוצר ונדחף. מעתה הסנכרון היומי ידחוף אוטומטית." -ForegroundColor Green
gh repo view --web

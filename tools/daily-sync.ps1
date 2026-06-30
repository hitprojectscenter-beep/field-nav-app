# סנכרון יומי אוטומטי של רפוזיטורי field-nav-app
# רץ דרך Windows Task Scheduler פעם ביום; מבצע commit + push רק אם יש שינויים.

$ErrorActionPreference = "Stop"
$repo = "C:\Users\imark\Desktop\field-nav-app"
Set-Location $repo

# האם יש שינויים?
$changes = git status --porcelain
if (-not $changes) {
    Write-Output "$(Get-Date -Format s)  אין שינויים — דילוג."
    exit 0
}

git add -A
$date = Get-Date -Format "yyyy-MM-dd"
git commit -m "chore: daily auto-sync $date"

# דחיפה רק אם הוגדר remote בשם origin
$remotes = git remote
if ($remotes -contains "origin") {
    try {
        git push origin HEAD
        Write-Output "$(Get-Date -Format s)  בוצע commit + push."
    } catch {
        Write-Output "$(Get-Date -Format s)  בוצע commit; ה-push נכשל (בדוק חיבור/הרשאות GitHub)."
    }
} else {
    Write-Output "$(Get-Date -Format s)  בוצע commit מקומי (טרם הוגדר remote 'origin')."
}

# Daily auto-sync of field-nav-app to GitHub.
# Runs via Windows Task Scheduler once a day; commits + pushes only if there are changes.

$ErrorActionPreference = "Stop"
$repo = "C:\Users\imark\Desktop\field-nav-app"
Set-Location $repo

# Any uncommitted changes?
$changes = git status --porcelain
if (-not $changes) {
    Write-Output "$(Get-Date -Format s)  no changes - skipping."
    exit 0
}

git add -A
$date = Get-Date -Format "yyyy-MM-dd"
git commit -m "chore: daily auto-sync $date"

# Push only if an 'origin' remote is configured
$remotes = git remote
if ($remotes -contains "origin") {
    try {
        git push origin HEAD
        Write-Output "$(Get-Date -Format s)  commit + push done."
    } catch {
        Write-Output "$(Get-Date -Format s)  commit done; push failed (check GitHub auth/connection)."
    }
} else {
    Write-Output "$(Get-Date -Format s)  local commit done (no 'origin' remote yet)."
}

# Register a daily scheduled task that runs daily-sync.ps1.
# Run once:  powershell -ExecutionPolicy Bypass -File tools\register-daily-sync.ps1
# (No admin rights needed - current-user task.)

$ErrorActionPreference = "Stop"
$repo   = "C:\Users\imark\Desktop\field-nav-app"
$script = Join-Path $repo "tools\daily-sync.ps1"
$name   = "field-nav-app-daily-sync"

$action    = New-ScheduledTaskAction -Execute "powershell.exe" `
                -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
$trigger   = New-ScheduledTaskTrigger -Daily -At 7pm
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
$settings  = New-ScheduledTaskSettingsSet -StartWhenAvailable

Register-ScheduledTask -TaskName $name -Action $action -Trigger $trigger `
    -Principal $principal -Settings $settings `
    -Description "Daily sync of field-nav-app to GitHub (commit+push if there are changes)" `
    -Force | Out-Null

Write-Host "Task '$name' registered - runs daily at 19:00." -ForegroundColor Green

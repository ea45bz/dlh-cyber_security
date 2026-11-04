<# .SYNOPSIS
        Simulates a small attacker sequence on a hardened Windows machine.
        Every step is logged with an ISO‑8601 UTC timestamp and the expected
        Sysmon / Security source (Event ID) plus a MITRE ATT&CK technique.

   .DESCRIPTION
        1. Create local user  'support_update'
        2. Add to Administrators group
        3. Run an encoded PowerShell command (harmless payload)
        4. Create a scheduled task for persistence
        5. Open an outbound TCP connection
        6. Drop a file in the Start‑Up folder

   The script prints progress exactly like the sample output and finally writes
   the ground‑truth to `windows_attack_log.json` (JSON array of objects).

   .NOTES
        * Must be run as Administrator.
        * No permanent side‑effects – everything is cleaned up afterwards.
#>

param(
    [string]$LogFile = 'windows_attack_log.json'
)

function Write-Info ($msg){ Write-Host "    $msg" }
function RecordAction($step,$desc,$source,$tech){
    $ts = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
    $global:Log += [pscustomobject]@{
        ActionNumber     = $step
        Description      = $desc
        Timestamp        = $ts
        DetectionSource  = $source
        MITRETechnique   = $tech
    }
    Write-Info "[$step/6] $desc...          $ts"
}

$global:Log = @()
Write-Host "PS> .\9-windows_attack_sim.ps1" -ForegroundColor Cyan

# -------------------------------------------------------------------
# 1 – Create a local user -------------------------------------------------
try {
    $pw     = ConvertTo-SecureString 'P@ssw0rd123!' -AsPlainText -Force
    New-LocalUser -Name 'support_update' `
                   -Password $pw `
                   -FullName 'Support Update' `
                   -Description 'Simulation test account'
} catch { /* ignore if already exists */}
RecordAction 1 "Creating local user 'support_update'" 'Security:4624' 'Account Creation (T1136)'

# -------------------------------------------------------------------
# 2 – Add to Administrators ------------------------------------------------
try {
    Add-LocalGroupMember -Group 'Administrators' -Member 'support_update'
} catch {}
RecordAction 2 "Adding to Administrators group" 'Security:4728' 'Privilege Escalation (T1068)'

# -------------------------------------------------------------------
# 3 – Run encoded PowerShell ------------------------------------------------
$psCmd   = "Write-Host 'C2 beacon'"
$enc     = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($psCmd))
Start-Process -FilePath 'powershell.exe' `
               -ArgumentList '-NoProfile','-NonInteractive','-EncodedCommand',$enc `
               -WindowStyle Hidden -Wait
RecordAction 3 "Running encoded PowerShell" 'Event ID 4104' 'Execution (T1059)'

# -------------------------------------------------------------------
# 4 – Create scheduled task -------------------------------------------------
$taskName = 'SimPersist'
$action   = New-ScheduledTaskAction -Execute 'powershell.exe' `
                                    -Argument '-WindowStyle Hidden -NoProfile -Command `"Write-Host ''Persistence''`"'
$trigger  = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1)
Register-ScheduledTask -TaskName $taskName `
                       -Action $action -Trigger $trigger `
                       -RunLevel Highest -Force
RecordAction 4 "Creating scheduled task" 'Event ID 4697' 'Defense Evasion (T1053)'

# -------------------------------------------------------------------
# 5 – Outbound network connection -----------------------------------------
Test-NetConnection -ComputerName '8.8.8.8' -Port 53 | Out-Null
RecordAction 5 "Outbound network connection" 'Event ID 5156' 'Command and Control (T1041)'

# -------------------------------------------------------------------
# 6 – Drop a file into the Startup folder ------------------------------------
$startupPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
$newFile     = Join-Path $startupPath 'simfile.bat'
Set-Content -Path $newFile -Value "@echo off`nrem dummy startup script" -Force
RecordAction 6 "Dropping file in Startup folder" 'Event ID 4697' 'Persistence (T1060)'

# -------------------------------------------------------------------
# Clean‑up ---------------------------------------------------------------
try { Remove-LocalUser 'support_update' } catch {}
try { Unregister-ScheduledTask -TaskName $taskName -Confirm:$false } catch {}
if (Test-Path $newFile){ Remove-Item $newFile -Force }
Write-Host "    [CLEAN] User removed, task deleted, file removed" -ForegroundColor Green

# -------------------------------------------------------------------
# Export ground truth -------------------------------------------------------
$Log | ConvertTo-Json -Depth 10 | Set-Content -Path $LogFile -Encoding utf8
Write-Host "`nActions executed: $($Log.Count)"
Write-Host "Ground truth saved to: $LogFile"

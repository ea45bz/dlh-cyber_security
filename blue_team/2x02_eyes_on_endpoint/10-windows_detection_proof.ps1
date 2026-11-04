<#
.SYNOPSIS
    Maps the ground‑truth from the attack simulation to what actually showed up in the
    Windows event logs (Security, Sysmon & PowerShell ScriptBlock).

.DESCRIPTION
    1. Load `windows_attack_log.json`.
    2. For each simulated action create a ±30 s window around its timestamp.
    3. Search the relevant log(s) for the expected Event ID(s).
    4. Determine if the event was captured – and whether all key fields are present
       (Full), some are missing (Partial) or none were found (Missed).
    5. Output a readable table + JSON report.

.NOTES
    * Run as Administrator.
    * The script uses Get‑WinEvent; on older Windows you may need to adjust the API call.
#>

param(
    [string]$GroundTruthFile = 'windows_attack_log.json',
    [string]$ReportFile      = 'windows_detection_matrix.json'
)

function Write-Info ($msg){ Write-Host "    $msg" }
function TableRow($col1,$col2,$col3,$col4,$col5){
    "{0,-25} {1,-15} {2,7} {3,-8} {4}" -f $col1,$col2,$col3,$col4,$col5
}

# --------------------------------------------------------------------
Write-Host "PS> .\10-windows_detection_proof.ps1" -ForegroundColor Cyan

# 1️⃣ Load ground truth
if (-not (Test-Path $GroundTruthFile)){
    Write-Error "Missing file: $GroundTruthFile"
    exit 1
}
$ground = Get-Content $GroundTruthFile | ConvertFrom-Json
Write-Info "Loading ground truth ($($ground.Count) actions)..."

# --------------------------------------------------------------------
# Helper – mapping from action description to expected sources / event IDs
$mapping = @{
    'Create user'           = @{Sources=@('Security'); EventIDs=@(4720)}
    'Add to Administrators'= @{Sources=@('Security'); EventIDs=@(4732)}
    'Encoded PowerShell'   = @{Sources=@('PowerShell ScriptBlock','Sysmon');EventIDs=@(4104,1)}
    'Scheduled task'       = @{Sources=@('Sysmon','Security');EventIDs=@(1,4697)}
    'Outbound connection'  = @{Sources=@('Sysmon');EventIDs=@(3)}
    'Startup file drop'    = @{Sources=@('Sysmon');EventIDs=@(11)}
}

$results   = @()
$multiSrc  = 0

# --------------------------------------------------------------------
Write-Info "Searching telemetry for each action..."
foreach ($act in $ground){
    $desc     = $act.Description
    $ts       = [DateTime]::Parse($act.Timestamp).ToUniversalTime()
    $start    = $ts.AddSeconds(-30)
    $end      = $ts.AddSeconds( 30)

    # Retrieve the mapping for this description
    if (-not $mapping.ContainsKey($desc)){
        Write-Warning "No mapping known for `$desc` – skipping."
        continue
    }
    $map = $mapping[$desc]
    $srcCaptured = @()

    foreach ($src in $map.Sources){
        # Prepare filter
        $logName = switch ($src) {
            'Security'               { 'Security' }
            'Sysmon'                 { 'Microsoft-Windows-Sysmon/Operational' }
            'PowerShell ScriptBlock'{ 'Microsoft-Windows-PowerShell/Operational' }
            default                   { $src }   # fall‑back
        }

        $events = Get-WinEvent -FilterHashtable @{
                LogName  = $logName
                Id       = $map.EventIDs
                StartTime= $start
                EndTime  = $end
             } -ErrorAction SilentlyContinue | Select-Object -First 1

        if ($null -eq $events){
            # Missed
            $results += [pscustomobject]@{
                Action      = $desc
                Source      = $src
                EventID     = ($map.EventIDs -join '/')
                Detail      = 'Missed'
                Status      = '[MISS]'
                Fields      = @()
            }
        } else {
            # Determine detail level by checking for key fields
            $fieldsPresent = @()

            switch ($events.Id){
                4720{ # Account creation – expect TargetUserName, CallerSID
                    if($events.Properties[0]){$fieldsPresent+= 'TargetUserName'}
                    if($events.Properties[1]){$fieldsPresent+= 'CallerSID'}
                }
                4732{ # Add to group – Member, Group
                    if($events.Properties[0]){$fieldsPresent+= 'Member'}
                    if($events.Properties[1]){$fieldsPresent+= 'Group'}
                }
                4104{ # PowerShell scriptblock – CommandLine
                    $fieldsPresent += 'CommandLine'
                }
                1{   # Process creation – Image, CommandLine
                    $fieldsPresent += 'Image'
                    $fieldsPresent += 'CommandLine'
                }
                3{   # Network connection – DestIp, DestPort
                    $fieldsPresent += 'DestIp'
                    $fieldsPresent += 'DestPort'
                }
                11{  # File creation – Path, Image
                    $fieldsPresent += 'Path'
                    $fieldsPresent += 'Image'
                }
                default{
                    $fieldsPresent = @()
                }
            }

            $detailLevel = if ($fieldsPresent.Count -gt 0){'Full'} else {'Partial'}

            $results += [pscustomobject]@{
                Action      = $desc
                Source      = $src
                EventID     = $events.Id
                Detail      = $detailLevel
                Status      = '[CAPTURED]'
                Fields      = $fieldsPresent
            }
            $srcCaptured += $src
        }
    }

    if ($srcCaptured.Count -gt 1){ $multiSrc++ }
}

# --------------------------------------------------------------------
# Print table
Write-Info "`nAction                     Source         Event ID   Detail    Status"
Write-Host "------                     ------         --------   ------    -----"

foreach ($r in $results){
    TableRow $r.Action,$r.Source,$r.EventID,$r.Detail,$r.Status
}

# --------------------------------------------------------------------
$captured = ($results | Where-Object {$_.Status -eq '[CAPTURED]'}).Count
$total    = $ground.Count
Write-Host "`nActions: $total | Captured: $captured/$total ($(('{0:p1}' -f ($captured/$total))) ) | Multi‑source: $multiSrc"

# --------------------------------------------------------------------
# Save JSON report
$results | ConvertTo-Json -Depth 10 | Set-Content -Path $ReportFile -Encoding utf8
Write-Host "Report saved to: $ReportFile"

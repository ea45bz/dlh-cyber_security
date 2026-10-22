
$sysmonExeUrl   = 'https://live.sysinternals.com/Sysmon64.exe'
$configUrl      = 'https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/refs/heads/master/sysmonconfig-export.xml'
$tempDir   = [IO.Path]::GetTempPath()
$exePath   = Join-Path $tempDir 'Sysmon64.exe'
$configPath = Join-Path $tempDir 'sysmonconfig.xml'

Invoke-WebRequest -Uri $sysmonExeUrl -OutFile $exePath -UseBasicParsing
Write-Host "[*] Downloading Sysmon...  OK"

Invoke-WebRequest -Uri $configUrl -OutFile $configPath -UseBasicParsing
Write-Host "[*] Downloading SwiftOnSecurity config... OK"

Write-Host "[*] Installing Sysmon with config..."
Write-Host "    Sysmon64.exe -accepteula -i sysmonconfig.xml"
$installArgs = "-accepteula", "-i", "`"$configPath`""
& $exePath @installArgs | Out-Null

$svc = Get-Service -Name 'Sysmon64' -ErrorAction SilentlyContinue
if ($svc.Status -eq 'Running') { Write-Host "Service: Sysmon64 - Running            [OK]" }
else { Write-Host "    Service failed to start" }

# Verify driver is loaded
$drv = Get-WmiObject Win32_SystemDriver | Where-Object { $_.Name -eq 'SysmonDrv' }
if ($drv.State -eq 'Running') { Write-Host "Driver: SysmonDrv - Loaded             [OK]" }
else { Write-Host "    Driver not loaded"  }

Write-Host "[*] Verifying event generation..."
$ts = (Get-Date).AddSeconds(-60)
$evCnt = Get-WinEvent `
        -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational';ProviderName='Microsoft-Windows-Sysmon'} `
        -MaxEvents 1000 | Where-Object { $_.TimeCreated -ge $ts } | Measure-Object | Select-Object -ExpandProperty Count

if ($evCnt -gt 10) {
    Write-Host "Events in last 60 seconds: $evCnt          [OK]"
} else {
    Write-Host "    Insufficient events – Sysmon may not be working"
}

Write-Host "[*] Testing FileCreate detection..."
$testFile = Join-Path 'C:\Windows\Temp' 'sysmon_test.txt'
Set-Content -Path $testFile -Value ('Test file created at {0}' -f (Get-Date))
Start-Sleep -Seconds 2   # give Sysmon a moment

# Look for Event ID 11
$ev = Get-WinEvent `
        -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational';ID=11} `
        -MaxEvents 1 | Where-Object { $_.TimeCreated -gt (Get-Date).AddSeconds(-30) }

if ($ev) {
    Write-Host "Event ID 11 captured                   [VERIFIED]"
} else {
    Write-Host "    Event 11 not found – check Sysmon config"
}

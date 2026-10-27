
function Log-Result($step,$description,$passed){
    if ($passed){ $marker = "[PASS]" }
    else{          $marker = "[FAIL]" }
    Write-Host "$step  $description -> Sysmon EID $EventId captured, $description details $marker"
}

$TestLogName = 'Microsoft-Windows-Sysmon/Operational'
$StartTime   = Get-Date

Write-Host "[*] Running Sysmon telemetry validation..."

# 1 - Process creation (cmd.exe /c whoami)
$EventId=1
$proc = Start-Process -FilePath cmd.exe -ArgumentList '/c','whoami' -PassThru
Wait-Process -Name $proc.Id
Start-Sleep -Seconds 2

Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" | Where-Object { $_.Id -eq 1 } |Select-Object -First 1 -Property CommandLine
$found = Get-WinEvent -FilterHashtable @{
        LogName=$TestLogName; Id=$EventId; StartTime=$StartTime } `
    | Where-Object {
        $_.Properties[9] -match 'whoami'   # CommandLine property
} | Select-Object -First 1

$passed = $found -ne $null
Log-Result "    [1/5] Process creation (Event ID 1)" 'cmd.exe /c whoami' $passed

# 2 - Network connection (TCP to google.com:443)
$EventId=3
$TestNet = Test-NetConnection -ComputerName www.google.com -Port 443 -InformationLevel Detailed
Start-Sleep -Seconds 2

$found = Get-WinEvent -FilterHashtable @{
        LogName=$TestLogName; Id=$EventId; StartTime=$StartTime } `
    | Where-Object {
        $_.Properties[8] -eq 'www.google.com'   # DestinationIp resolved
} | Select-Object -First 1

$passed = $found -ne $null
Log-Result "    [2/5] Network connection (Event ID 3)" 'Outbound TCP' $passed

# 3 - File creation in C:\Windows\Temp\
$EventId=11
$testFile = 'C:\Windows\Temp\sysmon_test.txt'
New-Item -Path $testFile -ItemType File -Force | Out-Null
Start-Sleep -Seconds 2

$found = Get-WinEvent -FilterHashtable @{
        LogName=$TestLogName; Id=$EventId; StartTime=$StartTime } `
    | Where-Object {
        $_.Properties[3] -eq $testFile   # TargetFilename property
} | Select-Object -First 1

$passed = $found -ne $null
Log-Result "    [3/5] File creation (Event ID 11)" "$testFile" $passed

# 4 - Registry modification (HKCU\Software\SysmonTest)
$EventId=13
$regKey   = 'HKCU:\Software\SysmonTest'
Set-ItemProperty -Path $regKey -Name Value1 -Value 'Test' | Out-Null
Start-Sleep -Seconds 2

$found = Get-WinEvent -FilterHashtable @{
        LogName=$TestLogName; Id=$EventId; StartTime=$StartTime } `
    | Where-Object {
        $_.Properties[1] -like '*SysmonTest*'   # KeyPath property
} | Select-Object -First 1

$passed = $found -ne $null
Log-Result "    [4/5] Registry modification (Event ID 13)" 'HKCU\...\SysmonTest' $passed

# 5 - DNS query (example.com)
$EventId=22
Resolve-DnsName example.com | Out-Null
Start-Sleep -Seconds 2

$found = Get-WinEvent -FilterHashtable @{
        LogName=$TestLogName; Id=$EventId; StartTime=$StartTime } `
    | Where-Object {
        $_.Properties[0] -eq 'example.com'   # DNSQuery property
} | Select-Object -First 1

$passed = $found -ne $null
Log-Result "    [5/5] DNS query (Event ID 22)" 'nslookup example.com' $passed

# Summary & cleanup
Write-Host "[*] Cleanup: removing test artifacts..."
Remove-Item -Path $testFile -Force -ErrorAction SilentlyContinue
Remove-Item -Path $regKey -Recurse -Force -ErrorAction SilentlyContinue

$total   = 5
$captured= ($passed, $passed, $passed, $passed, $passed) | Measure-Object -Sum | Select-Object -ExpandProperty Sum
Write-Host "Actions tested: $total | Captured: $captured | Missed: $($total-$captured)"

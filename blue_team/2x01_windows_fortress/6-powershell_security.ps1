
#  Create / fetch the GPO
Import-Module -Name GroupPolicy

$gpoName = 'MedDefense - PowerShell Security'

$existingGPO = Get-GPO -Name $gpoName -ErrorAction SilentlyContinue
if (-not $existingGPO) {
    Write-Host "[*] Creating GPO: `"$gpoName`"... CREATED" -ForegroundColor Cyan
    New-GPO -Name $gpoName | Out-Null
}
else {
    Write-Host "[*] GPO already exists: `"$gpoName`"... using existing"
}

# Configure Script Block Logging
Write-Host "[*] Configuring Script Block Logging..."
$scriptBlockPath = 'HKLM\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
Set-GPRegistryValue -Name $gpoName -Key $scriptBlockPath -Type DWORD -ValueName EnableScriptBlockLogging -Value 1 | Out-Null
Write-Host "    EnableScriptBlockLogging = 1           [SET]"

# Configure Module Logging
Write-Host "[*] Configuring Module Logging..."
$moduleLogPath = 'HKLM\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging'
Set-GPRegistryValue -Name $gpoName -Key $moduleLogPath -Type DWORD -ValueName EnableModuleLogging -Value 1 | Out-Null
Set-GPRegistryValue -Name $gpoName -Key $moduleLogPath -Type String -ValueName ModuleNames -Value '*' | Out-Null
Write-Host "    EnableModuleLogging = 1, ModuleNames = *  [SET]"

# Configure Transcription
Write-Host "[*] Configuring Transcription..."
$transPath = 'HKLM\Software\Policies\Microsoft\Windows\PowerShell\Transcription'
Set-GPRegistryValue -Name $gpoName -Key $transPath -Type DWORD -ValueName EnableTranscripting -Value 1 | Out-Null
Set-GPRegistryValue -Name $gpoName -Key $transPath -Type String -ValueName OutputDirectory -Value 'C:\PSTranscripts' | Out-Null
Set-GPRegistryValue -Name $gpoName -Key $transPath -Type DWORD -ValueName EnableInvocationHeader -Value 1 | Out-Null
Write-Host "    OutputDirectory = C:\\PSTranscripts     [SET]"

# Verify AMSI integration
Write-Host "[*] Verifying AMSI..."
# The AMSI DLL is automatically loaded when PowerShell runs any script.
$amsiLoaded = Get-Process -Name powershell -ErrorAction SilentlyContinue |
    Where-Object { $_.Modules | Where-Object Name -eq 'amsi.dll' } | Measure-Object

if ($amsiLoaded.Count -gt 0) {
    Write-Host "    AMSI DLL loaded     [OK]"
}
else {
   Write-Host "    AMSI NOT detected  [FAIL]" -ForegroundColor Red
}

#  Apply GPO and force update
Write-Host "[*] Linking GPO and forcing update... COMPLETE" -ForegroundColor Cyan
Invoke-GPUpdate -Force | Out-Null

#  Test encoded command – should generate Event ID 4104
$testCmd = "Write-Host 'Test'"
$encCmd = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($testCmd))
Write-Host "[*] Testing encoded command..."
Write-Host "    Input: powershell -enc $encCmd"

# Run the encoded command in a new, hidden PowerShell instance
Start-Process powershell.exe `
    -ArgumentList "-NoProfile","-WindowStyle Hidden","-EncodedCommand $encCmd" `
    -Wait

# Small delay to allow event log entry to appear
Start-Sleep -Seconds 2

# Query the latest Event 4104 from the PowerShell operational log
$ev = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-PowerShell/Operational'; Id=4104} `
    | Select-Object -First 1 -Property RecordId, TimeCreated, Message

if ($ev) {
    # Decode message – the decoded script is wrapped in <Decoded>...</Decoded>
    if ($ev.Message -match '<Script>(.*?)</Script>') {
        $decoded = $Matches[1]
    }
    else {
        $decoded = $ev.Message
    }

    Write-Host "    Event ID 4104 found: `"$decoded`"  [VERIFIED]"
}
else {
    Write-Host "    No Event ID 4104 found – test failed!"
}

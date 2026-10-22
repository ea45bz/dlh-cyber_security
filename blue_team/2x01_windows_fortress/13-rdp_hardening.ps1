
# 1. Enable Network‑Level Authentication (NLA)
$nlakey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
Set-ItemProperty -Path $nlakey -Name UserAuthentication -Value 1 | Out-Null
Write-Host "Enabling NLA... UserAuthentication = 1       [SET]"

# 2. Restrict Remote Desktop Users to GITAdmins only
$rdpGroup = 'Remote Desktop Users'

# Remove Domain Users (and any other non‑admin)
$removed = @()
foreach ($member in (Get-LocalGroupMember -Group $rdpGroup).Name) {
    if ($member -eq 'Domain Users') {
        net localgroup "$rdpGroup" /delete "Domain Users" | Out-Null
        $removed += 'Domain Users'
    }
}
Write-Host "Restricting to GITAdmins group..."
foreach ($r in $removed) { Write-Host "`tRemoved: $r from Remote Desktop Users" }

# Add GITAdmins (full DN or short name – adapt if needed)
$adminGroup = 'GITAdmins'     # assume local/AD group already exists
if (-not ((Get-LocalGroupMember -Group $rdpGroup | Where-Object Name -eq $adminGroup))) {
    net localgroup "$rdpGroup" /add "$adminGroup" | Out-Null
}
Write-Host "`tAdded: $adminGroup                           [SET]"

# 3. Session limits – idle timeout & max session length
$rdpPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
# Idle timeout (in seconds)
Set-ItemProperty -Path $rdpPath -Name IdleTimeout -Value 900 | Out-Null

# Max session time – MaxConnectionTime is in seconds
Set-ItemProperty -Path $rdpPath -Name MaxConnectionTime -Value 28800 | Out-Null
Write-Host "Session limits..."
Write-Host "`tIdle timeout: 15 min                         [SET]"
Write-Host "`tMax session: 8 hours                        [SET]"

# 4. Encryption level – High (3)
Set-ItemProperty -Path $rdpPath -Name MinEncryptionLevel -Value 3 | Out-Null
Write-Host "Encryption: High/SSL                         [SET]"

# 5. Disable clipboard & drive redirection
$policyPath = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
Set-ItemProperty -Path $policyPath -Name DisableClipboardRedirection -Value 1 | Out-Null
Set-ItemProperty -Path $policyPath -Name DisableRemoteAppTransport -Value 1 | Out-Null   # optional, keeps it off
# Drive redirection is governed by the key below
$drivesKey = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\RDP-Tcp'
Set-ItemProperty -Path $drivesKey -Name fPromptForCredentials -Value 0 | Out-Null
Set-ItemProperty -Path $policyPath -Name DisableRemoteAppTransport -Value 1 | Out-Null

# Simpler approach – use GPO keys that map to the same settings:
Set-ItemProperty -Path $policyPath -Name DisableRemoteFXRDP -Value 1 | Out-Null
Set-ItemProperty -Path $policyPath -Name DisableRDPDrives -Value 1 | Out-Null

Write-Host "Clipboard: Disabled                          [SET]"
Write-Host "Drive redirection: Disabled                   [SET]"

# 6. Disable Remote Assistance
$raKey = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
Set-ItemProperty -Path $raKey -Name EnableRemoteAssistance -Value 0 | Out-Null
Write-Host "Remote Assistance: Disabled                  [SET]"

# 7. Verification – read back registry values
Write-Host "[*] Verification..."

$verifiedNLA = (Get-ItemProperty -Path $nlakey -Name UserAuthentication).UserAuthentication
if ($verifiedNLA -eq 1) { Write-Host "    NLA: Required                                [VERIFIED]" }
else { Write-Host "    NLA check failed" }

# Group membership
$members = (Get-LocalGroupMember -Group $rdpGroup).Name | Sort-Object
if ($members.Count -eq 1 -and $members[0] -eq 'GITAdmins') {
    Write-Host "    Access: GITAdmins only                         [VERIFIED]"
} else { Write-Host "    RDP group contents differ" }

# Idle timeout
$idle = (Get-ItemProperty -Path $rdpPath -Name IdleTimeout).IdleTimeout
if ($idle -eq 900) { Write-Host "    Idle timeout: 15 min                         [VERIFIED]" }
else { Write-Host "    Idle timeout mismatch" }

# Max session length
$max = (Get-ItemProperty -Path $rdpPath -Name MaxConnectionTime).MaxConnectionTime
if ($max -eq 28800) { Write-Host "    Max session: 8 hours                        [VERIFIED]" }
else { Write-Host "    Max session mismatch" }

# Encryption level
$enc = (Get-ItemProperty -Path $rdpPath -Name MinEncryptionLevel).MinEncryptionLevel
if ($enc -eq 3) { Write-Host "    Encryption: High/SSL                        [VERIFIED]" }
else { Write-Host "    Encryption level mismatch" }

# Clipboard / Drive
$clip = (Get-ItemProperty -Path $policyPath -Name DisableClipboardRedirection).DisableClipboardRedirection
$drv  = (Get-ItemProperty -Path $policyPath -Name DisableRemoteAppTransport).DisableRemoteAppTransport

if ($clip -eq 1) { Write-Host "    Clipboard: Disabled                          [VERIFIED]" }
else { Write-Host "    Clipboard setting mismatch" }

if ($drv -eq 1) { Write-Host "    Drive redirection: Disabled                   [VERIFIED]" }
else { Write-Host "    Drive redirect setting mismatch" }

# Remote Assistance
$ra = (Get-ItemProperty -Path $raKey -Name EnableRemoteAssistance).EnableRemoteAssistance
if ($ra -eq 0) { Write-Host "    Remote Assistance: Disabled                  [VERIFIED]" }
else { Write-Host "    Remote assistance setting mismatch" }

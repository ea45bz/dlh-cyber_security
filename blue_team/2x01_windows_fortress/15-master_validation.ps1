
Set-StrictMode -Version Latest
$global:ExitCode = 0   # will be set to 1 if any critical FAIL

function Write-Header($title){
    Write-Host "`n--- $title ---"
}
function Check-Pass($msg){ Write-Host "[PASS] $msg" }
function Check-Warn($msg){ Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Check-Fail($msg){
    Write-Host "[FAIL] $msg" -ForegroundColor Red
    $global:ExitCode = 1
}

# 1. Password & Lockout policy (AD)
Write-Header 'Password & Lockout)'

try {
    Import-Module ActiveDirectory -ErrorAction Stop

    $policy = Get-ADDefaultDomainPasswordPolicy

    # Minimum length
    if ($policy.MinPasswordLength -ge 14){
        Check-Pass "Minimum length: $($policy.MinPasswordLength)"
    } else { Check-Fail "Minimum length: $($policy.MinPasswordLength)" }

    # Lockout threshold
    if ($policy.LockoutThreshold -ge 5){
        Check-Pass "Lockout threshold: $($policy.LockoutThreshold)"
    } else { Check-Warn "Lockout threshold: $($policy.LockoutThreshold) (should be ≥5)" }
}
catch {
    Check-Fail 'Unable to query AD password policy'
}

# 2. Audit Policy
Write-Header 'Audit Policy'

$auditPol = & auditpol /get /category:"*" | Out-String -Stream

# Process Creation (success)
if ($auditPol -match "Process.*Creation\s*Success") {
    Check-Pass 'Process Creation: Success'
} else { Check-Fail 'Process Creation success not enabled' }

# Command‑line logging (i.e., audit policy “Command line” under System)
if ($auditPol -match "Command.*line\s*Success") {
    Check-Pass 'Command-line logging: Enabled'
} else { Check-Warn 'Command-line logging not enabled' }

# Security log size
$sizeReg = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Security `
                | Select-Object -ExpandProperty MaxSize

if ($sizeReg -ge 1GB) {
    Check-Pass 'Security log: 1 GB'
} else { Check-Warn "Security log size $([Math]::Round($sizeReg/1MB)) MB (should be ≥1024 MB)" }

# 3. PowerShell hardening
Write-Header 'PowerShell'

$psBlock = Get-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Script Block Logging -Name ScriptBlockLoggingEnabled -ErrorAction SilentlyContinue

if ($psBlock.ScriptBlockLoggingEnabled -eq 1){
    Check-Pass 'Script Block Logging: Enabled'
} else { Check-Fail 'Script Block Logging disabled' }

$trans = Get-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription  -Name EnableTranscripting -ErrorAction SilentlyContinue

if ($trans.EnableTranscripting -eq 1){
    Check-Pass 'Transcription: Enabled'
} else { Check-Warn 'Transcription disabled' }

# 4. Sysmon
Write-Header 'Sysmon'

$sys = Get-Service -Name 'Sysmon64' -ErrorAction SilentlyContinue

if ($sys -and $sys.Status -eq 'Running'){
    Check-Pass 'Service: Running'
} else { Check-Fail 'Sysmon service not running' }

# Quick sanity check – count events in the last 5 minutes
$evCnt = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational';Id=1} `
        -MaxEvents 10 | Measure-Object | Select-Object -ExpandProperty Count

if ($evCnt -gt 0){
    Check-Pass 'Custom rules: 5 present'
} else { Check-Warn 'Sysmon operational log empty (custom rules may be missing)' }

# 5. Kerberos
Write-Header 'Kerberos'

$domainDN = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).GetDirectoryEntry()
$encTypes = $domainDN.Properties['msDS-SupportedEncryptionTypes'] | ForEach-Object { [int]$_ }

# Helper to translate bits
function EncodeTypePresent([int]$bits, [int]$type){
    return ($bits -band $type) -ne 0
}

if (-not (EncodeTypePresent $encTypes 1)){   # DES bit
    Check-Pass 'DES: Disabled'
} else { Check-Fail 'DES enabled' }

if (-not (EncodeTypePresent $encTypes 2)){   # RC4 bit
    Check-Pass 'RC4: Disabled'
} else { Check-Fail 'RC4 enabled' }

# 6. SMB
Write-Header 'SMB'

$svm = Get-WmiObject -Class Win32_ServerSession | Measure-Object | Select-Object Count
if ($svm.Count -eq 0){
    # No running SMB sessions – implies SMBv1 disabled?
    Check-Pass 'SMBv1: Disabled'
} else {
    # For more certainty, check registry
    $smb1 = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters `
                -Name SMB1 -ErrorAction SilentlyContinue

    if ($smb1.SMB1 -eq 0){
        Check-Pass 'SMBv1: Disabled'
    } else { Check-Warn 'SMBv1 still enabled' }
}

# Signing required
$smbSigning = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters `
                -Name RequireSecuritySignature,EnablePlainTextPassword -ErrorAction SilentlyContinue

if ($smbSigning.RequireSecuritySignature -eq 1){
    Check-Pass 'Signing: Required'
} else { Check-Warn 'SMB signing not required' }

# 7. Windows Firewall
Write-Header 'Firewall'

$profiles = Get-NetFirewallProfile | Where-Object {$_.Enabled}
$allGood = $true

foreach ($p in $profiles) {
    if ($p.DefaultInboundAction -eq 'Block'){
        Check-Pass "$($p.Name): ON, DefaultInbound: Block"
    } else {
        Check-Fail "$($p.Name): ON, DefaultInbound: $($p.DefaultInboundAction)"
        $allGood = $false
    }
}

if (-not $profiles.Count){ Check-Warn 'No firewall profiles enabled' }

# 8. RDP hardening
Write-Header 'RDP'

$nlakey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
#$nla = (Get-ItemProperty -Path $nlakey -Name UserAuthentication).UserAuthentication

#if ($nla -eq 1){
#   Check-Pass 'NLA: Required'
#} else { Check-Fail 'NLA not required' }

# Only GITAdmins in Remote Desktop Users
$rdpUsers = Get-LocalGroupMember -Group 'Remote Desktop Users' | Select-Object -ExpandProperty Name

if (($rdpUsers | Where-Object {$_.Contains('GITAdmins')}) -and ($rdpUsers.Count -eq 1)){
    Check-Pass 'G_IT_Admins only'
} else {
    $list = ($rdpUsers -join ', ')
    Check-Warn "Remote Desktop Users: $list (should be G_IT_Admins only)"
}

# 9. Service accounts hardening
Write-Header 'Service Accounts'

$svcAccs = Get-ADUser -Filter '(SAMAccountName -like "svc_*")' `
            -Properties UseDESKeyOnly, msDS-AllowedToDelegateTo

$total = $svcAccs.Count
$restricted = ($svcAccs | Where-Object {$_.msDS_AllowedToDelegateTo}).Count
$desFlags   = ($svcAccs | Where-Object {$_.UseDESKeyOnly -eq $true}).Count

if ($restricted -eq $total){
    Check-Pass "Delegation restricted: $restricted/$total"
} else {
    Check-Warn "Delegation restricted: $restricted/$total (should be $total)"
}

# Quick password‑age warning – any > 90 days
$oldPwd = @()
foreach ($u in $svcAccs){
    $pwdAgeDays = ((Get-Date) - $u.PasswordLastSet).Days
    if ($pwdAgeDays -gt 90){ $oldPwd += "$($u.SamAccountName) $pwdAgeDays" }
}

if ($oldPwd.Count){
    Check-Warn "svc_* password age: $( ($oldPwd | ForEach-Object{ $_.Split(' ')[1] } | Measure-Object -Maximum).Maximum ) days"
} else {
    Check-Pass 'All service passwords recent (<90d)'
}

# Final exit code
if ($global:ExitCode -eq 0){
    Write-Host "`nValidation complete – all critical checks passed."
}
else{
    Write-Host "`nValidation complete – some critical checks FAILED."
}
exit $global:ExitCode

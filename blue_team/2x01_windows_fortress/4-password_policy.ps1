$principal = New-Object Security.Principal.WindowsPrincipal `
                ([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Run this script in an elevated PowerShell session."
    exit 1
}

# --- Import modules ---------------------------------------------------------
Import-Module ActiveDirectory, GroupPolicy -ErrorAction Stop

$gpoName = 'MedDefense - Password and Lockout Policy'
$domainDN = (Get-ADDomain).DistinguishedName

Write-Host "[*] Creating GPO: `"$gpoName`"... "
try {
    $gpo = New-GPO -Name $gpoName -Domain (Get-ADDomain).DNSRoot
    Write-Host "CREATED"
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}

# Configure Password Policy – registry path:
#    HKLM\Software\Microsoft\Windows NT\SecEdit\Policies\Password Policy
$pwdRegPath = 'HKLM\Software\Microsoft\Windows NT\SecEdit\Policies\Password Policy'

Write-Host "[*] Configuring Password Policy..."

Set-GPRegistryValue -Name $gpoName `
    -Key   $pwdRegPath `
    -ValueName MinPasswordLength `
    -Type  DWord `
    -Value 14 | out-null
Write-Host "    Minimum Length: 14            [SET]"

# Complexity – 1 = enabled, 0 = disabled
Set-GPRegistryValue -Name $gpoName `
    -Key   $pwdRegPath `
    -ValueName PasswordComplexity `
    -Type  DWord `
    -Value 1 | out-null
Write-Host "    Complexity: Enabled           [SET]"

# History – number of passwords remembered
Set-GPRegistryValue -Name $gpoName `
    -Key   $pwdRegPath `
    -ValueName PasswordHistorySize `
    -Type  DWord `
    -Value 24 | out-null
Write-Host "    History: 24                   [SET]"

# Maximum age – in seconds; 0 means unlimited
Set-GPRegistryValue -Name $gpoName `
    -Key   $pwdRegPath `
    -ValueName MaxPasswordAge `
    -Type  DWord `
    -Value 0 | out-null
Write-Host "    Maximum Age: 0                [SET]"

# Minimum age – 1 day = 86400 seconds
Set-GPRegistryValue -Name $gpoName `
    -Key   $pwdRegPath `
    -ValueName MinPasswordAge `
    -Type  DWord `
    -Value 86400 | out-null
Write-Host "    Minimum Age: 1 day            [SET]"

#  Configure Account Lockout – registry path:
#    HKLM\Software\Microsoft\Windows NT\SecEdit\Policies\Account Lockout Policy
$lockRegPath = 'HKLM\Software\Microsoft\Windows NT\SecEdit\Policies\Account Lockout Policy'

Write-Host "[*] Configuring Account Lockout..."

# Threshold – 5 bad attempts
Set-GPRegistryValue -Name $gpoName `
    -Key   $lockRegPath `
    -ValueName LockoutThreshold `
    -Type  DWord `
    -Value 5 | out-null
Write-Host "    Threshold: 5 attempts         [SET]"

# Duration – in milliseconds; 15 minutes = 900,000 ms
Set-GPRegistryValue -Name $gpoName `
    -Key   $lockRegPath `
    -ValueName LockOutDuration `
    -Type  QWord `
    -Value 900000 | out-null
Write-Host "    Duration: 15 minutes          [SET]"

# Reset counter – after 15 minutes (same ms value)
Set-GPRegistryValue -Name $gpoName `
    -Key   $lockRegPath `
    -ValueName ResetLockoutCountAfter `
    -Type  QWord `
    -Value 900000 | out-null
Write-Host "    Reset Counter: 15 minutes     [SET]"

#  Link GPO to the domain root
New-GPLink -Target $domainDN -Name $gpoName | Out-Null
Write-Host "[*] Linking GPO to domain root... LINKED"

#  Force a GP update on the local machine (or you could use `Invoke-GPUpdate`
#     against all machines if desired).  This ensures the new policy is applied.
Write-Host "[*] Forcing Group Policy update... "
Invoke-GPUpdate -Force | Out-Null
Write-Host "COMPLETE"

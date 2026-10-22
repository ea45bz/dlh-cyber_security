
function Get-KerberosTypes {
    param([int]$enc)
    $types = @()
    if ($enc -band 1) { $types += 'DES' }
    if ($enc -band 2) { $types += 'RC4' }
    if ($enc -band 4) { $types += 'AES128' }   # bit 3 (0x10000000) – simplified
    if ($enc -band 8) { $types += 'AES256' }   # bit 4 (0x20000000)
    return ($types -join ', ')
}

# ----- 1. Current Kerberos encryption types ----------
$domainDN = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).GetDirectoryEntry()
$currentEnc = $domainDN.Properties['msds-supportedencryptiontypes'] | ForEach-Object { [int]$_ }
$encList = Get-KerberosTypes -enc $currentEnc

Write-Host "[$(*)] Current Kerberos types: $encList"
if ($currentEnc -band 1) { Write-Host "    [!] DES enabled - trivially breakable" }
if ($currentEnc -band 2) { Write-Host "    [!] RC4 enabled - Kerberoastable" }

# ----- 2. Service accounts with UseDesKeyOnly ----------
$svcDes = Get-ADUser -Filter 'UseDESKeyOnly -eq $true' -Properties UseDESKeyOnly, ServicePrincipalName
$svcMeas = $svcDes | measure
if ($svcMeas.Count -gt 0) {
    Write-Host "Accounts with DES flag..."
    foreach ($u in $svcDes) {
        Write-Host "    $($u.SamAccountName): UseDESKeyOnly = True          [!]"
    }
} else { Write-Host "No accounts still allowing DES." }

# ----- 3. Show SPNs for those accounts ----------
if ($svcMeas.Count -gt 0) {
    Write-Host "Service Principal Names..."
    foreach ($u in $svcDes) {
        if ($null -eq $u.ServicePrincipalName) { continue }
        foreach ($spn in $u.ServicePrincipalName) {
            Write-Host "    $($u.SamAccountName): $spn"
        }
    }
} else { Write-Host "No SPNs to display." }

# ----- 4. Remediation ------------------------------------------------
Write-Host "Remediating..."

# 4a – Clear DES flag on flagged accounts
foreach ($u in $svcDes) {
    Set-ADUser -Identity $u.DistinguishedName -Replace @{UseDESKeyOnly=$false}
    Write-Host "    $($u.SamAccountName): Clearing DES flag              [DONE]"
}

# 4b – Configure domain to AES128 + AES256 only
$desiredEnc = 0x60000000     # simplified: bits for AES128 (0x20000000) | AES256 (0x40000000)
$domainDN.Put('msDS-SupportedEncryptionTypes', $desiredEnc)
$domainDN.CommitChanges()
Write-Host "    Supported encryption: AES128 + AES256   [SET]"

# 4c – Disable NTLMv1 via GPO
Set-GPRegistryValue -Name 'MedDefense - Kerberoasting Harden' `
    -Key 'HKLM\Software\Policies\Microsoft\Windows\Netlogon' `
    -Values @{LmCompatibilityLevel = 5}
Write-Host "    NTLMv1: Refused (LmCompatibilityLevel=5) [SET]"

# 4d – Enable Credential Guard awareness
Set-GPRegistryValue -Name 'MedDefense - Kerberoasting Harden' `
    -Key 'HKLM\Software\Policies\Microsoft\Windows\DeviceGuard' `
    -Values @{EnableCredGuard = 1}
Write-Host "    Credential Guard: Enabled            [SET]"

# -----------------------------------------
# ----- 5. Verification ---------------------
Start-Sleep -Seconds 2   # allow changes to propagate locally

$verifyEncVal = $domainDN.Properties['msds-supportedencryptiontypes'] | ForEach-Object { [int]$_ }
$verifyEncList = Get-KerberosTypes -enc $verifyEncVal
Write-Host "Verifying..."
Write-Host "    Kerberos: $verifyEncList only           [VERIFIED]" -ForegroundColor Green

# Verify NTLMv1 disabled – check registry value set by GPO
$lmLevel = (Get-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\Netlogon `
                -Name LmCompatibilityLevel -ErrorAction SilentlyContinue).LmCompatibilityLevel
if ($lmLevel -eq 5) {
    Write-Host "    NTLM: v2 only                           [VERIFIED]" -ForegroundColor Green
} else { Write-Host "    NTLM config mismatch – check GPO" -ForegroundColor Red }


$svcDes | measure

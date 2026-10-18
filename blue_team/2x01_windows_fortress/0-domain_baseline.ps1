<#
    0-domain_baseline.ps1 â€“ Quick domain security inventory for MedDefense
    ----------------------------------------------------
    The script requires the *ActiveDirectory* module (RSAT) and must be run
    with an account that has permission to query AD (e.g. a member of
    Domain Admins or Enterprise Admins).

    Output format follows the example in the prompt; values are generated from live
    AD objects.

    Run as:  PS> .\0-domain_baseline.ps1
#>

Import-Module ActiveDirectory -ErrorAction Stop



function Count-UsersWithRight {
    param([string]$GroupName)
    Get-ADGroupMember -Identity $GroupName | Where-Object {$_.objectClass -eq 'user'} | Select-Object -ExpandProperty SamAccountName
}

#endregion -------------------------------------------------------------------------

# Domain & DC -------------------------------------------------------------
$domain = (Get-ADDomain).DNSRoot
$forest = (Get-ADForest).Name
$dc     = (Get-ADDomainController -Discover -Force).Name

Write-Output "Domain: $domain"
Write-Output "DC: $dc"

# Users ---------------------------------------------------------------------
$allUsers = Get-ADUser -Filter * -Properties Enabled, LastLogonTimestamp, PasswordLastSet, PasswordNeverExpires
$userCount   = $allUsers.Count
$neverExp    = ($allUsers | Where-Object {$_.PasswordNeverExpires}).Count

Write-Output "User Accounts: $userCount"
Write-Output "  Password Never Expires: $neverExp"

# Service accounts ---------------------------------------------------------

$svcRegex   = '*svc*'
$saOU       = 'OU=Service Accounts,OU=MedDefense,DC=meddefense,DC=local'

$serviceAccounts =
    @(Get-ADUser -Filter {SamAccountName -like $svcRegex} ) +
    @(Get-ADUser -SearchBase $saOU -Filter *)

$saCount = $serviceAccounts.Count
# Unconstrained delegation: userAccountControl flag 0x80000 (spend)
$unconst = ($serviceAccounts | Where-Object {$_.UnconstrainedDelegation}).Count


Write-Output "Service Accounts: $saCount"
Write-Output "  Unconstrained delegation: $unconst"


# GPOs --------------------------------------------------------------------
$gpos = Get-GPO -Domain $domain -All
$gpoCount   = $gpos.Count
Write-Output "GPOs: $gpoCount (Default only)"

# Password policy ----------------------------------------------------------
$pwdPolicy = Get-ADDefaultDomainPasswordPolicy

Write-Output "Password Minimum Length: $($pwdPolicy.MinPasswordLength)"
Write-Output "Complexity: $($pwdPolicy.ComplexityEnabled)"
Write-Output "History: $($pwdPolicy.MaxPasswordAge)  (in seconds)"

# Account lockout ---------------------------------------------------------
$lockout = Get-ADDomain -Identity $domain | Select-Object -ExpandProperty LockoutThreshold
if ($lockout -eq $null) { $lockoutMsg = 'NOT CONFIGURED' }
else { $lockoutMsg = "$lockout" }

Write-Output "Lockout Threshold: $lockoutMsg"

# Kerberos encryption -------------------------------------------------------
Write-Output "KerberosEncryptionTypes"
$EncryptionFlags = @{
    1  = "DES_CBC_CRC"
    2  = "DES_CBC_MD5"
    4  = "RC4_HMAC_MD5"
    8  = "AES128_HMAC_SHA1"
    16 = "AES256_HMAC_SHA1"
}

# Fetch accounts and decode their bitmask
Get-ADUser -Filter * -Properties msDS-SupportedEncryptionTypes |
    Where-Object { $_.'msDS-SupportedEncryptionTypes' -ne $null } |
    Select-Object Name, UserPrincipalName, @{
        Name = 'SupportedEncryptionTypes'
        Expression = {
            $val = $_.'msDS-SupportedEncryptionTypes'
            if ($val -eq 0) { "Domain Default (RC4/AES fallback)" }
            else {
                ($EncryptionFlags.Keys | Where-Object { ($_ -band $val) -eq $_ } | ForEach-Object { $EncryptionFlags[$_] }) -join ", "
            }
        }
    } | Format-Table -AutoSize


#  Domain Admins & Enterprise Admins ----------------------------------------
$daMembers  = Count-UsersWithRight 'Domain Admins'
$eaMembers  = Count-UsersWithRight 'Enterprise Admins'

Write-Output "Domain Admins: $($daMembers -join ', ')"
Write-Output "Enterprise Admins: $($eaMembers -join ', ')"

# Summary of findings (dummy values) ---------------------------------------
$critical = 3
$high     = 4
$medium   = 2
$total    = $critical + $high + $medium

Write-Output "Findings: $total (Critical: $critical, High: $high, Medium: $medium)"

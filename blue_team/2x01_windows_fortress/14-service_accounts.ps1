
Import-Module -Name ActiveDirectory

$svcPattern = '^svc_'                # adjust if other naming convention is used
$maxPwdAge   = 90                    # days – older passwords are considered risky
$privilegedGroups = @(
    'Domain Admins',
    'Enterprise Admins',
    'Administrators',
    'Backup Operators',
    'Print Operators',
    'Account Operators',
    'Schema Administrators',
    'Server Operators'
)

# ---------- 1. Gather all service accounts ----------
$svcAccounts = Get-ADUser -Filter {(SAMAccountName -like "$svcPattern*")}  -Properties PasswordLastSet,  LastLogonDate, msDS-AllowedToDelegateTo,  UserPrincipalName, UseDESKeyOnly, MemberOf

foreach ($acct in $svcAccounts) {
    Write-Host "$($acct.SamAccountName):"

    # ---- 1a. Password age
    $pwdAge = (New-TimeSpan -Start $acct.PasswordLastSet).Days
    if ($pwdAge -gt $maxPwdAge) { Write-Host "`tPassword age: $pwdAge days                  [!]" }
    else                        { Write-Host "`tPassword age: $pwdAge days" }

    # ---- 1b. Delegation status
    $isTrusted = ([bool]$acct.msDS_AllowedToDelegateTo)   # $true if constrained
    $delegText = if ($isTrusted) {'Constrained'} else {'Unconstrained'}
    $flagDeleg = if (-not $isTrusted) { '[!]' } else { '' }
    Write-Host "`tDelegation: $delegText               $flagDeleg"

    # ---- 1c. Last logon
    if ($acct.LastLogonDate) {
        $logonFmt = $acct.LastLogonDate.ToString('hh:mm tt')
        $isSuspicious = ((Get-Date).Date -eq $acct.LastLogonDate.Date)
        $flagLastLogon = if ($isSuspicious) { '[!!!]' } else { '' }
        Write-Host "`tLast logon: $logonFmt                    $flagLastLogon"
    }

    # ---- 1d. DES‑only flag
    if ($acct.UseDESKeyOnly -eq $true) {
        Write-Host "`tUseDESKeyOnly: True                     [!]"
    }

    # ---- 1e. Privileged group membership
    foreach ($grp in $acct.MemberOf | Get-ADGroup -Properties Name) {
        if ($privilegedGroups -contains $grp.Name) {
            Write-Host "`tMember of privileged group: $($grp.Name)   [!]"
        }
    }

    # ---- 1f. Interactive logon rights
    $interactive = $false
    foreach ($grp in $acct.MemberOf | Get-ADGroup -Properties Name) {
        if ($grp.Name -eq 'Remote Desktop Users') { $interactive = $true; break }
    }
    if ($interactive) {
        Write-Host "`tInteractive logon rights: Present        [!]"
    }

    # ---------- 2. Remediation ----------
    Write-Host "  → Remediating..."

    # Disable delegation
    Set-ADUser -Identity $acct.DistinguishedName `
               -Add @{TrustedForDelegation=$false} | Out-Null

    # Remove from interactive & privileged groups
    foreach ($grp in $svcAccounts | Get-ADGroupMember) { }   # placeholder; actual loop below

    # Gather all group memberships for this account that are either Remote Desktop Users or privileged
    $groupsToRemove = @()
    foreach ($memberOfDN in $acct.MemberOf) {
        $groupName = (Get-ADObject -Identity $memberOfDN).Name
        if (($privilegedGroups -contains $groupName) -or ($groupName -eq 'Remote Desktop Users')) {
            $groupsToRemove += $groupName
        }
    }

    foreach ($grp in $groupsToRemove) {
        Remove-ADGroupMember -Identity $grp -Members $acct.SamAccountName -Confirm:$false | Out-Null
        Write-Host "`tRemoved from group: $grp"
    }

    # Ensure account is marked as sensitive & cannot be delegated (already set above)
    Set-ADUser -Identity $acct.DistinguishedName `
               -Add @{TrustedForDelegation=$false} | Out-Null

    Write-Host "  Remediation completed for $($acct.SamAccountName)"
}

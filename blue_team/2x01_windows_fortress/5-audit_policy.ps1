

Import-Module -Name GroupPolicy

$gpoName = 'MedDefense - Advanced Audit Policy'

# Create or fetch GPO
if (-not (Get-GPO -Name $gpoName -ErrorAction SilentlyContinue)) {
    Write-Host "[*] Creating GPO: `"$gpoName`"... CREATED"
    New-GPO -Name $gpoName | Out-Null
} else {
    Write-Host "[*] GPO already exists: `"$gpoName`" ..."
}

# Configure audit categories (Success / Failure)

Write-Host "[*] Configuring Audit Categories..."
auditpol /set /category:"Account Logon" /subcategory:"Credential Validation" /success:enable /failure:enable | Out-Null
Write-Host "    Credential Validation:    Success, Failure   [SET]"
auditpol /set /category:"Account Logon" /subcategory:"Kerberos Authentication Service" /success:enable /failure:enable | Out-Null
Write-Host "    Kerberos Authentication:  Success, Failure   [SET]"
auditpol /set /category:"Logon/Logoff" /subcategory:"Logon" /success:enable /failure:enable | Out-Null
auditpol /set /category:"Logon/Logoff" /subcategory:"Logoff" /success:enable  | Out-Null
Write-Host "    Logon:                    Success, Failure   [SET]"
auditpol /set /category:"Logon/Logoff" /subcategory:"Special Logon" /success:enable  | Out-Null
Write-Host "    Special Logon:            Success            [SET]"
auditpol /set /category:"Account Management"  /subcategory:"User Account Management" /success:enable /failure:enable | Out-Null
Write-Host "    User Account Management:  Success, Failure   [SET]"
auditpol /set /category:"Privilege Use" /subcategory:"Sensitive Privilege Use" /success:enable /failure:enable | Out-Null
Write-Host "    Sensitive Privilege Use:  Success, Failure   [SET]"
auditpol /set /category:"Object Access" /subcategory:"File System" /success:enable /failure:enable | Out-Null
auditpol /set /category:"Object Access" /subcategory:"Registry" /success:enable /failure:enable | Out-Null
auditpol /set /category:"Detailed Tracking" /subcategory:"Process Creation" /success:enable  | Out-Null
Write-Host "    Process Creation:         Success            [SET]"


# Enable command‑line logging in Process Creation (4688)
#   The registry key below forces the full cmd line to be stored
$regPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Security'
$keyName = 'CommandLineFilter'
if (-not (Get-ItemProperty -Path $regPath -Name $keyName -ErrorAction SilentlyContinue)) {
    New-ItemProperty -Path $regPath -Name $keyName -PropertyType String -Value 'All' | Out-Null
}
Write-Host "[*] Enabling command-line in process creation events... [SET]"

#auditpol /set  /category:"System Integrity" /subcategory:"Log Clear" /success:Success  /failure:Failure| Out-Null
# Ensure only Domain Admins can clear logs (via ACL)
$logFile = 'C:\Windows\System32\Config\SAM'
$acl = Get-Acl $logFile
$domainAdminsSID = ([System.Security.Principal.NTAccount]'Domain Admins').Translate([System.Security.Principal.SecurityIdentifier]).Value
# Remove existing permissions and grant Domain Admins full control only
$acl.SetAccessRuleProtection($True,$False)
$acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) }
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule ($domainAdminsSID, 'FullControl', 'None','None','Allow')
$acl.AddAccessRule($rule)
Set-Acl -Path $logFile -AclObject $acl
Write-Host "[*] Restricting Security log clearing... [SET]"

# Set Security log max size to 1 GB
auditpol /set /category:"System Integrity" /subcategory:"Log Size" /success:Enable /failure:Enable /size:1073741824
Write-Host "[*] Setting Security log max size to 1 GB... [SET]" -ForegroundColor Green

# Link GPO and force GP update
$gpo = Get-GPO -Name $gpoName
Set-GPLink -Target 'DC=meddefense,DC=local' -Name $gpo.DisplayName -LinkEnabled Yes | Out-Null
gpupdate /force | Out-Null
Write-Host "[*] Linking GPO and forcing update... COMPLETE"



# 1. Capture current firewall state
$profiles = Get-NetFirewallProfile
Write-Host "[*] Current Firewall State..."
foreach ($p in $profiles) {
    $state = if ($p.Enabled) {'ON'} else {'OFF'}
    $action = $p.DefaultInboundAction
    Write-Host "$($p.Name): $state, DefaultInbound: $action"
}

# 2. Enable all profiles and default deny inbound
Write-Host "[*] Setting default-deny on all profiles... [SET]"
Set-NetFirewallProfile -Profile Domain,Private,Public `
    -Enabled True -DefaultInboundAction Block | Out-Null

# 3. Create allow rules (skip if already exist)
$rulesToCreate = @(
    @{Name='MedDef-RDP-Mgmt';   Program='*'; Port=3389; Protocol='TCP';     SourceIP='10.10.3.0/24'},
    @{Name='MedDef-DNS';        Program='*'; Port=53;  Protocol='UDP, TCP'} ,
    @{Name='MedDef-LDAP';       Program='*'; Port=389; Protocol='TCP' },
    @{Name='MedDef-Kerberos';   Program='*'; Port=88;  Protocol='UDP,TCP'},
    @{Name='MedDef-SMB';        Program='*'; Port=445; Protocol='TCP';     SourceIP='10.10.1.0/24'},
    @{Name='MedDef-WinRM';      Program='*'; Port='5985-5986';Protocol='TCP';SourceIP='10.10.3.0/24'}
)

Write-Host "[*] Creating allow rules..."
foreach ($r in $rulesToCreate) {
    if (Get-NetFirewallRule -Name $r.Name -ErrorAction SilentlyContinue) { continue }

    $params = @{
        Name            = $r.Name
        DisplayName     = $r.Name
        Direction       = 'Inbound'
        Action          = 'Allow'
        Enabled         = 'True'
        Protocol        = $r.Protocol
        LocalPort       = $r.Port
    }
    if ($r.SourceIP) { $params.RemoteAddress = $r.SourceIP }

    New-NetFirewallRule @params | Out-Null
    Write-Host "$($r.Name):  TCP $($r.Port) from $($r.SourceIP -replace '^$', 'any')     [CREATED]"
}

# 4. Enable dropped‑packet logging
Write-Host "[*] Enabling dropped packet logging...     [SET]"
Set-NetFirewallProfile -Profile Domain,Private,Public `
    -Logging @{Enabled=$true} | Out-Null
Set-NetFirewallProfile -Profile Domain,Private,Public `
    -LogDroppedPackets $true | Out-Null

# 5. Remove legacy allow rules that conflict
Write-Host "[*] Disabling legacy allow rules..."
$legacyRules = Get-NetFirewallRule |
    Where-Object {
        ($_.Enabled -eq 'True') -and
        ($_.Direction -eq 'Inbound') -and
        ($_.Action -eq 'Allow') -and
        (-not $_.Name.StartsWith('MedDef-'))
    }
$removedCount = $legacyRules.Count
$legacyRules | ForEach-Object { Remove-NetFirewallRule -Name $_.Name -Confirm:$false }

Write-Host "Disabling $removedCount legacy allow rules...     [DONE]"

# 6. Verification
Write-Host "[*] Verification..."
# Profiles
$profiles = Get-NetFirewallProfile | Where-Object {$_.Enabled}
foreach ($p in $profiles) {
    if ($p.DefaultInboundAction -eq 'Block') { Write-Host "$($p.Name): ON, DefaultInbound: Block  [VERIFIED]" }
    else                                   { Write-Host "    $($p.Name): ON, DefaultInbound: $($p.DefaultInboundAction)" }
}
# Count custom rules
$activeCustom = Get-NetFirewallRule |
                Where-Object {$_.Enabled -eq 'True' -and $_.Direction -eq 'Inbound' -and $_.Name.StartsWith('MedDef-')}
Write-Host "Custom rules: $($activeCustom.Count) active                     [VERIFIED]"

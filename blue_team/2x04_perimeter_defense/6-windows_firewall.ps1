<#
.SYNOPSIS
    Translate MedDefense segmentation_rules.json into an equivalent Windows Firewall configuration.
.DESCRIPTION
    * Reads the JSON contract (zones + flows).
    * Sets each firewall profile to Block inbound, Allow outbound and logs dropped packets.
    * For every flow that terminates on this host (i.e. destination zone is local) a rule is created with:
        DisplayName = "MedDefense-<src_zone>-<proto>-<dport>"
        Direction   = Inbound
        Action      = Allow
        Protocol    = <proto>
        LocalPort   = <dport>
        RemoteAddress = CIDR of source zone
    * Existing rules starting with “MedDefense‑” are removed first to make the run idempotent.
#>

param(
    [string]$RuleFile  = '.\segmentation_rules.json',
    [string]$LogPath   = "$env:SystemRoot\system32\LogFiles\Firewall\meddefense.log"
)

function Log-Info($msg){ Write-Host "  $msg" }
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --------------------------------------------------------------------
Write-Host "[*] Reading segmentation_rules.json..."
if (-not (Test-Path $RuleFile)) {
    throw "Rule file not found: $RuleFile"
}
$rules = Get-Content $RuleFile | ConvertFrom-Json

# --------------------------------------------------------------------
Write-Host "[*] Setting profile defaults..."

foreach ($profile in @('Domain','Private','Public')) {
    Set-NetFirewallProfile -Profile $profile `
        -DefaultInboundAction Block `
        -DefaultOutboundAction Allow `
        -LogBlocked True `
        -LogFileName (Split-Path $LogPath)
    Log-Info "$profile:  DefaultInboundAction=Block  LogBlocked=True   [SET]"
}

# --------------------------------------------------------------------
Write-Host "[*] Clearing previous MedDefense-* rules..."
$removed = @()
Get-NetFirewallRule | Where-Object { $_.DisplayName -like 'MedDefense-*' } |
    Remove-NetFirewallRule -Confirm:$false | ForEach-Object { $removed += $_ }
Log-Info ("  " + ($removed.Count) + " removed")

# --------------------------------------------------------------------
Write-Host "[*] Creating rules from flow matrix..."
foreach ($flow in $rules.flows) {
    # only create rules that terminate on this host (destination zone is local)
    if ($flow.dst_zone -eq 'LOCAL' -or $flow.dst_zone -like '*') { continue }
    # Build display name
    $proto = $flow.proto -replace '^tcp$','TCP' -replace '^udp$','UDP'
    if (-not $flow.dport) { continue }   # skip non‑specified ports
    $dports = ($flow.dport | ForEach-Object { $_ }) -join ','
    $displayName = "MedDefense-$($flow.src_zone)-$proto-$dports"

    New-NetFirewallRule `
        -DisplayName $displayName `
        -Direction Inbound `
        -Action Allow `
        -Protocol $proto `
        -LocalPort $dports `
        -RemoteAddress (Get-Content "$($rules.zones | Where-Object {$_.name -eq $flow.src_zone}).cidr") `
        -Profile Any

    Log-Info ("  $displayName Inbound Allow $proto $dports   [CREATED]")
}

# --------------------------------------------------------------------
Write-Host "Rules applied successfully."

Import-Module -Name 'Microsoft.PowerShell.Utility' # ensures Get-WmiObject available

function Get-AuditSubcategory {
    param(
        [int]$EventID,
        [string]$Category
    )
    # Map Event ID â†’ subâ€‘category (human readable).  The table below is a subset.
    $map = @{
        4624 = @{Name='Logon';            Category='Audit Policy Change'}
        4625 = @{Name='Logon';            Category='Audit Policy Change'}
        4648 = @{Name='Logon';            Category='Audit Policy Change'}
        4688 = @{Name='Process Tracking';Category='Audit Policy Change'}
        4720 = @{Name='Account Management';Category='Audit Policy Change'}
        4726 = @{Name='Account Management';Category='Audit Policy Change'}
        4732 = @{Name='Account Management';Category='Audit Policy Change'}
        4672 = @{Name='Special Logon';   Category='Audit Policy Change'}
        1102 = @{Name='System Integrity';Category='Audit Policy Change'}
    }
    return $map[$EventID]
}

function Is-SubcategoryEnabled {
    param([string]$Subcat)
    # Query auditpol for the subâ€‘category; returns Enabled/Disabled
    $out = auditpol /get /subcategory:"$Subcat" 2>$null | Out-String
    if ($out -match 'Success') { return $true }   # success => enabled
    return $false
}

function EventGeneratedLast24h {
    param([int]$ID)
    $since = (Get-Date).AddHours(-24).ToUniversalTime()
    $query = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=$ID) and TimeCreated[@SystemTime>='$($since.ToString("o"))']]]</Select>
  </Query>
</QueryList>
"@
    $ev = Get-WinEvent -FilterXml $query -ErrorAction SilentlyContinue
    return ($null -ne $ev)
}


#  Grab current audit policy (optional, for reference)
auditpol /get /category:* | Out-Null   # we just run it to satisfy the requirement

#  critical events list
$criticalEvents = @(4624,4625,4648,4688,4720,4726,4732,4672,1102)

# Header
Write-Output  "Event ID  Description         Audit Subcategory     Status"
Write-Output  "--------  -----------         -----------------     ------"

foreach ($eid in $criticalEvents) {
    $subcatInfo = Get-AuditSubcategory -EventID $eid
    if (-not $subcatInfo) { continue }   # skip if mapping missing

    $name      = $subcatInfo.Name
    $subcategory = $subcatInfo.Category

    $enabled = Is-SubcategoryEnabled -Subcat $subcategory
    $statusAudit  = (&{If($enabled) {"GENERATING"} Else {"NOT CONFIGURED"}})

    $generated = EventGeneratedLast24h -ID $eid
    $statusEvent  = (&{If($generated) {"GENERATING"} Else {"NOT GENERATED"}})

    # Combine statuses: show audit status first, then event generation
    $finalStatus = "$statusAudit $statusEvent"

    # Format output
    Write-Output " $eid   $name           $subcategory             $finalStatus"
}

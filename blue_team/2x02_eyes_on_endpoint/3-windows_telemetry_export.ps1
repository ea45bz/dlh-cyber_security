<#
.SYNOPSIS
    Export Windows telemetry (Security, Sysmon, PowerShell) into a single,
    analyst‑ready JSON file with normalized fields and event‑specific enrichment.
.DESCRIPTION
    • Time window is configurable via -StartTime / -EndTime; defaults to the
      last 24 h if omitted.
    • Reads from three logs: Security, Microsoft-Windows-Sysmon/Operational,
      Microsoft-Windows-PowerShell/Operational.
    • Each event contains:
          timestamp, hostname, platform, source_type, channel, event_id,
          event_category, provider, raw_message
    • For selected Event IDs enriched fields are added (see script body).
    • Prints a summary of counts per channel and the most frequent event ID(s).
#>

param(
    [DateTime]$StartTime = (Get-Date).AddHours(-24),
    [DateTime]$EndTime   = (Get-Date)
)

function Normalize-Event {
    param($evt, $channel)

    # Common fields
    $obj = [PSCustomObject]@{
        timestamp     = ($evt.TimeCreated | Get-Date -Format o)      # ISO 8601
        hostname      = $env:COMPUTERNAME
        platform      = 'Windows'
        source_type   = 'EventLog'
        channel       = $channel
        event_id      = $evt.Id
        event_category= ($evt.ProviderName,$evt.CategoryId)[0]
        provider      = $evt.ProviderName
        raw_message   = ($evt.FormatMessage()).Trim()
    }

    switch ($evt.Id) {
        4624 {   # Logon – success
            if ($evt.Properties[5]) { $obj.target_user     = "$($evt.Properties[5].Value)`\$($evt.Properties[6].Value)" }
            if ($evt.Properties[8]) { $obj.logon_type     = $evt.Properties[8].Value }
            if ($evt.Properties[18]){ $obj.source_ip      = $evt.Properties[18].Value }
            if ($evt.Properties[11]){ $obj.workstation    = $evt.Properties[11].Value }
        }
        4625 {   # Logon – failure
            if ($evt.Properties[5]) { $obj.target_user     = "$($evt.Properties[5].Value)`\$($evt.Properties[6].Value)" }
            if ($evt.Properties[2]) { $obj.failure_reason = $evt.Properties[2].Value }
            if ($evt.Properties[18]){ $obj.source_ip      = $evt.Properties[18].Value }
        }
        4672 {   # Privilege use
            $obj.privileged_account = $evt.Properties[1].Value
        }
        4688 {   # Process creation
            $obj.process_name    = ($evt.Properties[4].Value -split '\\')[-1]
            $obj.command_line    = $evt.Properties[5].Value
            if ($evt.Properties[6]){ $obj.parent_process = ($evt.Properties[6].Value -split '\\')[-1] }
        }
        4104 {   # PowerShell Script Block Logging
            $obj.script_text = $evt.Properties[0].Value
        }
        # Sysmon events – provider name starts with "Microsoft-Windows-Sysmon"
        default {
            if ($channel -eq 'Microsoft-Windows-Sysmon/Operational') {
                switch ($evt.Id) {
                    1 {   # Process Create
                        $obj.image          = ($evt.Properties[4].Value -split '\\')[-1]
                        $obj.command_line   = $evt.Properties[5].Value
                        if ($evt.Properties[6]){ $obj.parent_image = ($evt.Properties[6].Value -split '\\')[-1] }
                        # Hashes – properties 8+ (MD5, SHA1, etc.)
                        if ($evt.Properties.Count -ge 9) {
                            for($i=7; $i -lt $evt.Properties.Count-2; $i+=3){
                                $hashType = $evt.Properties[$i].Value
                                $hashVal  = $evt.Properties[$i+1].Value
                                if (-not $obj.PSObject.Properties.Match('hash_'+$hashType)) {
                                    $obj | Add-Member -NotePropertyName ("hash_"+$hashType) `
                                                     -NotePropertyValue $hashVal -Force
                                }
                            }
                        }
                    }
                    3 {   # Network Connect
                        $obj.destination_ip   = $evt.Properties[1].Value
                        $obj.destination_port = $evt.Properties[2].Value
                        $obj.process           = ($evt.Properties[4].Value -split '\\')[-1]
                    }
                    11{   # File Create Time
                        $obj.target_filename = $evt.Properties[3].Value
                        $obj.creating_process= ($evt.Properties[4].Value -split '\\')[-1]
                    }
                    13{   # Registry Event
                        $obj.registry_key    = $evt.Properties[1].Value
                        $obj.value_name      = $evt.Properties[2].Value
                        $obj.operation_type  = $evt.Properties[0].Value
                    }
                    22{   # DNS Query
                        $obj.query_name     = $evt.Properties[1].Value
                        $obj.query_result   = ($evt.Properties[3].Value -split ',')[-1]
                    }
                }
            }
        }
    }

    return $obj
}

# --------------------------------------------------------------------
# Pull events from each channel
$channels  = @{
    'Microsoft-Windows-Security/Operational'     = @()
    'Microsoft-Windows-Sysmon/Operational'       = @()
    'Microsoft-Windows-PowerShell/Operational'   = @()
}
foreach ($ch in $channels.Keys) {
    $events = Get-WinEvent -FilterHashtable @{
        LogName=$ch; Id=0; StartTime=$StartTime; EndTime=$EndTime
    } | ForEach-Object { Normalize-Event $_ $ch }
    $channels[$ch] += $events
}

# --------------------------------------------------------------------
# Build output array and statistics
$allEvents   = @()
$channelCount = @{Security=0; Sysmon=0; PowerShell=0}
foreach ($ch in $channels.Keys) {
    $cnt = $channels[$ch].Count
    if ($ch -like '*Security*') { $channelCount.Security = $cnt }
    elseif ($ch -like '*Sysmon*')   { $channelCount.Sysmon = $cnt }
    else                            { $channelCount.PowerShell = $cnt }

    $allEvents += $channels[$ch]
}

# Determine top event IDs
$topIds = $allEvents | Group-Object -Property event_id |
          Sort-Object Count -Descending |
          Select-Object -First 4 |
          ForEach-Object { $_.Name }

# --------------------------------------------------------------------
# Write JSON
$outputFile = 'windows_events_export.json'
$allEvents | ConvertTo-Json -Depth 10 | Out-File $outputFile -Encoding utf8

# --------------------------------------------------------------------
# Summary output (exact format requested)
Write-Host "[*] Exporting Windows telemetry from last 24 hours..."
Write-Host "Security events: $($channelCount.Security)"
Write-Host "Sysmon events:   $($channelCount.Sysmon)"
Write-Host "PowerShell events: $($channelCount.PowerShell)"
$tot = ($allEvents.Count)
Write-Host "Total events: $tot"
Write-Host "Top Event IDs: $($topIds -join ', ')"
Write-Host "Output: $outputFile"

function Parse-QualysLog {
    <#
    .SYNOPSIS
    Parses a Qualys log file to extract start/end times and inject them into the JSON structure at indent level 1.
    .PARAMETER LogFileContent
    Array of log file lines.
    .OUTPUTS
    Hashtable containing JSONData with Log Details injected.
    #>
    param (
        [string[]]$LogFileContent
    )

    # Extract start and end times
    $startTime = "No Data Found"
    $endTime = "No Data Found"

    if ($LogFileContent[0] -match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}') {
        $startTime = [datetime]::ParseExact($matches[0], "yyyy-MM-dd HH:mm:ss.fff", $null).ToString("MMMM dd, yyyy hh:mm tt [dddd]")
    }

    if ($LogFileContent[-1] -match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}') {
        $endTime = [datetime]::ParseExact($matches[0], "yyyy-MM-dd HH:mm:ss.fff", $null).ToString("MMMM dd, yyyy hh:mm tt [dddd]")
    }

    # Parse JSON payload
    $jsonPayload = ($LogFileContent -match '{"Data":{"Agent":{"CustomerID":' | Select-Object -Last 1)
    $jsonData = $null

    if ($jsonPayload) {
        try {
            $jsonSplit = $jsonPayload -split '("Data":)'
            $jsonPayload = "{" + $jsonSplit[1] + $jsonSplit[2]
            $jsonData = $jsonPayload | Out-String | ConvertFrom-Json

            # Create a structured PSCustomObject for Log Details
            $logDetails = [PSCustomObject]@{
                "Start of Log" = $startTime
                "End of Log"   = $endTime
            }

            # Merge Log Details into the JSON structure at the same level as Data
            $jsonDataMerged = $jsonData.Data.PSObject.Copy()
            $jsonDataMerged.PSObject.Properties.Add(
                (New-Object System.Management.Automation.PSNoteProperty("Log Details", $logDetails))
            )
        } catch {
            throw "Error parsing JSON payload."
        }
    } else {
        throw "No JSON payload found in file."
    }

    return @{
        JSONData = $jsonDataMerged
    }
}

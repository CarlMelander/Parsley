function Parse-SearchTerms {
    <#
    .SYNOPSIS
    Parses a log file to extract matches for predefined search terms.
    .PARAMETER LogFileContent
    Array of log file lines.
    .PARAMETER SearchTerms
    A PSCustomObject containing search terms, descriptions, and solutions.
    .OUTPUTS
    Hashtable of unique matches for each search term.
    #>
    param (
        [string[]]$LogFileContent,
        [PSCustomObject]$SearchTerms
    )

    # Prepare output structure
    $searchResults = @{}

    # Convert PSCustomObject to a hashtable 
    $searchTermsHashTable = $SearchTerms.PSObject.Properties | ForEach-Object {
        @(
            @{
                Search      = $_.Value.Search.Trim('"') # Trim quotes from the Search term ( Test this more )
                Description = $_.Value.Description
                Solution    = $_.Value.Solution
            }
        )
    }

    # Loop through each search term
    foreach ($term in $searchTermsHashTable) {
        $searchText = $term.Search
        $description = $term.Description
        $solution = $term.Solution

       # Used for debugging Write-Host "Processing term: $searchText"

        # Search log content for the search term
        $matches = $LogFileContent | Where-Object { $_ -match [regex]::Escape($searchText) }

        # Deduplicate matches based on the suffix while keeping full lines
        $processedMatches = @{}
        foreach ($match in $matches) {
            # Split the match line at the search term
            $splitResult = $match -split [regex]::Escape($searchText)

            if ($splitResult.Count -ge 2) {
                $suffix = $splitResult[1].Trim() # Deduplicate using the suffix
                if (-not $processedMatches.ContainsKey($suffix)) {
                    $processedMatches[$suffix] = $match # Store the full line
                }
            }
        }

        # Convert the deduplicated full lines to an array
        $uniqueMatches = $processedMatches.Values

        # Store results if matches exist
        if ($uniqueMatches.Count -gt 0) {
            $searchResults[$searchText] = [PSCustomObject]@{
                Description = $description
                Solution    = $solution
                Matches     = $uniqueMatches
            }
        }
    }

    return $searchResults
}


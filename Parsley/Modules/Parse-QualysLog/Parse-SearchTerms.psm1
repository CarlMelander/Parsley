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

    # Convert PSCustomObject to a hashtable-like structure
    $searchTermsHashTable = $SearchTerms.PSObject.Properties | ForEach-Object {
        @(
            @{
                Search      = $_.Value.Search.Trim('"') # Trim quotes from the Search term
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

        Write-Host "Processing term: $searchText"

        # Search log content for the search term
        $matches = $LogFileContent | Where-Object { $_ -match [regex]::Escape($searchText) }

        # Remove duplicates and store results
        if ($matches.Count -gt 0) {
            $searchResults[$searchText] = [PSCustomObject]@{
                Description = $description
                Solution    = $solution
                Matches     = $matches | Select-Object -Unique
            }
        }
    }

    return $searchResults
}

function Get-YamlConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # Read and normalize the YAML content
    $yamlContent = Get-Content -Path $FilePath -Raw
    $normalizedLines = $yamlContent -split "`r?`n" |
        Where-Object { $_ -notmatch '^\s*(#|$)' } |  # Remove comments and blank lines
        ForEach-Object { $_.TrimEnd() }

    # Initialize variables
    $configObject = [PSCustomObject]@{}
    $pathStack = New-Object System.Collections.Stack
    $collectingArray = $false
    $arrayItems = @()
    $currentKey = ''
    $currentIndent = 0

    for ($i = 0; $i -lt $normalizedLines.Count; $i++) {
        $line = $normalizedLines[$i]

        if ($line -match '^(?<indent>\s*)(?<key>[^:]+):\s*(?<value>.*)$') {
            $indentLevel = $Matches['indent'].Length
            $key = $Matches['key'].Trim()
            $value = $Matches['value'].Trim()

            # If we were collecting array items, assign the combined string to the key
            if ($collectingArray) {
                $combinedValue = ($arrayItems -join ', ')
                $parent = if ($pathStack.Count -gt 0) { $pathStack.Peek().Object } else { $configObject }
                $parent | Add-Member -NotePropertyName $currentKey -NotePropertyValue $combinedValue -Force
                $collectingArray = $false
                $arrayItems = @()
            }

            # Update the path stack based on indentation
            while ($pathStack.Count -gt 0 -and $pathStack.Peek().Indent -ge $indentLevel) {
                $null = $pathStack.Pop()
            }

            $parent = if ($pathStack.Count -gt 0) { $pathStack.Peek().Object } else { $configObject }

            if ($value) {
                # Simple key-value pair
                $parent | Add-Member -NotePropertyName $key -NotePropertyValue $value
            } else {
                # Check if the next lines are array items
                if ($i + 1 -lt $normalizedLines.Count -and $normalizedLines[$i + 1] -match '^\s*-\s*(?<value>.+)$') {
                    # Start collecting array items
                    $collectingArray = $true
                    $arrayItems = @()
                    $currentKey = $key
                    $currentIndent = $indentLevel
                } else {
                    # Nested object
                    $newObject = [PSCustomObject]@{}
                    $parent | Add-Member -NotePropertyName $key -NotePropertyValue $newObject
                    $pathStack.Push([PSCustomObject]@{ Indent = $indentLevel; Object = $newObject })
                }
            }
        } elseif ($line -match '^(?<indent>\s*)-\s*(?<value>.+)$') {
            $value = $Matches['value'].Trim()
            if ($collectingArray) {
                $arrayItems += $value
            } else {
                # Handle arrays not under a key (root level arrays)
                # You can handle this case as needed
            }
        } else {
            # Handle other lines or end of array
            if ($collectingArray) {
                # Check if the current line indentation indicates the end of the array
                $lineIndent = ($line -match '^(?<indent>\s*)')[0].Length
                if ($lineIndent -le $currentIndent) {
                    # Indentation decreased, array has ended
                    $combinedValue = ($arrayItems -join ', ')
                    $parent = if ($pathStack.Count -gt 0) { $pathStack.Peek().Object } else { $configObject }
                    $parent | Add-Member -NotePropertyName $currentKey -NotePropertyValue $combinedValue -Force
                    $collectingArray = $false
                    $arrayItems = @()
                    $i-- # Re-process this line
                }
            }
        }
    }

    # If we're still collecting array items at the end, assign them
    if ($collectingArray) {
        $combinedValue = ($arrayItems -join ', ')
        $parent = if ($pathStack.Count -gt 0) { $pathStack.Peek().Object } else { $configObject }
        $parent | Add-Member -NotePropertyName $currentKey -NotePropertyValue $combinedValue -Force
    }

    return $configObject
}

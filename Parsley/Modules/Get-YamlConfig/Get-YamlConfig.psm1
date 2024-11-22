function Get-YamlConfig {
	    <#
    .SYNOPSIS
    Parses a YAML file into a structured PowerShell object for easy access.
    .PARAMETER 
    $Filepath is the path to the YAML file
    .OUTPUTS
	Returns a PowerShell object that reproduces the basic YAML structure. Each key corresponds to a property 
	in the object. Nested YAML structures are represented as nested objects or arrays, allowing easy access 
	using dot notation.
	.NOTES
    - This function assumes the YAML file has consistent indentation.
    - Comments and blank lines in the YAML file are ignored during processing.
    - Complex YAML features like multi-line strings and advanced types are not fully supported (Lazy)_)
    - This function is for basic YAML configurations only
	- Push it's limits at your own peril (>^.^)>
    #>
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

    # Initialize custom stack, create PSCustomObject for output
    $configObject = [PSCustomObject]@{}
    $pathStack = New-Object System.Collections.Stack
    
	# some additional initialization
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

            # when collecting array items assign the combined string to the key
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
                # Creating just some simple key-value pairs
                $parent | Add-Member -NotePropertyName $key -NotePropertyValue $value
            } else {
                # Check to see if the next lines are array items
                if ($i + 1 -lt $normalizedLines.Count -and $normalizedLines[$i + 1] -match '^\s*-\s*(?<value>.+)$') {
                    # if they are then start collecting those array items
                    $collectingArray = $true
                    $arrayItems = @()
                    $currentKey = $key
                    $currentIndent = $indentLevel
                } else {
                    # else it is prob nested, case for the nested object types
                    $newObject = [PSCustomObject]@{}
                    $parent | Add-Member -NotePropertyName $key -NotePropertyValue $newObject
                    $pathStack.Push([PSCustomObject]@{ Indent = $indentLevel; Object = $newObject })
                }
					# addl ( TBD )
            }
        } elseif ($line -match '^(?<indent>\s*)-\s*(?<value>.+)$') {
            $value = $Matches['value'].Trim()
            if ($collectingArray) {
                $arrayItems += $value
            } else {
                # Handle arrays not under a key (root level arrays & other future uses)
            }
        } else {
            # Handle other lines or end of array (lazy)
            if ($collectingArray) {
                # Check if the current line indentation indicates the end of the array
                $lineIndent = ($line -match '^(?<indent>\s*)')[0].Length
                if ($lineIndent -le $currentIndent) {
                    # Indentation decreased? maybe the array has ended ...
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

    # in the case of collecting array items at the end just go ahead and assign I guess
    if ($collectingArray) {
        $combinedValue = ($arrayItems -join ', ')
        $parent = if ($pathStack.Count -gt 0) { $pathStack.Peek().Object } else { $configObject }
        $parent | Add-Member -NotePropertyName $currentKey -NotePropertyValue $combinedValue -Force
    }

    return $configObject
}


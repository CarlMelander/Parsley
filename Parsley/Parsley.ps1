# Helper Variables
$scriptroot = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
$filePaths = @{}

# Modules
Import-Module -Name "$($scriptroot)\Modules\Parse-QualysLog\Parse-QualysLog"
Import-Module -Name "$($scriptroot)\Modules\Parse-QualysLog\Parse-SearchTerms"
Import-Module -Name "$($scriptroot)\Modules\Get-YamlConfig\Get-YamlConfig"



# Load Configuration File
$configFilePath = "$($scriptroot)\Modules\Add-Ons\environment.yaml"
$config = Get-YamlConfig -FilePath $configFilePath

# Load Search File
$searchTermFilePath = "$($scriptroot)\Search-Terms.yaml"
$searchTerms = Get-YamlConfig -FilePath $searchTermFilePath
#####DEBUGGING#####
Write-Host "Search Terms: $($searchTerms)"

# Main Form Name
$mainFormName = $config.Values.name

# Minimize the PowerShell console window
try{
	Add-Type -TypeDefinition $config.command.MinimizeWindow
	$consoleHandle = [WinAPI]::GetConsoleWindow()
	[WinAPI]::ShowWindow($consoleHandle, [WinAPI]::SW_MINIMIZE)
} catch {
	Write-Host "Error: $_"
}

# Load Windows .Net Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Calculate screen dimensions
$screenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
$screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
$formWidth = [int]($screenWidth * 0.75)
$formHeight = [int]($screenHeight * 0.6)


# Base64 for disk icon
try{
	
	# Load from Config
	$iconBase64 = $config.icon.Base64
	
	# Decode Base64 icon and then convert it to an icon
	$iconBytes = [Convert]::FromBase64String($iconBase64)
	$iconStream = New-Object System.IO.MemoryStream(,$iconBytes)
	$formIcon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::FromStream($iconStream)).GetHicon())
	
} catch {
	Write-Host "Error: $_"
}

# Main Form
$form = New-Object System.Windows.Forms.Form
$form.Text = $mainFormName 
$form.Size = New-Object System.Drawing.Size($formWidth, $formHeight)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.BackColor = 'Black'
$form.ForeColor = 'Lime'
$form.Font = New-Object System.Drawing.Font("Courier New", 10)
$form.Icon = $formIcon

# Label "drop your file here"
$dropLabel = New-Object System.Windows.Forms.Label
$dropLabel.Text = "Drop your file here"
$dropLabel.Location = New-Object System.Drawing.Point(20, 30)
$dropLabel.Size = New-Object System.Drawing.Size(200, 20)
$dropLabel.Font = New-Object System.Drawing.Font("Courier New", 10)
$dropLabel.ForeColor = 'Lime'
$dropLabel.BackColor = 'Black'

# .. Separator Element 
$separatorLabel = New-Object System.Windows.Forms.Label
$separatorLabel.Text = ".."
$separatorLabel.Location = New-Object System.Drawing.Point(222, 200)
$separatorLabel.Size = New-Object System.Drawing.Size(27, 20)
$separatorLabel.Font = New-Object System.Drawing.Font("Courier New", 12)
$separatorLabel.ForeColor = 'Lime'
$separatorLabel.BackColor = 'Black'

# ListBox to display log file names
$listBoxWidth = 200 
$listBoxHeight = [int]($form.ClientSize.Height * 0.85)  

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(20, 60) 
$listBox.Size = New-Object System.Drawing.Size($listBoxWidth, $listBoxHeight)
$listBox.Font = New-Object System.Drawing.Font("Courier New", 10)
$listBox.ForeColor = 'Lime'
$listBox.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#002200")
$listBox.AllowDrop = $true
$listBox.ScrollAlwaysVisible = $false
$listBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor `
                  [System.Windows.Forms.AnchorStyles]::Bottom -bor `
                  [System.Windows.Forms.AnchorStyles]::Left

# RichTextBox to display results parsed from the data
$resultsBoxWidth = [int]($listBoxWidth * 2.75)  
$resultsBoxHeight = $listBoxHeight 
$resultsBoxX = $form.ClientSize.Width - $resultsBoxWidth - 20  

$resultsBox = New-Object System.Windows.Forms.RichTextBox
$resultsBox.Location = New-Object System.Drawing.Point($resultsBoxX, 60)
$resultsBox.Size = New-Object System.Drawing.Size($resultsBoxWidth, $resultsBoxHeight)
$resultsBox.Font = New-Object System.Drawing.Font("Courier New", 10)
$resultsBox.ForeColor = 'Lime'
$resultsBox.BackColor = 'Black'
$resultsBox.ReadOnly = $true
$resultsBox.WordWrap = $true
$resultsBox.ScrollBars = [System.Windows.Forms.RichTextBoxScrollBars]::Both  # Enable both scroll bars
$resultsBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor `
                      [System.Windows.Forms.AnchorStyles]::Bottom -bor `
                      [System.Windows.Forms.AnchorStyles]::Right

# RichTextBox to display parsed log data
$detailsBoxX = $listBox.Location.X + $listBox.Width + 32  
$detailsBoxWidth = $resultsBox.Location.X - $detailsBoxX - 32  
$detailsBoxHeight = $listBoxHeight 
$detailsBox = New-Object System.Windows.Forms.RichTextBox
$detailsBox.Location = New-Object System.Drawing.Point($detailsBoxX, 60)
$detailsBox.Size = New-Object System.Drawing.Size($detailsBoxWidth, $detailsBoxHeight)
$detailsBox.Font = New-Object System.Drawing.Font("Courier New", 10)
$detailsBox.ForeColor = 'Lime'
$detailsBox.BackColor = 'Black'
$detailsBox.ReadOnly = $true
$detailsBox.ScrollBars = 'Vertical'
$detailsBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor `
                      [System.Windows.Forms.AnchorStyles]::Bottom -bor `
                      [System.Windows.Forms.AnchorStyles]::Left -bor `
                      [System.Windows.Forms.AnchorStyles]::Right
				  



# DragEnter event ( drag and drop visual )
$listBox.Add_DragEnter({
    if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
        $_.Effect = [Windows.Forms.DragDropEffects]::Copy
    } else {
        $_.Effect = [Windows.Forms.DragDropEffects]::None
    }
})

# DragDrop event (Drop event)
$listBox.Add_DragDrop({
    $files = $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
    foreach ($file in $files) {
        if ($file -match "\.log$") {
            $fileName = [System.IO.Path]::GetFileName($file)
            if (-not $filePaths.ContainsKey($fileName)) {
                $filePaths[$fileName] = $file  # Store full path
                $listBox.Items.Add($fileName) # Add only the file name to the list box
            }
        }
    }
})

# Helper function to append colored text with values from the config file
function Add-ColoredText {
    param (
        [System.Windows.Forms.RichTextBox]$richTextBox,
        [string]$text,
        [string]$type 
    )

	# Dynamically build the color map from the configuration
	$colorMap = @{}
	foreach ($key in $config.Color.PSObject.Properties.Name) {
		$colorName = $config.Color.$key.Trim('"')
		$colorMap[$key.ToLower()] = [System.Drawing.Color]::FromName($colorName) 
	}

	# Retrieve the color
	$color = switch ($type.ToLower()) {
		{ $colorMap.ContainsKey($_) } { $colorMap[$_.ToLower()] } 
		default    { [System.Drawing.Color]::FromName("White") }
	}

    $start = $richTextBox.TextLength
    $richTextBox.AppendText($text)
    $end = $richTextBox.TextLength
    $richTextBox.Select($start, $end - $start)
    $richTextBox.SelectionColor = $color
    $richTextBox.DeselectAll()
}

# Event (Log Selected)
$listBox.Add_SelectedIndexChanged({
    $selectedFileName = $listBox.SelectedItem
    if ($selectedFileName -and $filePaths.ContainsKey($selectedFileName)) {
        $fullPath = $filePaths[$selectedFileName]  # Retrieve the full path
        $logContent = Get-Content $fullPath

        # Clears the display for a new selection
        $detailsBox.Clear()
		$resultsBox.Clear()


		# Displays the nested structure of the JSON Payload
		try {
			# Parse Qualys log
			$parsedLog = Parse-QualysLog -LogFileContent $logContent
			
			
			# Search for terms in the log content
            $searchResults = Parse-SearchTerms -LogFileContent $logContent -SearchTerms $searchTerms

			# Display nested JSON details from the Log file
			function Display-NestedData {
				param (
					[object]$Data,
					[int]$IndentLevel = 0
				)
				$indent = ' ' * ($IndentLevel * 4)

				if ($Data -is [PSCustomObject]) {
					foreach ($property in $Data.PSObject.Properties) {
						# Use "Parent" type for root level, "Key" for nested levels
						$type = if ($IndentLevel -eq 0) { "Parent" } else { "Key" }
						Add-ColoredText -richTextBox $detailsBox -text "$indent$($property.Name): " -type $type
						if ($property.Value -is [PSCustomObject] -or $property.Value -is [System.Array]) {
							Add-ColoredText -richTextBox $detailsBox -text "`n" -type $type
							Display-NestedData -Data $property.Value -IndentLevel ($IndentLevel + 1)
						} else {
							Add-ColoredText -richTextBox $detailsBox -text "$($property.Value)`n" -type "Value"
						}
					}
				} elseif ($Data -is [System.Array]) {
					foreach ($item in $Data) {
						Display-NestedData -Data $item -IndentLevel ($IndentLevel + 1)
					}
				} else {
					Add-ColoredText -richTextBox $detailsBox -text "$indent$Data`n" -type "Value"
				}
			}

			# Call the Display-NestedData function
			Display-NestedData -Data $parsedLog.JSONData
			
		} catch {
			Add-ColoredText -richTextBox $resultsBox -text "Error: $_`n" -type "Warning"
			Write-Host "Error: $_"
		}
		
		# Displays the results of the Search Terms
		foreach ($key in $searchResults.Keys) {
                $result = $searchResults[$key]

                Add-ColoredText -richTextBox $resultsBox -text "`nSearch: " -type "Time"
				Add-ColoredText -richTextBox $resultsBox -text "$key`n" -type "Parent"
                Add-ColoredText -richTextBox $resultsBox -text "  Description: " -type "Key"
				Add-ColoredText -richTextBox $resultsBox -text "$($result.Description)`n" -type "Value"
                Add-ColoredText -richTextBox $resultsBox -text "  Solution: " -type "Key"
				Add-ColoredText -richTextBox $resultsBox -text "$($result.Solution)`n" -type "Value"
                Add-ColoredText -richTextBox $resultsBox -text "  Matches:`n" -type "Key"

                foreach ($match in $result.Matches) {
				 # Use the search term as the delimiter to split the log line
					$splitResult = $match -split [regex]::Escape($key)  # $key is the search term

					if ($splitResult.Count -gt 1) {

						# The second part is after the match (include the search term itself)
						$suffix = "$key$($splitResult[1])".Trim()
						$key = $key.Trim()
						$suffix = $suffix.Trim($key)
						

						# Display the match and the portion after it
						Add-ColoredText -richTextBox $resultsBox -text "$key" -type "Warning"    # Matched search term
						Add-ColoredText -richTextBox $resultsBox -text "$suffix`n" -type "Child"  # Remaining portion
					} else {
						# Fallback if no split occurs (should not happen with valid matches)
						Add-ColoredText -richTextBox $resultsBox -text "$match`n" -type "Info"
					}
                }
            }
		
		
	}

})

# Add controls to form
$form.Controls.AddRange(@($dropLabel, $separatorLabel, $listBox, $detailsBox, $resultsBox ))

# Show the form
$form.ShowDialog()

# Windows .Net Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Base64 for disk icon
$iconBase64 = @"
iVBORw0KGgoAAAANSUhEUgAAABoAAAAaCAYAAACpSkzOAAAAIGNIUk0AAHomAACAhAAA+gAAAIDoAAB1MAAA6mAAADqYAAAXcJy6UTwAAAAGYktHRAD/AP8A/6C9p5MAAAAJcEhZcwAAA7AAAAOwASfED60AAAAHdElNRQfoCwYDLREspJnGAAAD0ElEQVRIx7WWX4hUVRzHP79z7p07o7tjs6voqkuU9sdNDUwLH4R6KCnszSCCeoioHnwIwofsoQhC6zmCMF8sCunBooKIwBIWKtIUS8Fc1n9r/tnW3dmdnbn3nnt+PezsrJPTtrPSF86Fe/md+zm/7++c371iiz1Hcis3bsA74sH+Yz4u7wHCUlf3mxs2bV4VhjmUGQlgrEXq9wo4l2mlmvDb7yckLq3FBBHu+uBQMvTrztzi1Z8mw2eQwppt2v30fnx1lJEDz/lo8aokcymrC9eivfv2S+ei21DVOkSoVif56uABrl27CgorenvZ+uRTnL86wa7XX2N401uExWW44dOMffnqpcnT3+7ILb7rYCA2RMIFSFolWLTSlDa/nHdpjXBgL1EUkc/nqXMwBsZGR/josy8YLm3Bu5g7fvqcrdu2E+ULiLFIkEeCHGHPWkpP7F5OFr83OfBDIZgxRetXD+ppJVVAPcGCLjrufRSfTGIHBlBVtMlgwEOwbD2lh3cud+NX3jXMR6rgs6mh9cK1CkMISr0ExZ4V8wO1uyjg/wfV1R5Ipi2pD5Gp2uh/T53ZDPVgEQNipqw3BmMa2SMGglxE3pcZOboPzRyFYkwQhhhJZwJnBQloUiEZHgCES39e5vB3X9O3fgPqtRGTOcfzzz7D+Nh1AErdS7h4/iw/Hz3GX0mEzXe2zDCYTkdyndgl91D+4xAilswu5Y2937Cwo/9mv41FZMpH1dNk2WGqpoNg4w5MrjALSBVTKLLo8T34tMr0nlUg0TkUAMjZEIwlS2IQsEHUtO0b1mnmiH98n+KFQ1gjc3p5k25YT+aU8u2PED30IlKnBdNVTisj3HnmYz68X+iMokZ/a0sC4oTxi8oLJz/h3Lrt5ORGEIDP6AgMq7uKRGHYmNi2nBCXocOMoD672ToEai7jwliFlcWFTCSOmsvahkkmTE5ALcuanjdABjiXWt4Z7eSlLY/x/fGTnLo8hJH2zrQCk5oyKLWmbtAAee+5e00fb3+wm+4lS7kvjnHOtZ2R98LglTKDr+zirPc3gwCsNYTRQso1QCOwUdslUoFCwWOtbW3ddN6BUfK5ObWv1hnp9AlsVtAqMMlmbVuzZ/Qvz4NWgTq3htwa9I+5TQdW43E0rYIIViAKmTfJ68y3R9MaPp1AEAKMpXL8AN5O/Vw4DxPxrVnnFTCW+Fw/bnQAjCFQFxMu7SNzjmykH5/WWHALKWUqpEkN71Js1wrCwFAd7EdsseeXXO+DD2iW0lk+yeaN6wiCcJ4VmnKiUks5cuwEleIajE+ILx0/8jepJJ/lXaLeogAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAyNC0xMS0wNlQwMzo0NToxNyswMDowMFMezRAAAAAldEVYdGRhdGU6bW9kaWZ5ADIwMjQtMTEtMDZUMDM6NDU6MTcrMDA6MDAiQ3WsAAAAKHRFWHRkYXRlOnRpbWVzdGFtcAAyMDI0LTExLTA2VDAzOjQ1OjE3KzAwOjAwdVZUcwAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAAASUVORK5CYII=
"@

# Decode Base64 icon and then convert it to an icon
$iconBytes = [Convert]::FromBase64String($iconBase64)
$iconStream = New-Object System.IO.MemoryStream(,$iconBytes)
$formIcon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::FromStream($iconStream)).GetHicon())



# Main Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Log Parser"  
$form.Size = New-Object System.Drawing.Size(800, 500)
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

# Label for separator text
$separatorLabel = New-Object System.Windows.Forms.Label
$separatorLabel.Text = ".."
$separatorLabel.Location = New-Object System.Drawing.Point(222, 200)
$separatorLabel.Size = New-Object System.Drawing.Size(27, 20)
$separatorLabel.Font = New-Object System.Drawing.Font("Courier New", 12)
$separatorLabel.ForeColor = 'Lime'
$separatorLabel.BackColor = 'Black'

# ListBox to display log file names ( drag-and-drop enabled )
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(20, 60)
$listBox.Size = New-Object System.Drawing.Size(200, 300)
$listBox.Font = New-Object System.Drawing.Font("Courier New", 10)
$listBox.ForeColor = 'Lime'
$listBox.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#002200")
$listBox.AllowDrop = $true  
$listBox.ScrollAlwaysVisible = $false  
$listBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left

# TextBox to display parsed log data ( Responsive )
$detailsBox = New-Object System.Windows.Forms.TextBox
$detailsBox.Location = New-Object System.Drawing.Point(250, 28)
$detailsBox.Size = New-Object System.Drawing.Size(520, 324)
$detailsBox.Font = New-Object System.Drawing.Font("Courier New", 10)
$detailsBox.ForeColor = 'Lime'
$detailsBox.BackColor = 'Black'
$detailsBox.Multiline = $true
$detailsBox.ReadOnly = $true
$detailsBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical 
$detailsBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right

# DragEnter event ( drag and drop visual )
$listBox.Add_DragEnter({
    if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {
        $_.Effect = [Windows.Forms.DragDropEffects]::Copy
    } else {
        $_.Effect = [Windows.Forms.DragDropEffects]::None
    }
})

# DragDrop event ( Drop Event )
# Only add log files - path excluded
$listBox.Add_DragDrop({
    $files = $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
    foreach ($file in $files) {
        if ($file -match "\.log$") { 
            $listBox.Items.Add([System.IO.Path]::GetFileName($file))  
        }
    }
})

# Event  ( Log Selected )
$listBox.Add_SelectedIndexChanged({
    $selectedFile = $listBox.SelectedItem
    if ($selectedFile) {
        # getpath 
        $fullPath = (Get-ChildItem -Path . -Filter $selectedFile -Recurse | Select-Object -First 1).FullName
        $lines = Get-Content $fullPath
        
        $startLogTime = ""
        $endLogTime = ""
        
        # Start of log, end of log
        if ($lines[0] -match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}') {
            $startLogTime = $matches[0]
        }
        if ($lines[-1] -match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}') {
            $endLogTime = $matches[0]
        }

        
        $displayText = @("Start of Log: $startLogTime", "End of Log: $endLogTime")

        # Find the last JSON payload ( CAPI JSON )
		# Display each element on unique line
        $jsonPayload = ($lines -match '{"Data":' | Select-Object -Last 1)
        if ($jsonPayload) {
            try {
                $jsonData = $jsonPayload | Out-String | ConvertFrom-Json
                # Extract details from JSON 
                foreach ($key in $jsonData.Data.Client.PSObject.Properties.Name) {
                    $displayText += "$($key): $($jsonData.Data.Client.PSObject.Properties[$key].Value)"
                }
                foreach ($key in $jsonData.Data.Agent.PSObject.Properties.Name) {
                    $displayText += "$($key): $($jsonData.Data.Agent.PSObject.Properties[$key].Value)"
                }
                foreach ($key in $jsonData.Data.Provider.PSObject.Properties.Name) {
                    $displayText += "$($key): $($jsonData.Data.Provider.PSObject.Properties[$key].Value)"
                }
                foreach ($key in $jsonData.Data.Status.PSObject.Properties.Name) {
                    $displayText += "$($key): $($jsonData.Data.Status.PSObject.Properties[$key].Value)"
                }
            } catch {
                $displayText += "Error parsing JSON data"
            }
        } else {
            $displayText += "No JSON data found in file."
        }
        
        
        $detailsBox.Lines = $displayText
    }
})

## ## ## M A I N ## ## ##


# Add controls to form
$form.Controls.AddRange(@($dropLabel, $separatorLabel, $listBox, $detailsBox))

# Show the form
$form.ShowDialog()

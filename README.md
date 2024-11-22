# Parsley - Qualys Cloud Agent Log File Analysis Tool

## Overview

**Parsley** is a PowerShell-based tool designed for efficient analysis of Qualys Cloud Agent log files. Its primary functionality includes parsing logs using configurable search terms and providing a streamlined drag-and-drop interface for usability. 

## Considerations of Use

- *NO* reliability of data should assumed from any of the outputs (I'm just a quasi-lazy nerd sharing a tool) - always use the raw data to troubleshoot. 

## Features

1. **Configurable Search Terms**:
   - Uses `Search-Terms.yaml` for defining terms to search within log files.
   - Customize and build search criteria tailored to your requirements.

2. **Ease of Use**:
   - Run the script by right-clicking it and selecting "Run with PowerShell."
   - Intuitive drag-and-drop interface: drop Qualys Cloud Agent log files into the window, and the analysis starts automatically.
   - There are no external libraries or dependencies required, its designed to be transparent.

3. **Customizable Environment**:
   - Reads configurations from `environment.yaml` for additional settings and customization.

## Installation and Setup

1. **Prerequisites**:
   - All Windows based machines should have Powershell by default, but its good to make sure it is installed and updated anyways. 
   - Do not change the file structure, some functionalities are dependant on the modules.

2. **File Structure**:
   ```
   /Parsley/
   ├── Parsley.ps1
   ├── Search-Terms.yaml
   ├── environment.yaml
   └── Modules/
       ├── Parse-QualysLog/
       │   ├── Parse-QualysLog.psm1
       │   └── Parse-SearchTerms.psm1
       ├── Get-YamlConfig/
       │   └── Get-YamlConfig.psm1
       └── Add-Ons/
           └── environment.yaml
   ```

3. **Running the Script**:
   - Navigate to the script directory.
   - Right-click `Parsley.ps1` and select **Run with PowerShell**.

## How to Use

1. **Load Log Files**:
   - Drag and drop Qualys Cloud Agent log files into the interface.

2. **View Results**:
   - The parsed log details, including timestamps and other key metrics, these will be displayed dynamically on the left.

3. **Modify Search Terms**:
   - Open `Search-Terms.yaml` in a text editor.
   - Add or edit search terms as needed.
   - Save the file to apply the changes for subsequent analysis.

## Configuration Files

- **`Search-Terms.yaml`**:
  - Defines the terms or patterns to search for in the log files.
  - Example:
    ```yaml
    Http Response 200:
        Search: "Received HTTP response code: 200"
        Description: "Code 200 indicates an OK status"
        Solution: "All good"
    Missing Element:
        Search: "Missing Element"
        Description: "Mysterious Tour Bus"
        Solution: "Dance in circles"
    Error: 
        Search: "[Error]"
        Description: "Errors are generally a bad thing"
        Solution: "It's a trap"
    ```

- **`environment.yaml`**:
  - Contains settings like window titles, script behavior, and visual customization.

## Contributions

Feel free reach out to me about **Parsley**. It is a work in progress after all :)

## License

This tool is released under the GNULicense. Share for fun, not profit. 

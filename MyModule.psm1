# MyModule.psm1
# Get the module directory path (cross-platform compatible)
$ModulePath = $PSScriptRoot

# Optional: Define files to exclude from auto-discovery
# Add any helper files or private functions here
$ExcludeFiles = @(
    # Example: 'Private-Helper.ps1',
    # Example: 'Internal-Function.ps1'
)

# Auto-discover all .ps1 function files in the module root
$FunctionFiles = Get-ChildItem -Path $ModulePath -Filter "*.ps1" -File |
    Where-Object { $_.Name -notin $ExcludeFiles }

# Import each function file with error handling
$SuccessfullyLoaded = @()
$FailedToLoad = @()

foreach ($file in $FunctionFiles) {
    try {
        # Use Join-Path for cross-platform compatibility
        $filePath = Join-Path -Path $ModulePath -ChildPath $file.Name

        # Validate file exists before dot-sourcing
        if (Test-Path -Path $filePath -PathType Leaf) {
            # Dot-source the file
            . $filePath

            # Extract function name from filename (assumes File-Name.ps1 pattern)
            $functionName = $file.BaseName

            # Export the function
            Export-ModuleMember -Function $functionName

            # Track successful loads
            $SuccessfullyLoaded += $functionName

            Write-Verbose "Successfully loaded function: $functionName"
        }
        else {
            Write-Warning "File not found: $filePath"
            $FailedToLoad += $file.Name
        }
    }
    catch {
        Write-Warning "Failed to load function from $($file.Name): $_"
        $FailedToLoad += @{
            File = $file.Name
            Error = $_.Exception.Message
        }
    }
}

# Optional: Report loading status (only in verbose mode)
Write-Verbose "Module loading complete: $($SuccessfullyLoaded.Count) functions loaded successfully"
if ($FailedToLoad.Count -gt 0) {
    Write-Warning "Failed to load $($FailedToLoad.Count) function(s). Use -Verbose flag for details."
}

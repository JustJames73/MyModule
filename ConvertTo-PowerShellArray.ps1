function ConvertTo-PowerShellArray {
    <#
    .SYNOPSIS
        Converts text from clipboard or input into a properly formatted PowerShell array string.
    
    .DESCRIPTION
        This function takes text from either the clipboard or a provided string and converts it into
        a PowerShell array format. It can handle multiple input formats including:
        - Distinguished Names (DN) from Active Directory
        - Multi-line text
        - Comma-separated values
        - Space-separated values
        - IP addresses (with special sorting capabilities)
        
        The function automatically detects the input format and processes it accordingly.
        The output is formatted as a PowerShell array string with proper quoting and is 
        automatically copied to the clipboard.
    
    .PARAMETER InputList
        The text to convert into an array. If not specified, the function uses the current
        clipboard content. The text can be in various formats (DN, CSV, space-separated, etc.).
    
    .PARAMETER Sort
        When specified, sorts the output array. Has special handling for IP addresses to ensure
        proper numeric sorting.
    
    .EXAMPLE
        ConvertTo-PowerShellArray
        Takes whatever is in the clipboard and converts it to a PowerShell array.
    
    .EXAMPLE
        ConvertTo-PowerShellArray -InputList "server1,server2,server3" -Sort
        Converts the comma-separated list into a sorted PowerShell array.
    
    .EXAMPLE
        "CN=User1,DC=contoso,DC=com", "CN=User2,DC=contoso,DC=com" | ConvertTo-PowerShellArray
        Converts a list of Distinguished Names into a PowerShell array.
    
    .EXAMPLE
        ConvertTo-PowerShellArray -InputList "192.168.1.1 192.168.0.1" -Sort
        Converts and properly sorts IP addresses.
    
    .NOTES
        Author: https://github.com/JustJames73
        Last Modified: 2025-01-13
    
    .LINK
        about_Arrays
        about_Splatting
    #>
    [Alias("CTA", "Format-Array")]
    param (
        [string]$InputList = $(Get-Clipboard -Raw),
        [switch]$Sort
    )
    
    function Get-BestDelimiter {
        # Helper function to determine the best delimiter based on input format
        param ([string]$text)
        
        # Check for Distinguished Name format with multiple lines
        if (($text -split "\r?\n").Count -gt 1 -and $text -match "^CN=|^OU=|^DC=") {
            return "DN multiline"
        }
        # Check for single Distinguished Name with possible spaces
        elseif ($text -match "^CN=|^OU=|^DC='") {
            if ($text -match "\s") { return "CN with Spaces" }
            return "CN no spaces"
        }
        # Check for multiple lines (more than 2)
        elseif (($text -split "\r?\n").Count -gt 2) {
            return "crlf"
        }
        # Check for comma-separated values
        elseif ($text -match ",") {
            return "comma"
        }
        # Check for space-separated values
        elseif ($text -match "\s") {
            return "space"
        }
        # Return null if no specific format is detected
        return $null
    }

    # Determine the input format
    $delimiterType = Get-BestDelimiter -text $InputList

    # Process the input based on detected format
    $cleanedList = switch ($delimiterType) {
        "DN multiline" { 
            # Handle multi-line Distinguished Names
            ($InputList -split "\r?\n") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } 
        }
        "crlf" { 
            # Handle general multi-line input
            ($InputList -split "\r?\n") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } 
        }
        "comma" { 
            # Handle comma-separated input
            ($InputList -split ",") | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } 
        }
        "space" { 
            # Handle space-separated input
            ($InputList -split "\s+") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } 
        }
        default { 
            # Handle single item input
            @($InputList) 
        }
    }

    # Sort the list if requested
    if ($Sort) {
        $cleanedList = if ($cleanedList[0] -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
            # Special handling for IP addresses - convert to version objects for proper sorting
            [string[]]$([version[]]($cleanedList) | Sort-Object -Unique)
        }
        else {
            # Standard sorting for non-IP addresses
            $cleanedList | Sort-Object -Unique
        }
    }

    # Add quotes around each item and escape any existing quotes
    $quotedList = $cleanedList | ForEach-Object { "'$($_ -replace "'", "''")'" }
    
    # Create the final array string with proper PowerShell syntax
    $result = '@(' + ($quotedList -join ',') + ')'
    
    # Output the result and copy to clipboard
    Write-Output $result
    $result | Set-Clipboard
}

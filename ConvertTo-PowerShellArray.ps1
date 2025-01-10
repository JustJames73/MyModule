# ConvertTo-PowerShellArray.ps1
function ConvertTo-PowerShellArray {
    [Alias("CTA", "Format-Array")]
    param (
        [string]$InputList = $(Get-Clipboard -Raw),
        [switch]$Sort
    )
    
    function Get-BestDelimiter {
        param ([string]$text)
        if (($text -split "\r?\n").Count -gt 1 -and $text -match "^CN=|^OU=|^DC=") {
            return "DN multiline"
        }
        elseif ($text -match "^CN=|^OU=|^DC='") {
            if ($text -match "\s") { return "CN with Spaces" }
            return "CN no spaces"
        }
        elseif (($text -split "\r?\n").Count -gt 2) {
            return "crlf"
        }
        elseif ($text -match ",") {
            return "comma"
        }
        elseif ($text -match "\s") {
            return "space"
        }
        return $null
    }

    $delimiterType = Get-BestDelimiter -text $InputList
    $cleanedList = switch ($delimiterType) {
        "DN multiline" { ($InputList -split "\r?\n") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } }
        "crlf" { ($InputList -split "\r?\n") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } }
        "comma" { ($InputList -split ",") | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } }
        "space" { ($InputList -split "\s+") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } }
        default { @($InputList) }
    }

    if ($Sort) {
        $cleanedList = if ($cleanedList[0] -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
            [string[]]$([version[]]($cleanedList) | Sort-Object -Unique)
        }
        else {
            $cleanedList | Sort-Object -Unique
        }
    }

    $quotedList = $cleanedList | ForEach-Object { "'$($_ -replace "'", "''")'" }
    $result = '@(' + ($quotedList -join ',') + ')'
    
    Write-Output $result
    $result | Set-Clipboard
}


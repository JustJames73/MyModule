# Search-Scripts.ps1
function Search-Scripts {
    [CmdletBinding()]
    param(
        [string[]]$Path = $pwd,
        [string[]]$Include = "*.ps1",
        [string[]]$KeyWord = (Read-Host "Keyword?"),
        [switch]$ListView
    )
    begin {}
    process {
        Get-ChildItem -path $Path -Include $Include -Recurse | `
        sort Directory,CreationTime | `
        Select-String -simplematch $KeyWord -OutVariable Result | `
        Out-Null
    }
    end {
        if ($ListView) { 
            $Result | Format-List -Property Path,LineNumber,Line 
        } 
        else { 
            $Result | Format-Table -GroupBy Path -Property LineNumber,Line -AutoSize 
        } 
        $Result | 
        select Path | sort Path -Unique | 
        Out-GridView -OutputMode Multiple -Title 'Select one or more files to open...' | 
        ForEach-Object { $psISE.CurrentPowerShellTab.Files.Add($_.Path) }  
    }
}


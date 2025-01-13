# Search-Scripts.ps1
function Search-Scripts {
.SYNOPSIS
  Search all .PS1 files under the present working directory for keywords. 
.DESCRIPTION
  The Search-Scripts function combines the Get-ChildItem and Select-String
cmdlets to perform a keyword search on text files. By default the function 
recursively searches PowerShell script files (*.ps1) from the current folder 
using the provided keyword as a "simplematch". A simplematch searches the 
text as as string and does not evaluate Regular Expressions, if a RegEx is 
provided the search will return any string matching the keword as provided. 
  The path and file type can be changed with parameter switches. 
  The default view groups results by the file in which they were found but 
truncates the matching line of text, using the "-ListView" switch will show
the whole line of text matching the search. 
The Path is sent to "Out-GridView -Multiple", allowing selection of one or 
more scripts to open in PowerShellISE for further review. 
NOTE: the GridView window needs to close before you can use ISE. 
.EXAMPLE
	C:\> Search-Scripts -Keyword foreach
... will search all *.ps1 files from the root of C:\ containing the word "foreach"
.PARAMETER <Path>
    The path from where you wish to start your search. 
    Uses $pwd by default. 
.PARAMETER <Include>
    The filename pattern to include in the search.
    Uses "*.ps1" by defualt, but can be changed to any valid filename pattern. 
    Ex: "Scheduled*.ps1" or "*log.txt"
.PARAMETER <Keyword>
    The keword to search for. 
    This is a required parameter, and will prompt for a value if not provided. 
.PARAMETER <List>
    [Switch] to change the output from a formatted table grouping results by
    the path and filename with the matched line on a single truncated line 
    or displaying as a formatted list with the Path, Line Number, and full Line 
    of text matched by the search. 
    It is recomended that you narrow down the scope of your search with the 
    Path and Include parameters when using the ListView switch. 
#>

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


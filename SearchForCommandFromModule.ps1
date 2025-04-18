# SearchForCommandFromModule.ps1
FUNCTION SearchForCommandFromModule  {
<#
.SYNOPSIS
Search a script for commands from a specific module.
.DESCRIPTION
This function does two things. 
    1) Pull a list of the commands associated with a module.
    2) Search a script for each instance of the command and output to a gridview window. 

Identifies cmdlets in a script that call on a specific module. 
The function is built on the "Get-Command" cmdlet. 
If you don't know what module to search use "Get-Command" on a cmdlet you know is from 
that module, or use "Get-Module" for a list of modules currently loaded in your session. 
The results will be displayed using "Out-GridView".
.EXAMPLE
To find the ModuleName that a known command is from:
 Get-Command Write-Host
The resulting ModuleName will be "Microsoft.PowerShell.Utility"
.EXAMPLE
To find all commands related to the Utility module... 
Using a partial match:
    SearchForCommandFromModule -Module "*Utility" -LiteralPath C:\Scripts\MyScript.ps1
Using a fully qualified module name:
    SearchForCommandFromModule -Module "Microsoft.PowerShell.Utility" -LiteralPath C:\Scripts\MyScript.ps1
.PARAMETER <Module>
The "-Module" parameter will be used in the function as:
    Get-Command -Module $Module
If you had specified "*Utility" as the value, this would be the same as:
    Get-Command -Module "*Utility"
.PARAMETER <LitteralPath>
The -LitteralPath specifies the script you wish to search in, and will be used in the function as:
    Select-String -Pattern $i -LiteralPath $LiteralPath
If you had specifed "C:\Scripts\MyScript.ps1", this would be the same as:
    Select-String -Pattern "Write-Host -LiteralPath "C:\Scripts\MyScript.ps1"
#>

    PARAM(
        [string]$Module,
        [string]$LiteralPath
    )
    BEGIN {
        Get-Command -Module $Module | select -ExpandProperty Name -OutVariable Commands | Out-Null
    }
    PROCESS {
        foreach ($i in $Commands) { 
            Select-String -Pattern $i -LiteralPath $LiteralPath | select LineNumber,Line -OutVariable +FoundIt | Out-Null
        }
    }
    END {
        $FoundIt | sort LineNumber -Unique | Out-GridView -Title "Search Results for module $Module";
    }

}

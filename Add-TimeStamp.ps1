# Add-TimeStamp.ps1
function Add-TimeStamp {
<#
.Synopsis
   Add a sortable timestamp to the filename using the last modified date of the file
.DESCRIPTION
   By default this function will replace file name with a sortable timestamp prefix
   in the directory where the file is currently located. 
   Use the -Suffix switch to add the timestamp at the end of the filename. 
   Use the -Copy switch to create a copy of the file with the new filename.
.EXAMPLE
   > Add-TimeStamp -FullName .\Foo.bar
   Renames the file "Foo.bar" to "2016-11-07T144837_Foo.bar"
.EXAMPLE
   > Add-TimeStamp .\Foo.bar -Suffix -CopyItem
   Copies the file "Foo.bar" to "Foo_2016-11-07T144837.bar"
.EXAMPLE
   > Get-ChildItem Foo*.bar | Add-TimeStamp
   Renames all files in the folder matching "Foo*.bar" with the last modified 
   timestamp. 
.NOTES
   This script was created to aid in creating backup copies of scripts and data files. 
#>

    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    [OutputType([String])]
    param(
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [string] $FullName,
        [switch] $Suffix,
        [switch] $CopyItem
    )
    begin {}
    process {
        Write-Verbose -Message $("OldName:`t$((Get-ItemProperty $FullName).FullName)")
        $Vars = Get-ItemProperty $FullName 
        $Directory = $Vars.DirectoryName
        $BaseName = $Vars.BaseName
        $Extension = $Vars.Extension
        $TimeStamp = $Vars.LastWriteTime | Get-Date -Format yyy-MM-ddTHHmmss
        
        if ($Suffix) {
            $NewName = Join-Path $directory $($BaseName+"_"+$TimeStamp+$Extension)
        }
        else {
            $NewName = Join-Path $directory $($TimeStamp+"_"+$BaseName+$Extension)
        }
        
        if ($CopyItem) {
            Copy-Item -Path $Vars.FullName -Destination $NewName
        }
        else {
            Rename-Item -Path $Vars.FullName -NewName $NewName
        }
        Write-Verbose $("NewName:`t $((Get-ItemProperty $NewName).FullName)")
        return $((Get-ItemProperty $NewName).FullName)
    }
    end {}
}


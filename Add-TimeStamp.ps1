# Add-TimeStamp.ps1
function Add-TimeStamp {
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


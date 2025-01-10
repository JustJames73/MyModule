# MyModule.psm1
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$Functions = @(
    'Search-Scripts',
    'Add-TimeStamp',
    'ConvertTo-PowerShellArray',
    'Report-GroupMembers',
    'Write-Color',
    'Generate-RandomPassword',
    'Generate-RandomPassPhrase',
    'SearchForCommandFromModule',
    'Test-MultipleConnections'
)

foreach ($function in $Functions) {
    . "$ScriptPath\$function.ps1"
    Export-ModuleMember -Function $function
}
@{
    # Script module or binary module file associated with this manifest
    RootModule = 'MyModule.psm1'

    # Version number of this module
    ModuleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d'

    # Author of this module
    Author = 'JustJames73'

    # Company or vendor of this module
    CompanyName = 'Unknown'

    # Copyright statement for this module
    Copyright = '(c) 2025. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'A collection of frequently used PowerShell utility functions for text processing, password generation, network testing, and Active Directory reporting.'

    # Minimum version of PowerShell required
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @(
        'Add-TimeStamp',
        'Convert-CIDRToIPRange',
        'ConvertTo-PowerShellArray',
        'Generate-RandomPassword',
        'Generate-RandomPassPhrase',
        'Report-GroupMembers',
        'Search-Scripts',
        'SearchForCommandFromModule',
        'Test-MultipleConnections',
        'Write-Color'
    )

    # Aliases to export from this module
    AliasesToExport = @('CTA', 'Format-Array')

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{
        PSData = @{
            # Tags applied to this module for discoverability
            Tags = @('Utility', 'ActiveDirectory', 'NetworkTools', 'TextProcessing', 'PasswordGeneration')

            # A URL to the main website for this project
            ProjectUri = 'https://github.com/JustJames73/MyModule'

            # ReleaseNotes of this module
            ReleaseNotes = 'Initial release with 10 utility functions including cross-platform support and auto-discovery module loading.'
        }
    }
}

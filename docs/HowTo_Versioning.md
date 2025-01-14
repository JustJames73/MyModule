# Recomended versioning strategy for Git and PowerShell

This structure provides:
- Clear version history
- Separation of concerns
- Easy maintenance
- Automated building and testing
- Proper documentation
- Professional release management

## 1. Module Manifest Structure:
```powershell
# Create a module manifest if you don't have one
New-ModuleManifest -Path .\MyModule.psd1 -RootModule .\MyModule.psm1 -ModuleVersion '0.1.0'
```

## 2. Version Number Format:
- Use Semantic Versioning (SemVer): MAJOR.MINOR.PATCH
  - MAJOR: Breaking changes
  - MINOR: New features, backward compatible
  - PATCH: Bug fixes, backward compatible

## 3. Directory Structure:
```
MyModule/
├── .git/
├── .gitignore
├── src/
│   ├── Public/
│   │   ├── Search-Scripts.ps1
│   │   ├── Add-TimeStamp.ps1
│   │   └── ...
│   └── Private/
│       └── internal-functions.ps1
├── tests/
│   └── MyModule.Tests.ps1
├── docs/
│   └── CHANGELOG.md
├── MyModule.psd1
├── MyModule.psm1
└── README.md
```

## 4. .gitignore contents:
```gitignore
# PowerShell temp files
*.psm1.*.ps1
*.ps1.*.ps1
*.psm1.*.psd1
*.ps1.*.psd1

# Build output
/output/
/release/

# Test results
/TestResults/

# Module manifest backup
*.psd1.backup
```

## 5. Version Control in Functions:
```powershell
function Search-Scripts {
    <#
    .SYNOPSIS
        Search scripts for keywords
    .NOTES
        Version:        1.0.0
        Author:         Your Name
        Creation Date:  2025-01-14
        ChangeLog:
            1.0.0 - Initial release
            1.0.1 - Added support for multiple file types
    #>
    [CmdletBinding()]
    param(...)
```

## 6. CHANGELOG.md structure:
```markdown
# Changelog
All notable changes to this project will be documented in this file.

## [1.0.0] - 2025-01-14
### Added
- Initial release
- Search-Scripts function
- Add-TimeStamp function

### Changed
- Improved error handling in ConvertTo-PowerShellArray

### Fixed
- Bug in Report-GroupMembers when handling empty groups
```

## 7. Git Workflow:
```bash
# Feature branches
git checkout -b feature/new-function
git checkout -b bugfix/timestamp-error
git checkout -b release/v1.0.0

# Tag releases
git tag -a v1.0.0 -m "Release version 1.0.0"
```

## 8. Build Process Example:
```powershell
# build.ps1
param(
    [string]$Version = '1.0.0',
    [string]$OutputPath = '.\output'
)

# Update module version
Update-ModuleManifest -Path .\MyModule.psd1 -ModuleVersion $Version

# Combine all public functions
$Public = @(Get-ChildItem -Path $PSScriptRoot\src\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\src\Private\*.ps1 -ErrorAction SilentlyContinue)

# Create output directory
New-Item -ItemType Directory -Path $OutputPath -Force

# Combine files
$ModuleContent = @'
# MyModule.psm1
# Version: {0}
# Generated: {1}
'@ -f $Version, (Get-Date)

foreach ($file in @($Private + $Public)) {
    $ModuleContent += "`n`n# Source: $($file.Name)`n"
    $ModuleContent += (Get-Content -Path $file.FullName -Raw)
}

# Output combined module
$ModuleContent | Out-File -FilePath "$OutputPath\MyModule.psm1" -Encoding UTF8
```

## 9. GitHub Action workflow example:
```yaml
# .github/workflows/publish.yml
name: Publish PowerShell Module
on:
  push:
    tags:
      - 'v*'
jobs:
  publish:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build and Test
        shell: pwsh
        run: |
          ./build.ps1
          Invoke-Pester ./tests -Output Detailed
      - name: Publish
        if: success()
        env:
          NUGET_KEY: ${{ secrets.NUGET_KEY }}
        shell: pwsh
        run: |
          Publish-Module -Path ./output -NuGetApiKey $env:NUGET_KEY
```

## 10. Include version checks in your module:
```powershell
# In MyModule.psm1
$MinimumPowerShellVersion = '5.1'
if ($PSVersionTable.PSVersion -lt [Version]$MinimumPowerShellVersion) {
    throw "PowerShell version $MinimumPowerShellVersion or higher is required."
}
```

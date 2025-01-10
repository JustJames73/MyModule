# Report-GroupMembers.ps1
function Report-GroupMembers {
    param([string]$GroupName = $(Read-Host -Prompt "Enter group name"))
    
    $ErrorActionPreference='SilentlyContinue'
    $collection = Get-ADGroupMember $GroupName | select -ExpandProperty distinguishedName
    foreach ($i in $collection) {
        Get-ADUser $i -Properties EmailAddress,whenCreated,accountExpirationDate,LastLogonDate,PasswordExpired,PasswordLastSet,Description -ErrorAction SilentlyContinue | 
            Select-Object -OutVariable +CollectionReport -Property `
                Name,
                SamAccountName,
                EmailAddress,
                whenCreated,
                @{n='AccountExpiration';e={($_.AccountExpirationDate|Get-date).AddDays(-1)}},
                Description,
                Enabled,
                LastLogonDate,
                PasswordExpired,
                PasswordLastSet | 
            out-null
    }
    $CollectionReport | Sort-Object -Property Name | Export-Csv -NoTypeInformation -Path $('.\MembershipReport_'+$GroupName+'_'+$(Get-Date -Format yyy-MM-ddTHHmmss)+'.csv')
}


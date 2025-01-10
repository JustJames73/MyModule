# Generate-RandomPassword.ps1
function Generate-RandomPassword {
    param ([Parameter(Mandatory=$false)][string]$Username)
    
    begin {
        function Get-RandomCharacter {
            param ( [char[]]$Characters )
            $index = Get-Random -Minimum 0 -Maximum $Characters.Length
            $Characters[$index]
        }

        $charAlpha = @([char[]](65..90) + [char[]](97..122))
        $charNumeric = @([char[]](48..57))
        $charSpecial = @([char[]](33,35,36,37,40,41,43,47,58,61,63))

        $length = Get-Random -Minimum 14 -Maximum 21
    }
    
    process {
        $password = $null
        while ($password -eq $null) {
            $chars = 1..$length | ForEach-Object {
                if ($_ -eq 1) {
                    $char = Get-RandomCharacter -Characters $charAlpha
                }
                elseif ($_ -eq $length) {
                    $char = Get-RandomCharacter -Characters $charAlpha
                }
                elseif ($_ -ge 2 -and $_ -le 7) {
                    $char = Get-RandomCharacter -Characters @($charAlpha + $charSpecial + $charNumeric)
                }
                else {
                    $char = Get-RandomCharacter -Characters @($charAlpha + $charNumeric)
                }
                $char
            }

            $newPassword = -join $chars
            if ($newPassword -cmatch '[A-Z]' -and $newPassword -cmatch '[a-z]' -and $newPassword -cmatch '\d' -and $newPassword -cmatch '\W') {
                $password = $newPassword
            }
        }
    }
    
    end {
        $password
    }
}


# Generate-RandomPassPhrase.ps1
function Generate-RandomPassPhrase {
<#
.SYNOPSIS
Generates a random passphrase from an external dictionary list of words.

.DESCRIPTION
The Generate-RandomPassPhrase function generates a random passphrase using a word list file. 
The passphrase consists of random words concatenated together with optional padding characters.
The word list file will have one word per line.
By default, the function uses a word list file named "all.words" in the current directory.
The function can also enforce complexity requirements such as case modification and special characters.
Additionally, it supports banning specific words from the generated passphrase.

.PARAMETER minLength
The minimum length of the generated passphrase. Default is 15 characters.

.PARAMETER wordListFile
The path to the word list file. Default is "all.words" in the current directory.

.PARAMETER Iterations
The number of passphrases to generate. Default is 1. Increment to list additional passswords. 

.PARAMETER Complex
Switch parameter to enable passphrase complexity. When specified, modifies case and adds special characters between words.

.PARAMETER BannedWords
An array of words to exclude from the generated passphrase.

.EXAMPLE
Generate-RandomPassPhrase -minLength 20 -wordListFile "custom.words" -Iterations 3 -Complex -BannedWords @("password", "123456")

Generates 3 random passphrases with a minimum length of 20 characters, using a custom word list file "custom.words".
Passphrases are complex with modified case and special characters. The words "password" and "123456" are banned.

.NOTES
This function may require access to external word list files. Ensure appropriate permissions are set.
#>


    param (
        [int]$minLength = 15,
        [string]$wordListFile = 'all.words',
        [int]$Iterations = 1,
        [switch]$Complex, 
        [array]$BannedWords = @('1234','2015','2016','2017','2018','2019','2020','2021','2022','2023','avalanche','broncos','buffalo','buffs','colorado','horse','mammoth','nuggets','rams','rockies','battery','drive','energy','nrel','research','solar','wind','correct','password','qwerty','rain')
    )
    
    $PadCharacters = ' '
    $passphrases = @()

    if (-not (Test-Path -Path $wordListFile -PathType Leaf)) {
        Write-Verbose -Message "Word list file '$wordListFile' not found. Searching for .words files in the current directory..."
        $wordListFiles = Get-ChildItem -Path $pwd -Filter "*.words" -File -Recurse
        Write-Verbose -Message "Found the following words list: $wordListFiles"
        
        if ($wordListFiles.Count -eq 0) {
            throw "No .words files found in the current directory."
        }
        $wordListFile = $wordListFiles[0].FullName
    }

    if (-not $wordlist) {
        $global:wordList = Get-Content -Path $wordListFile 
    }

    for ($i = 1; $i -le $Iterations; $i++) {
        $password = ''
        $length = 0

        while ($length -lt $minLength) {
            $randomWord = Get-Random -InputObject $global:wordList

            foreach ($bannedWord in $BannedWords) {
                $isSafe = $true
                if ($randomWord -match [regex]::Escape($bannedWord) -and $matches[0]) {
                    $isSafe = $false
                    break
                }
            }

            if ($isSafe) {
                if ($Complex) {
                    $PadCharacters = @(' ', ',', ' ', '.', ' ', '/', ' ', '\', ' ', ';', ' ', '-')
                    $case = Get-Random -Minimum 0 -Maximum 4
                    switch ($case) {
                        0 { $password += $randomWord.ToLower() }
                        1 { $password += $randomWord }
                        2 { $password += (Get-Culture).TextInfo.ToTitleCase($randomword.ToLower()) }
                        3 { $password += $randomWord.ToUpper() }
                    }
                }
                else {
                    $password += $randomWord
                }
            }

            $length = $password.Length
            if ($length -lt $minLength) {
                $PadChar = Get-Random -InputObject $PadCharacters
                $password += $PadChar
                $length++
            }
        }

        $password = $password.TrimEnd()
        $passphrases += $password
    }

    $passphrases
}


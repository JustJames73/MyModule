# Generate-RandomPassPhrase.ps1
function Generate-RandomPassPhrase {
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


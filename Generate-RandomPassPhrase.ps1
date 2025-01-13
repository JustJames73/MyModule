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
    
    #Use a blank space as the character between words, this is modified elsewhere of the Complex switch is used
    $PadCharacters = ' '
    
    # Initialize an array to store passphrases
    $passphrases = @()

    # Check if the word list file exists
    if (-not (Test-Path -Path $wordListFile -PathType Leaf)) {
        Write-Verbose -Message "Word list file '$wordListFile' not found. Searching for .words files in the current directory..."

        # Search for *.word files in the current directory
        $wordListFiles = Get-ChildItem -Path $pwd -Filter "*.words" -File -Recurse
        Write-Verbose -Message "Found the following words list: $wordListFiles"
        
        # If no *.words files found, throw an error
        if ($wordListFiles.Count -eq 0) {
            throw "No .words files found in the current directory."
        }

        # Use the first found .word file
        $wordListFile = $wordListFiles[0].FullName
    }

    # Create the wordList as a global variable so that it is not processed everytime the function is run
    if (-not $wordlist) {
        $global:wordList = Get-Content -Path $wordListFile 
    }

#region - PassPhrase generation
    # Generate passphrases for each iteration
    for ($i = 1; $i -le $Iterations; $i++) {
        $password = ''
        $length = 0

        # Keep adding random words until the password length is at least $minLength
        while ($length -lt $minLength) {
            
            # Get a random word from the list
            $randomWord = Get-Random -InputObject $global:wordList

	        # Check if the $radomWord matches $BannedWord
            foreach ($bannedWord in $BannedWords) {
                $isSafe = $true

                # Use case-insensitive regular expression match
                if ($randomWord -match [regex]::Escape($bannedWord) -and $matches[0]) {
                    $isSafe = $false
                    break
                }
            }

	        # If the word is safe, add it to $password
            if ($isSafe) {

                # if the Complex switch is used, modify the case
                if ($Complex) {

                    # Special characters to inject, every other char is a space; 50% chance of giving a space. 
                    $PadCharacters = @(' ', ',', ' ', '.', ' ', '/', ' ', '\', ' ', ';', ' ', '-')

                    # Generate a random number to determine the case
                    $case = Get-Random -Minimum 0 -Maximum 4

                    # Convert the word to the selected case
                    switch ($case) {
                        0 { $password += $randomWord.ToLower() }
                        1 { $password += $randomWord }
                        2 { $password += (Get-Culture).TextInfo.ToTitleCase($randomword.ToLower()) }
                        3 { $password += $randomWord.ToUpper() }
                    }
                }
                else {
                    #Add the unmodified word to the password string
                    $password += $randomWord
                }
            }

            # Check the length and continue processing of too short
            $length = $password.Length
            if ($length -lt $minLength) {

                # Add a special character, the character set is modified when the Complex switch is used
                $PadChar = Get-Random -InputObject $PadCharacters
                $password += $PadChar

                # Increment length to account for the added space
                $length++
            }
        }

        # Remove trailing space
        $password = $password.TrimEnd()

        # Add the passphrase to the array
        $passphrases += $password
    }
#region - PassPhrase generation

    #Output the password, multiple passwords when the Iterations paramater is used
    $passphrases
}


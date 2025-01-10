# MyModule
A collection of my frequently used functions

## Most used functions
### 1. ConvertTo-PowerShellArray
  * My most used function!
  * By default it takes text in the clipboard. With the -InputList parameter it will accept a string or variable
  * Will identify the delimiter in a single string or use CRLF for multiple strings.
  * The **-Sort** switch will "sort -unique"
    * If an IPv4 format is detected it will sort using the [version[]] accelerators
### 3. Search-Scripts
  * Intended for use in an ISE that supports Out-GridView
  * Can be used with any ascii text file.
  * By default the **-Input** property searches for *.ps1 files
  * The **-KeyWord** property uses "Select-String -SimpleMatch $KeyWord"
  * The **-ListView** outputs the entire matched string to the console
  * One or more files selected in the gridview will open in PowerShell-ISE
### 4. Generate-RandomPassPhrase
  * Instead of creating password of random characters assemble longer and less complex passwords from a word list
    * It's a big hit with users asking for a password reset, they often want to keep the generated passphrase
  * Uses the all.words dictionary file that has over 500K lines and a lot of madeup words
  * Set the minimum lenght requirement with the **-minLength** property, default is 15
  * Get multiple options using the **-Iterations** parameter
  * Use the **-Complex** switch to add some complexity by randomly changing the case or adding non-shifted special characters making it easier to type
  * Includes a **-BannedWords** array property to fit the password requirements of the domain, it's easier than modifying the .words file
### 5. Add-TimeStamp
  * Add a sortable timestamp to the begining of a filename
    * Using the **-Suffix** switch adds the timestamp to the end of the filename, depending on sorting preferences
    * Use the **-CopyItem** to create a timestamped copy of the file.
      * This function was originally created for simple verion control 
### 6. Test-MultipleConnections
  * Generate a simple connection test report on multiple hosts and ports, grouped by host
  * Perform ping and port tests on each host
  * output a time stamped report indicating if each test passed or failed. Timestamps are helpful when reviewing logs
### 7. Report-GroupMembers
  * Generate a CSV file report with more information about each user than you get from Get-ADGroupMember
  * _NOT a mature script_, but it get's the job done
    * Edit the function to change the output fields
   
## Additional functions included
* Generate-RandomPassword
  * Written to deal with some funky password requirements
  * Outputs a raondom password 14-21 characters long
* SearchForCommandFromModule
  * Requires knowledge of the module name.
  * Limited use but it was a fun exercise at the time. 
  * Search the script for occurances of any command from the specified module.
  * Output the line number and line with the found commands
* Write-Color
  * Another fun experiment for making console output look pretty with less coding

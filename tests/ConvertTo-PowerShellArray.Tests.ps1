# ConvertTo-PowerShellArray.Tests.ps1

BeforeAll {
    # Import the module or dot-source the function
    . ./ConvertTo-PowerShellArray.ps1

    # Helper function to set clipboard content and run the function
    function Test-WithClipboardInput {
        param([string]$input)
        Set-Clipboard -Value $input
        ConvertTo-PowerShellArray
    }
}

Describe "ConvertTo-PowerShellArray" {
    Context "When handling Distinguished Names (DN)" {
        It "Should properly format a single DN" {
            $input = "CN=User1,OU=Department,DC=contoso,DC=com"
            $expected = "@('CN=User1,OU=Department,DC=contoso,DC=com')"
            Test-WithClipboardInput -input $input | Should -Be $expected
        }

        It "Should handle multiple DNs with line breaks" {
            $input = @"
CN=User1,OU=Department,DC=contoso,DC=com
CN=User2,OU=Department,DC=contoso,DC=com
"@
            $expected = "@('CN=User1,OU=Department,DC=contoso,DC=com','CN=User2,OU=Department,DC=contoso,DC=com')"
            Test-WithClipboardInput -input $input | Should -Be $expected
        }

        It "Should handle DNs with escaped commas" {
            $input = "CN=User\, Joe,OU=Department,DC=contoso,DC=com"
            $expected = "@('CN=User\, Joe,OU=Department,DC=contoso,DC=com')"
            Test-WithClipboardInput -input $input | Should -Be $expected
        }

        It "Should handle DNs with spaces" {
            $input = "CN=Joe Smith,OU=IT Department,DC=contoso,DC=com"
            $expected = "@('CN=Joe Smith,OU=IT Department,DC=contoso,DC=com')"
            Test-WithClipboardInput -input $input | Should -Be $expected
        }
    }

    Context "When handling comma-separated values" {
        It "Should properly format comma-separated items" {
            $input = "item1,item2,item3"
            $expected = "@('item1','item2','item3')"
            Test-WithClipboardInput -input $input | Should -Be $expected
        }

        It "Should handle empty entries in comma-separated list" {
            $input = "item1,,item2,,,item3"
            $expected = "@('item1','item2','item3')"
            Test-WithClipboardInput -input $input | Should -Be $expected
        }

        It "Should handle whitespace around comma-separated items" {
            $input = "item1 , item2 , item3"
            $expected = "@('item1','item2','item3')"
            Test-WithClipboardInput -input $input | Should -Be $expected
        }
    }

    Context "When handling space-separated values" {
        It "Should properly format space-separated items" {
            $input = "item1 item2 item3"
            $expected = "@('item1','item2','item3')"
            Test-WithClipboardInput -input $input | Should -Be $expected
        }

        It "Should handle multiple spaces between items" {
            $input = "item1    item2     item3"
            $expected = "@('item1','item2','item3')"
            Test-WithClipboardInput -input $input | Should -Be $expected
        }

        It "Should handle leading and trailing spaces" {
            $input = "  item1 item2 item3  "
            $expected = "@('item1','item2','item3')"
            Test-WithClipboardInput -input $input | Should -Be $expected
        }
    }

    Context "When handling multi-line input" {
        It "Should handle Windows-style line endings (CRLF)" {
            $input = "line1`r`nline2`r`nline3"
            $expected = "@('line1','line2','line3')"
            Test-WithClipboardInput -input $input | Should -Be $expected
        }

        It "Should handle Unix-style line endings (LF)" {
            $input = "line1`nline2`nline3"
            $expected = "@('line1','line2','line3')"
            Test-WithClipboardInput -input $input | Should -Be $expected
        }

        It "Should handle empty lines in multi-line input" {
            $input = "line1`r`n`r`nline2`r`n`r`nline3"
            $expected = "@('line1','line2','line3')"
            Test-WithClipboardInput -input $input | Should -Be $expected
        }
    }

    Context "When handling special cases" {
        It "Should handle single quotes in input" {
            $input = "O'Connor,D'Angelo,McDonald"
            $expected = "@('O''Connor','D''Angelo','McDonald')"
            Test-WithClipboardInput -input $input | Should -Be $expected
        }

        It "Should handle input with mixed delimiters" {
            $input = "item1,item2 item3`r`nitem4"
            $expected = "@('item1','item2','item3','item4')"
            Test-WithClipboardInput -input $input | Should -Be $expected
        }

        It "Should handle single item input" {
            $input = "singleitem"
            $expected = "@('singleitem')"
            Test-WithClipboardInput -input $input | Should -Be $expected
        }

        It "Should handle empty input" {
            $input = ""
            $expected = "@()"
            Test-WithClipboardInput -input $input | Should -Be $expected
        }
    }

    Context "When using the Sort parameter" {
        It "Should sort regular text items" {
            $input = "charlie,alpha,bravo"
            $expected = "@('alpha','bravo','charlie')"
            Set-Clipboard -Value $input
            ConvertTo-PowerShellArray -Sort | Should -Be $expected
        }

        It "Should sort IP addresses correctly" {
            $input = "192.168.1.10,192.168.1.2,192.168.1.1"
            $expected = "@('192.168.1.1','192.168.1.2','192.168.1.10')"
            Set-Clipboard -Value $input
            ConvertTo-PowerShellArray -Sort | Should -Be $expected
        }
    }
}

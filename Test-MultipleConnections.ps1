# Test-MultipleConnections.ps1
function Test-MultipleConnections {
<#
.SYNOPSIS
    The Test-MultipleConnections function allows you to supply multiple hosts and ports.
.DESCRIPTION
.VERSION
    2.2404.03
.NOTES
     
    Both the hosts and ports can be supplied by a multivalued string array
      Ex: $hosts = 'host1','host2'; $ports= 80, 443
    The function will return results in a table format with timestamps
    Sample useage:
      # Define IP addresses and ports
      $ipList = "1.1.1.1", "1.1.1.2"
      $portList = 80, 443
      # Run the test
      Test-MultipleConnections -ipList $ipList -portList $portList
    20240325: added a progress bar based on the count of the $ipList
    20240326: #TODOs 
        Get-NetAdapter: Identify the PANGP network interface
        Get-NetRoute: Filter routes applied to the PANGP interface
        Compare routes to ipList (needs a function for expanding CIDR ranges)
        DNS lookup of the ipList, identify unresolvable addresses
        Add timers for start, end, duration of the run
    20240403: Added alias to the function and moved the comment block
#>

    [Alias('TMC')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ipList,

        [Parameter(Mandatory = $false)]
        [int[]]$portList
    )
    
    BEGIN {
        # Initialize arrays to store results
        $results = @()

        # Counts for progress
        $ipTotal = $ipList.count
        $ipCounter = 0

    }

    PROCESS {
        # Loop through each IP address in the list
        foreach ($ip in $ipList) {
#region - progressbar
            # Increment the counter
            $ipCounter++
            # Write the progress bar
            Write-Progress -Activity 'Testing' -Status "Testing host $ipCounter of $ipTotal" -PercentComplete (($ipCounter / $ipTotal) * 100) -Id 1
#endregion - progressbar

            # Loop through each port in the list
            IF ($portList) {
                foreach ($port in $portList) {
                    # Test the connection
                    $testResult = Test-NetConnection -ComputerName $ip -Port $port -InformationLevel Detailed

                    # Add the result to the results array with a timestamp
                    $results += ($testResult | select @{name='TimeStamp';expression={$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')}}, SourceAddress, RemoteAddress, PingSucceeded, RemotePort, TcpTestSucceeded )
                }
            }
            ELSE {
                # Test the connection
                $testResult = Test-NetConnection -ComputerName $ip -InformationLevel Detailed

                # Add the result to the results array with a timestamp
                $results += ($testResult | select @{name='TimeStamp';expression={$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')}}, SourceAddress, RemoteAddress, PingSucceeded, @{name='RemotePort';expression={'NA'}}, @{name='TcpTestSucceeded';expression={'NA'}} )
            }
            Write-Progress -Activity "Testing" -Status "Completed" -Completed -Id 1
        }
    }

    END {
        # Output the results
        RETURN $results | Format-Table -AutoSize
    }
}

# Test-MultipleConnections.ps1
function Test-MultipleConnections {
<#
.SYNOPSIS
    The Test-MultipleConnections function allows you to supply multiple hosts and ports.
.DESCRIPTION
    Tests connectivity to multiple hosts and ports, resolves hostnames for IP addresses,
    and detects web services if applicable.
.VERSION
    2.2404.04
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
    20240404: Added hostname resolution and web service detection
#>

    [Alias('TMC')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ipList,

        [Parameter(Mandatory = $false)]
        [int[]]$portList,
        
        [Parameter(Mandatory = $false)]
        [switch]$DetectWebServices = $true
    )
    
    BEGIN {
        # Initialize arrays to store results
        $results = @()

        # Counts for progress
        $ipTotal = $ipList.count
        $ipCounter = 0
        
        # Function to resolve IP to hostname
        function Resolve-HostName {
            param([string]$IPAddress)
            try {
                # Try to get the hostname - this may fail for various reasons
                $hostEntry = [System.Net.Dns]::GetHostEntry($IPAddress)
                return $hostEntry.HostName
            }
            catch {
                # If we can't resolve, return "Unresolved"
                return "Unresolved"
            }
        }
        
        # Function to check if web service is running
        function Test-WebService {
            param(
                [string]$Address,
                [int]$Port
            )
            
            # Don't try to test non-HTTP ports
            if ($Port -ne 80 -and $Port -ne 443) {
                return "N/A"
            }
            
            $protocol = if ($Port -eq 443) { "https" } else { "http" }
            $url = "$($protocol)://$($Address)"
            
            try {
                # Disable certificate validation for HTTPS to avoid errors with self-signed certs
                if ($Port -eq 443) {
                    # Save current security protocol
                    $currentProtocol = [System.Net.ServicePointManager]::SecurityProtocol
                    
                    # Add TLS protocols
                    [System.Net.ServicePointManager]::SecurityProtocol = 
                        [System.Net.SecurityProtocolType]::Tls12 -bor 
                        [System.Net.SecurityProtocolType]::Tls11 -bor 
                        [System.Net.SecurityProtocolType]::Tls
                    
                    # Ignore certificate validation
                    $originalCallback = [System.Net.ServicePointManager]::ServerCertificateValidationCallback
                    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
                }
                
                # Set a short timeout to avoid hanging
                $request = [System.Net.WebRequest]::Create($url)
                $request.Timeout = 3000 # 3 seconds
                $request.Method = "HEAD" # Just get headers, not the full content
                
                # Get the response
                $response = $request.GetResponse()
                $statusCode = [int]$response.StatusCode
                $response.Close()
                
                # Return status code and description
                return "$($statusCode) $($response.StatusDescription)"
            }
            catch [System.Net.WebException] {
                # Check if there was a response even though there was an exception
                if ($_.Exception.Response) {
                    $statusCode = [int]$_.Exception.Response.StatusCode
                    return "$statusCode $($_.Exception.Response.StatusDescription)"
                }
                return "Error: $($_.Exception.Message)"
            }
            catch {
                return "Error: $($_.Exception.Message)"
            }
            finally {
                # Restore original settings if we modified them
                if ($Port -eq 443) {
                    [System.Net.ServicePointManager]::SecurityProtocol = $currentProtocol
                    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $originalCallback
                }
            }
        }
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
            
            # Resolve hostname
            $hostname = Resolve-HostName -IPAddress $ip
            
            # Loop through each port in the list
            IF ($portList) {
                foreach ($port in $portList) {
                    # Test the connection
                    $testResult = Test-NetConnection -ComputerName $ip -Port $port -InformationLevel Detailed
                    
                    # Check for web service if enabled and connection succeeded
                    $webServiceStatus = "N/A"
                    if ($DetectWebServices -and $testResult.TcpTestSucceeded) {
                        # Use IP address by default
                        $addressToTest = $ip
                        
                        # If hostname is resolved and not "Unresolved", use it instead
                        if ($hostname -ne "Unresolved") {
                            $addressToTest = $hostname
                        }
                        
                        $webServiceStatus = Test-WebService -Address $addressToTest -Port $port
                    }

                    # Add the result to the results array with a timestamp
                    $results += $testResult | Select-Object `
                        @{Name='TimeStamp';Expression={$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')}}, 
                        SourceAddress, 
                        RemoteAddress, 
                        @{Name='HostName';Expression={$hostname}}, 
                        PingSucceeded, 
                        RemotePort, 
                        TcpTestSucceeded, 
                        @{Name='WebService';Expression={$webServiceStatus}}
                }
            }
            ELSE {
                # Test the connection without port
                $testResult = Test-NetConnection -ComputerName $ip -InformationLevel Detailed

                # Add the result to the results array with a timestamp and hostname
                $results += $testResult | Select-Object `
                    @{Name='TimeStamp';Expression={$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')}}, 
                    SourceAddress, 
                    RemoteAddress, 
                    @{Name='HostName';Expression={$hostname}}, 
                    PingSucceeded, 
                    @{Name='RemotePort';Expression={'NA'}}, 
                    @{Name='TcpTestSucceeded';Expression={'NA'}}, 
                    @{Name='WebService';Expression={'NA'}}
            }
            Write-Progress -Activity "Testing" -Status "Completed" -Completed -Id 1
        }
    }

    END {
        # Output the results
        RETURN $results | Format-Table -AutoSize
    }
}

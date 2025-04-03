function Convert-CIDRToIPRange {
    <#
    .SYNOPSIS
        Converts CIDR notation to a list of IP addresses in the range.
    
    .DESCRIPTION
        This function takes a CIDR notation (e.g. 192.168.1.0/24) and returns all usable IP addresses in that range.
        Perfect for when you need to enumerate all IPs in a subnet but don't want to do math. Because who does?
    
    .PARAMETER CIDRNotation
        The CIDR notation to convert (e.g. 192.168.1.0/24)
    
    .PARAMETER ExcludeNetworkAndBroadcast
        Switch to exclude network address and broadcast address from the results
    
    .EXAMPLE
        Convert-CIDRToIPRange -CIDRNotation "192.174.2.32/27"
        Returns all 32 IP addresses in the 192.174.2.32/27 CIDR range
    
    .EXAMPLE
        Convert-CIDRToIPRange -CIDRNotation "192.174.2.32/27" -ExcludeNetworkAndBroadcast
        Returns only the 30 usable IP addresses, excluding network and broadcast addresses
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidatePattern("^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}$")]
        [string]$CIDRNotation,
        
        [Parameter(Mandatory = $false)]
        [switch]$ExcludeNetworkAndBroadcast = $false
    )
    
    # Split CIDR notation into IP and prefix
    $CIDRParts = $CIDRNotation.Split('/')
    $IPAddress = $CIDRParts[0]
    $PrefixLength = [int]$CIDRParts[1]
    
    # Validate prefix length
    if ($PrefixLength -lt 0 -or $PrefixLength -gt 32) {
        throw "Prefix length must be between 0 and 32"
    }
    
    # Convert IP address to integer
    $IPOctets = $IPAddress.Split('.')
    # If we're working with IPs, we're in 32-bit land. No need for [int64].
    # But this allows us to do bitshifting without worrying about signed integers.
    [int64]$IPInt = ([int]$IPOctets[0] -shl 24) + ([int]$IPOctets[1] -shl 16) + ([int]$IPOctets[2] -shl 8) + [int]$IPOctets[3]
    
    # Calculate subnet mask
    [int64]$SubnetMask = -bnot ((1 -shl (32 - $PrefixLength)) - 1) -band [int64]::MaxValue
    
    # Calculate network address (bitwise AND of IP and subnet mask)
    $NetworkAddressInt = $IPInt -band $SubnetMask
    
    # Calculate broadcast address (network address + wildcard mask)
    $WildcardMask = -bnot $SubnetMask -band [int64]::MaxValue  # Need to mask to 32 bits
    $BroadcastAddressInt = $NetworkAddressInt -bor $WildcardMask
    
    # Generate all IP addresses in the range
    $IPAddresses = @()
    
    # Determine start and end IPs based on whether to exclude network and broadcast
    $StartIP = $NetworkAddressInt
    $EndIP = $BroadcastAddressInt
    
    if ($ExcludeNetworkAndBroadcast -and $PrefixLength -lt 31) {
        # Only exclude if the subnet is large enough to have distinct network/broadcast addresses
        $StartIP++
        $EndIP--
    }
    
    # This hurts my brain less than triple-nested for loops
    for ($i = $StartIP; $i -le $EndIP; $i++) {
        # Convert integer back to IP address
        $FirstOctet = ($i -shr 24) -band 255
        $SecondOctet = ($i -shr 16) -band 255
        $ThirdOctet = ($i -shr 8) -band 255
        $FourthOctet = $i -band 255
        
        $IPAddresses += "$FirstOctet.$SecondOctet.$ThirdOctet.$FourthOctet"
    }
    
    # Return our beautiful array of IPs
    return $IPAddresses
}

# Example usage: 
# $IPs = Convert-CIDRToIPRange -CIDRNotation "192.174.2.32/27" -ExcludeNetworkAndBroadcast
# $IPs

# Quick explanation of results from the example:
# 192.174.2.32/27 means:
# - Network address: 192.174.2.32 (excluded with -ExcludeNetworkAndBroadcast)
# - Broadcast address: 192.174.2.63 (excluded with -ExcludeNetworkAndBroadcast)
# - Usable IPs: 192.174.2.33 through 192.174.2.62 (30 addresses)

function GetAllDomainControllerLastLogon 
{
    param 
    (
        [string] $identifier,
        [string] $executionPath
    )

    $output = @()
    $servers =  (Get-ADDomainController -Filter *).Name

    foreach ($server in $servers)
    {
        Write-Host ("Now querying DC " + $server + " ...")
        if($executionPath -eq "User")
            {$time = (Get-ADUser $identifier -Properties * -Server $server).LastLogon}
        else 
            {$time = (Get-ADComputer $identifier -Properties * -Server $server).LastLogon}
        $output += [PSCustomObject]@{LastLogon=[datetime]::FromFileTime($time); DC = $server}
    }

    $output
}

function GetAllUserValues
{
    param ([string] $identifier)

    try 
    {
        $user = Get-ADUser -Identity $identifier -Properties * 
    
        $name = $user | select -expand DisplayName 
        $id = $user | select -expand EmployeeID
        $lastdc = $user | select -expand LastLogon
        $lastdc = [datetime]::FromFileTime($lastdc)
        $lastad = $user | select -expand LastLogonTimestamp 
        $lastad = [datetime]::FromFileTime($lastad)
        
        Write-Host("Username: $name")
        Write-Host("ID:       $id")
        Write-Host("Last Connected to Network (DC): $lastdc")
        Write-Host("Last Connected to Network (AD): $lastad")
    }
    catch
    {Write-Error $_}
}

function GetAllDeviceValues
{
    param ([string] $identifier)

    try
    {
        $comp = Get-ADComputer -Identity $identifier -Properties *

        $lastip = $comp | select -expand IPv4Address
        $lastdc = $comp | select -expand LastLogon
        $lastdc = [datetime]::FromFileTime($lastdc)
        $lastad = $comp | select -expand LastLogonTimestamp 
        $lastad = [datetime]::FromFileTime($lastad)
        $isconnected = test-connection $identifier -quiet -count 1
        if($isconnected -eq "True")
        {$user = (Get-WmiObject -class Win32_ComputerSystem -ComputerName $identifier).Username}
        else 
        {$user = "N/A"}

        Write-Host("Name: $identifier")
        Write-Host("Last Used IP Address: $lastip")
        Write-Host("Last Connected to Network (DC): $lastdc")
        Write-Host("Last Connected to Network (AD): $lastad")
        Write-Host("Is currently logged in: $isconnected")
        Write-Host("Current User: $user")
    } 
    catch 
    {Write-Error $_}
}


function LastLogon
{
    <#
        .SYNOPSIS
        Lookup info about a user or computer in ActiveDirectory.
        .DESCRIPTION
        For devices, responds with last logon time both local DC and AD replicated, IP Address, current device powered on state, and current login state for devices.

        For users, responds with last logon time, ID number, and display name.
        .NOTES
        The "LastLogon" field is NOT when a user last logged in. Read more at 
        https://techcommunity.microsoft.com/t5/ask-the-directory-services-team/8220-the-lastlogontimestamp-attribute-8221-8211-8220-what-it-was/ba-p/396204

        .EXAMPLE
        lastlogon -user -anydc Test    
    #>

    param 
    (
        [Parameter(Mandatory)] $identifier,
        [switch] $anydc = $false,
        [switch] $user = $false,
        [switch] $comp = $false,
        [switch] $help = $false
    )

    if($help -eq $true)
    {
        Get-Help LastLogon
        break
    }

    $executionPath = "Computer"

    if($user -eq $true)
        {$executionPath = "User"}
    elseif ($comp -eq $true) 
        {$executionPath = "Computer"}
    else 
    {
        #Insert your own domain-specific parsing here. or just use defaults 
        {$executionPath = "Computer"}
    }


    if($anydc -eq $true)
        {GetAllDomainControllerLastLogon $identifier $executionPath}
    elseif($executionPath -eq "User")
        {GetAllUserValues $identifier}
    elseif($executionPath -eq "Computer")
        {GetAllDeviceValues $identifier }
    else
        {Write-Host("Error parsing input of '" + $identifier +"'.")}
    
}

Export-ModuleMember -Function LastLogon

Function Test-CloudFlare {
    <#
        .SYNOPSIS
        Allows a remote session to run a ping test
        .DESCRIPTION
        Changes the session to a remote session and runs a test-netconnection on the session
        .PARAMETER Computername
        The name/ip address of the computer being tested
        .PARAMETER Path
        The location where the output of the script will be stored
        .PARAMETER Output
        Specifies how the output will be delivered when the script is run. Acceptable values are:
        Host (Displays in the help section)
        Test (Displays in a text file)
        CSV (Displays in an CSV file)
        .PARAMETER Alias
        A quicker way to access your computername value by using CN or Name. This pulls information from the $Computername variable and allows a shortcut
        .NOTES
        Author: Ryan Davis
        Last Edit: 11/12/2021
        Version 1.0.12 - Initial Release of Test-CloudFlare (Beta)
        
        EXAMPLE 1
    PS C:\Powershell Test> .\Test-CloudFlare.ps1 -Computername 192.168.1.38 -Output Host
        
        EXAMPLE 2
    PS C:\Powershell Test> .\Test-CloudFlare.ps1 -Computername 192.168.1.38 -Output Text
    
        EXAMPLE 3
    PS C:\Powershell Test> .\Test-CloudFlare.ps1 -Computername 192.168.1.38 -Output CSV
    
    #>
    [CmdletBinding()]
    
    Param (
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [Alias('CN','Name')][string]$ComputerName,
        [Parameter(Mandatory=$False)]
        [string]$Path = $env:USERPROFILE,
        [Parameter(Mandatory=$False)]
        [ValidateSet ('Host', 'Text', 'CSV')]
        [string]$Output = 'Host')
    
    
    ForEach ($Computer in $Computername) {
            Try {
                    $Params = @{
                            'Computername' = $Computer
                            'ErrorAction' = 'Stop'
                }
        #Attempting to access different computers on the network, defined within the $Computer parameter. If not accessible, will STOP
        $RemoteSession = New-PSSession @Params
        #Establishing a new remote session using the $RemoteSession variable with our computer, defined within the $Computer variable
        Enter-PSSession $RemoteSession
        #Connecting to the remote session
        $DateTime = Get-Date
        #Creating a variable called $DateTime, where we retrieve the date
        $TestCF = Test-NetConnection -Computername 'one.one.one.one' -InformationLevel Detailed
        #Created the $TestCF variable as a quick way to test network connection status of our computername, with detailed information
        $OBJ = [PSCustomObject]@{
            'Computername' = $Computer
            'PingSuccess' = $TestCF.PingSucceeded
            'NameResolve' = $TestCF.NameResolutionSucceeded
            'ResolvedAddresses' = $TestCF.ResolvedAddress
        }
        #This variable we created allows us to set custom properties of test results and how they will be displayed
        Exit-PSSession
        #Exiting the session
        Remove-PSSession $RemoteSession
        #Ending the remote session
        }
        Catch {
            Write-Host "Remote Connection to $Computer has failed." -ForegroundColor Red
        }
        #Will return a failed connection output if the computer attempting to be tested is unreachable
    }
    Switch ($Output) {
        #Switch allows us to change the output results based on what is inputted into the $Output variable, which is set up as Host by default
        "Text" {
            Write-Verbose "Generating test results"
            #Outputs information on the screen when using -verbose with your script
            $OBJ | Out-File '.\TestResults.txt'
            #Sending the results to a file called TestResults.txt
            Add-Content '.\RemTestNet.txt' -value "Computer Tested : $Computer"
            #Adding information to the text file, specifically the computername and that it was tested
            Add-Content '.\RemTestNet.txt' -value "Date and Time Tested : $DateTime"
            #Adding information to the text file, specifically the Date and time it was tested
            Add-Content '.\RemTestNet.txt' -value (Get-Content -Path '.\TestResults.txt')
            #Adding the content from the file we originally exported, TestResults.txt, to another text file called RemTestNet.txt
            Write-Verbose "Test Complete"
            #Outputs information on the screen when using -verbose with your script
            Write-Verbose "Opening Test Results"
            #Outputs information on the screen when using -verbose with your script
            Notepad.exe '.\RemTestNet.txt'
            #Executing the RemTestNet text document to notepad
            Remove-Item '.\TestResults.txt'
            #Removing the original file we pulled information from, as it is no longer needed
            }
        "CSV" {
            Write-Verbose "Generating results to CSV file"
            #Outputs information on the screen when using -verbose with your script
            $OBJ | Export-CSV .\TestResults.csv
            #Exporting the results of the output to a CSV file, TestResults.csv
            }
        "Host" {
            Write-Verbose "Generating results file and displaying it to the screen"
            #Outputs information on the screen when using -verbose with your script
            $OBJ
            #Because we are not exporting the results of the $OBJ variable, this information will display within powershell
            }
        }
}


Function Enter-SSP {
    <#
	.SYNOPSIS
		Connect to remote computer using Credssp protocol with custom credentials
	
	.DESCRIPTION
		Enables both local and remote machine to participate in a Credssp session and establishes a PSRemote session using Credssp protocol.
	
    .PARAMETER ComputerName
        Remote computer name
    
    .PARAMETER Credential
        PSCredential object used for authentication
    .EXAMPLE
		# Connect to remote computer MyRemoteComputer and ask for credentials
        Enter-SSP MyRemoteComputer
    .EXAMPLE   
        # Connect to remote computer PC2 with custom credentials
        $cred = Get-Credential
        Enter-SSP -ComputerName PC2 -Credential $cred
#>

    Param (
        [Parameter(Mandatory = $true,
            Position = 1)]
        [string]$ComputerName,
        [pscredential]$Credential
    )

    # Get the ID and security principal of the current user account
    $myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent();
    $myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID);
    
    # Get the security principal for the administrator role
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;
    
    # Check to see if we are currently running as an administrator
    if (!$myWindowsPrincipal.IsInRole($adminRole)) {  
        #Restart the script as admin
        $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

        # Specify the current script path and name as a parameter
        $newProcess.Arguments = "-noexit", $MyInvocation.MyCommand, $ComputerName
    
        # Indicate that the process should be elevated
        $newProcess.Verb = "runas";
    
        # Start the new process
        $null = [System.Diagnostics.Process]::Start($newProcess);
        #Exit from current unnecessary process
        Return
    }

    If (!$Credential) {
        $Credential = Get-Credential -Credential "$($env:USERDOMAIN)\$($env:USERNAME)"
        If (!$Credential) { Return }
    }
        
    Invoke-Command -Computer $ComputerName { 
        # Enable SSP on the remote machine
        $null = Enable-WSManCredSSP -Role Server -Force
    }
    # Start local WinRM service
    Get-Service winrm | Start-Service
    # Enable SSP on local machine
    $null = Enable-WSManCredSSP -role Client -DelegateComputer $ComputerName -Force

    New-PSSession -ComputerName $ComputerName -Credential $Credential -Authentication Credssp | Enter-PSSession

}
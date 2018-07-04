# About
This Powershell module contains a single command Enter-SSP, which allows you to configure your local and remote computers to establish a secure Credssp session on the remote machine, which will work around limitations of a standard Kerberos session that was not properly configured for credentials delegation.

The established session would act as if you're logged locally on the remote machine and will be able to talk with other remote machines through Kerberos protocol without configuring delegation.

# Installation

Note: if started from a non-elavated session, requires the module to be loaded automatically with session (be in one of the shared modules folder). Otherwise, the function will fail to start, as it will start a new elevated Powershell session automatically.

## PSGallery:

```powershell
Install-Module EnterSSP
```

## Manual

```powershell
git clone https://github.com/nvarscar/enterssp.git
Copy-Item .\enterssp "$([environment]::getfolderpath('mydocuments'))\WindowsPowershell\Modules" -Recurse 
```

# Usage

```powershell
# Connect to remote computer MyRemoteComputer and ask for credentials
Enter-SSP MyRemoteComputer

# Connect to remote computer PC2 with custom credentials
$cred = Get-Credential
Enter-SSP -ComputerName PC2 -Credential $cred
```
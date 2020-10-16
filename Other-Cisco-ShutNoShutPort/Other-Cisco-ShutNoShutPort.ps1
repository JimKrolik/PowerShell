<#

Authored by
James Krolik

Purpose:
The purpose of this PowerShell script is to connect to a Cisco switch via SSH and perform various commands.

Dependencies:
This script was tested with and requires Posh-SSH to be installed.  This script was tested with version 2.1.

Web:                         https://www.powershellgallery.com/packages/Posh-SSH/2.1
PowerShell Command:          Install-Module -Name Posh-SSH -RequiredVersion 2.1 

Notes:
I typically run this manually and if the session does not establish, I will restart it and ensure it has a valid session prior. 

#>

############
#Example 1:
###########
#Connect to a port and shut / no shut it.

#Establish the SSH session, prompting the user for credentials
New-SSHSession -ComputerName 172.16.16.118 -credential (Get-Credential)

#Start a new session
$stream = New-SSHShellStream -index 0

#Start sending commands
Invoke-SSHStreamShellCommand -shellstream $stream -command "config t"

Invoke-SSHStreamShellCommand -shellstream $stream -command "int Gi1/0/46"
Invoke-SSHStreamShellCommand -shellstream $stream -command "shut"

Sleep -seconds 2

Invoke-SSHStreamShellCommand -shellstream $stream -command "no shut"

#Clean up the session
Get-SSHSession | Remove-SSHSession

##########
#Example 2:
##########

#Connect to a port and properly remove PoE power

#Establish the SSH session, prompting the user for credentials
New-SSHSession -ComputerName 172.16.16.118 -credential (Get-Credential)

#Start a new session
$stream = New-SSHShellStream -index 0

#Start sending commands
Invoke-SSHStreamShellCommand -shellstream $stream -command "config t"

Invoke-SSHStreamShellCommand -shellstream $stream -command "int Gi1/0/46"
Invoke-SSHStreamShellCommand -shellstream $stream -command "power inline never"

Sleep -seconds 15

Invoke-SSHStreamShellCommand -shellstream $stream -command "power inline auto"

#Clean up the session
Get-SSHSession | Remove-SSHSession
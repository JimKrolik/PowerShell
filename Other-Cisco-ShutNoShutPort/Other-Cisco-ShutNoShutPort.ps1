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
New-SSHSession -ComputerName 172.16.16.118 -credential (get-credential)

#Start a new session
$session = New-SSHShellStream -index 0

#Start sending commands
invoke-sshstreamshellcommand -shellstream $stream -command "config t"

invoke-sshstreamshellcommand -shellstream $stream -command "int Gi1/0/46"
invoke-sshstreamshellcommand -shellstream $stream -command "shut"

sleep -seconds 2

invoke-sshstreamshellcommand -shellstream $stream -command "no shut"

#Clean up the session
get-sshsession | remove-sshsession

##########
#Example 2:
##########

#Connect to a port and properly remove PoE power

#Establish the SSH session, prompting the user for credentials
New-SSHSession -ComputerName 172.16.16.118 -credential (get-credential)

#Start a new session
$session = New-SSHShellStream -index 0

#Start sending commands
invoke-sshstreamshellcommand -shellstream $stream -command "config t"

invoke-sshstreamshellcommand -shellstream $stream -command "int Gi1/0/46"
invoke-sshstreamshellcommand -shellstream $stream -command "power inline never"

sleep -seconds 15

invoke-sshstreamshellcommand -shellstream $stream -command "power inline auto"

#Clean up the session
get-sshsession | remove-sshsession
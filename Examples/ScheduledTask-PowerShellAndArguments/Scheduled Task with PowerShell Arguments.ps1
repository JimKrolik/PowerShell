<#
Authored by
James Krolik
The purpose of this script create a scheduled task via PowerShell that repeats hourly.  In the case here, I had a need with AlwaysOnVPN to ensure the wireless interface was
always set to 'Private' since 'Public' would cause it to fail.

#>

#Create the action with the path to PowerShell with the argument.  Double "" means insert a quote without breaking the string.
$Action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -argument "Get-NetConnectionProfile -InterfaceAlias ""Wi-Fi"" | Set-NetConnectionProfile -NetworkCategory Private"

#Create the trigger.
$Trigger = New-ScheduledTaskTrigger -once -at (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 60)

#Set the principal name.  In our case, use system since this requires admin rights.
$Principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount

#Finally create the task.
Register-ScheduledTask -Action $Action -Trigger $Trigger -Principal $principal -TaskName "SetWiFiToPrivate" -Description "This will automatically set any 'Wi-Fi' interface to Private for the VPN."
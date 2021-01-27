<#
Authored by
James Krolik

The purpose of this script is remove an explicit messaging policy in Teams.  In this case, specifically the 'EduFaculty' policy that is defined for schools automatically.
It will find all users assigned the 'EduFaculty' policy and re-assign them to null, which effectively removes the explicit policy definition.

Requirements:
    
    Teams PowerShell module installed.
        https://docs.microsoft.com/en-us/microsoftteams/teams-powershell-install
    Skype Online Connector module installed.
        https://docs.microsoft.com/en-us/skypeforbusiness/set-up-your-computer-for-windows-powershell/download-and-install-the-skype-for-business-online-connector  (Requires a restart of the PC).
#>



Import-Module MicrosoftTeams
Import-Module SkypeOnlineConnector

#Clean up any residual session if re-run multiple times
Remove-PSSession $sfbSession 

$userCredential = Get-Credential
$sfbSession = New-CsOnlineSession -Credential $userCredential

$File = $PSScriptRoot + "\Test.csv"
Import-PSSession $sfbSession

#Dump all users with the policy to a CSV to re-import.
    
Get-CsOnlineUser -filter {TeamsMessagingPolicy -eq 'EduFaculty'} | Select displayname,userprincipalname |  Export-Csv $file -notypeinformation

#sleep to let it propagate
write-host "Done writing file."
start-sleep 5
write-host "Reading file."

$dataInFile = Import-CSV $File
ForEach ($dataFromCSV in $dataInFile) {

$NameFromCSV = $dataFromCSV.userprincipalname


<#

I left this in as an example of if we wanted to target a specific user.

    if ($NameFromCSV -eq "specificUser@mydomain.org") {
        write-host "Found specific user"
    }
#>

#Assign $null to the policy to remove anything explicitly defined and default back to Org.
Grant-CsTeamsMessagingPolicy -Identity $NameFromCSV -PolicyName $null


}


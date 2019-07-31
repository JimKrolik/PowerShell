<#

Author: James Krolik

Purpose: The purpose of this script is to add a Mail Relay account to Office 365.  This is for enabling Scan To E-mail on most copiers so the copier can send on behalf of the user.

Dependencies:
This script requires the Windows Feature Remote Server Administration Tools be enabled to import the ActiveDirectory module.
This script requires the MSOnline modules be installed.  These can be installed from PowerShell by the following command:  Install-Module MSOnline


#>


Import-Module ActiveDirectory  #active directory module import
Import-Module MSOnline  #O365 module import

$logFile = "C:\MyLog.log" #Specify the log location

$credential = get-credential  #Get credentials with admin access to Office 365 online as a full e-mail address: someAdmin@mydomain.org

#This will clean any existing connection to Office 365
Get-pssession | Remove-pssession

#Output to the console and then output to the log
"Connecting to Office 365 Exchange session." | out-file $logFile -append

#Connect to Office 365 Exchange Online
$exchangeSession = new-pssession -configurationname microsoft.exchange -connectionuri "https://outlook.office365.com/powershell-liveid/" -credential $credential -authentication "Basic" -allowredirection
import-pssession $exchangeSession -disablenamechecking

#Write the connection status to the log
"Connected to Office 365 Exchange session." | out-file $logFile -append

#Connect to O365 online service.
"Connecting to Office 365 service." | out-file $logFile -append
Connect-MSOLservice -credential $credential

#Let the script sleep to catch up with connection.
start-sleep -s 5

#Get the list of users from a distribution list or group.
$groupMembers = Get-DistributionGroupMember -id "Teachers"


foreach ($member in $groupMembers) {

#Check if a trustee (Send As) has been set.
$checkIfRelaySet = (get-recipientpermission -Identity $member.Name).trustee 

#Check for a matching Send As matching MailRelay since my district uses the account mailrelay@mydomain.org as a Send As trustee.
    if ($checkIfRelaySet -like '*MailRelay*') {

    #Left here for any additional matching.

    }

    else {
        #For reading purposes, output the name and flag status
        write-host $member.name " - " $checkIfRelaySet

        #Add the mail relay account
        Add-RecipientPermission -identity $member.Name -accessrights SendAs -trustee mailrelay@mydomain.org -confirm:$false
    }


}





<#
Authored by:
James Krolik

The purpose of this script is to quickly generate a set amount of accounts in Active Directory.

Requirements:
    The Active Directory powershell module needs to be installed.

#>

Import-Module ActiveDirectory

$Password = "$ecureP@ssword!"
$OU = "OU=Temporary Sub Accounts,OU=Generic User Accounts,DC=mydomain,DC=org"
$tempPrefix = "temp"
$numOfAccountsNeeded = 50
$description = "Temporary Account"


for ($i = 1; $i -le $numOfAccountsNeeded; $i++) {


$username = $tempPrefix + $i
$email = $tempPrefix + $i + "@myemaildomain.org"
$lastName = "Account" + $i
$firstName = "Temporary"

$lastFirst = $LastName + ", " + $FirstName


New-ADUser -SamAccountName $username -Name $lastFirst -GivenName $firstName -Surname $lastName -DisplayName $lastFirst -EmailAddress $email -UserPrincipalName $email -ChangePasswordAtLogon $false -Path $OU

#Sleep to give the accounts time to propagate if needed.  In single site instances, this can be commented out or omitted entirely.
Start-Sleep 30

Set-ADAccountPassword -Identity $username -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)

}
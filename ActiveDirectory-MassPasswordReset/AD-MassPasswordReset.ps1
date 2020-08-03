<#
Authored by
James Krolik

The purpose of this PowerShell script is reset groups of passwords for students and force a password change at next logon.  My school district has three campuses and we set passwords based on the campus accordingly.
#>


Import-Module ActiveDirectory

$WestCampus = "student2019"
$EastCampus = "password2020"
$NorthCampus = "changeme2021"

$securePasswordWest = ConvertTo-SecureString $WestCampus -asplaintext -force
$securePasswordEast = ConvertTo-SecureString $EastCampus -asplaintext -force
$securePasswordNorth = ConvertTo-SecureString $NorthCampus -asplaintext -force

get-aduser -searchbase "OU=West Students,OU=West,DC=MyDomain,DC=local" -filter * | set-adaccountpassword -newpassword $securepasswordWest -reset
get-aduser -searchbase "OU=West Students,OU=West,DC=MyDomain,DC=local" -filter * | set-aduser -changepasswordatlogon:$true

get-aduser -searchbase "OU=East Students,OU=East,DC=MyDomain,DC=local" -filter * | set-adaccountpassword -newpassword $securepasswordEast -reset
get-aduser -searchbase "OU=East Students,OU=East,DC=MyDomain,DC=local" -filter * | set-aduser -changepasswordatlogon:$true

get-aduser -searchbase "OU=North Students,OU=North,DC=MyDomain,DC=local" -filter * | set-adaccountpassword -newpassword $securepasswordNorth -reset
get-aduser -searchbase "OU=North Students,OU=North,DC=MyDomain,DC=local" -filter * | set-aduser -changepasswordatlogon:$true

<#

Authored by
James Krolik



The purpose of this PowerShell script is to clean up any stale machines in Active Directory that are no longer 
being used and move them into an Archived Computers container.  In my experience, a machine that hasn't been signed into
in 52 weeks has most likely either been decomissioned, broken, renamed, or sitting somewhere off network.  Since this disables
the computer and moves it, the next time someone finds it and tries to sign in, they will be notified it is disabled.

1. First we import the framework to work with Active Directory
2. We loop through every computer that matches the parameters of:
   a. Being inactive (not signed into by a user for) 52 weeks
   b. Limit our query to the first 1000 results (for testing purposes)
3. We remove the quotes in the computer name as required for the commands that follow.
4. We disable the computer account.
5. We move the computer to the archived computers OU.

Note: If we wanted to see what the commands would do, we can append a -WhatIf to each of the lines and the script will output
what it would do versus actually executing it.

        Disable-ADAccount $compclean -WhatIf
        Move-ADObject $compclean -Targetpath 'OU=Archived Computers,DC=MyDomain,DC=local' -WhatIf

#>

Import-Module ActiveDirectory

$ADComputers = (dsquery computer -inactive 52 -limit 1000 "OU=SomeComputerOU,dc=MyDomain,dc=local")
foreach ($computer in $ADComputers)
    {
        $compclean=($computer -replace '"', '') #Strip out the quotes
        Disable-ADAccount $compclean            #Disable the computer Account
        Move-ADObject $compclean -Targetpath 'OU=Archived Computers,DC=MyDomain,DC=local'   #Move the computer to the OU
        
        
      
    }

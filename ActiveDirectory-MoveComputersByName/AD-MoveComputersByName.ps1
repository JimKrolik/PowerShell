<#

Authored by
James Krolik

The purpose of this script is to serve two functions:

    1. Move machines joined to the domain out of the default 'Computers' OU and into our production OU.
    2. Move any machines matching a pre-fix to predefined OU's.  In our case, used for computer labs.

Dependencies:

    1. This script requires the Windows Feature Remote Server Administration Tools be enabled to import the ActiveDirectory module.

Information on topology:

    My school district has three campuses and four locations.  North, West, East, and District.  All devices in the district are named with a prefix to
    specify their location (N-, W-, E-, D-) so we can group them to target group policies based on the location and other needs.  From there, we also have 
    labs at the campuses, so we have subsequent policies we deploy such as printers, software through SCCM, etc.  I have this script run as a scheduled task
    with an account with permission to move items in Active Directory so I do not need to run it manually.

    Domain
    |
    +-------Enterprise
            |
            +-----East
            |     |
            |     +-----Labs
            |     |     |    
            |     |     +-----Room 182
            |     |
            |     +-----Carts
            |           |
            |           +-----Cart 1
            |
            +-----West

   Etc.


Overview of process:

    1. Take all computers in 'Computers' OU and move them to the Enterprise OU.
    2. Match for a prefix and move to a location based OU (East, West, North, District)
    3. Match any specifically named devices to where they should go.  I.e. Labs, carts, etc.

#>

Import-Module ActiveDirectory


$ADComputers = (DSQuery Computer 'CN=Computers,DC=mydomain,DC=local' -limit 10000)  #Query the base OU for any objects

ForEach ($Computer in $ADComputers) #Loop through every computer that is in the OU specified above.
    {

    #In order to move an object, the quotes need to be stripped out, so we do so before proceeding.
    #This will move everything from the Computers OU to the Enterprise Computers OU

        $ComputerObjectNoQuotes = ($Computer -replace '"', '') #Remove the quotes from the Object name returned.
        write-host "Moved " $ComputerObjectNoQuotes #Output the fact that the object was moved for visibility if needed.

        Move-ADObject $ComputerObjectNoQuotes -Targetpath 'OU=Enterprise Computers,DC=mydomain,DC=local'

    } 
 
#Completed moving from Base OU to Enterprise OU

$ADComputersToSchool = (DSQuery computer 'OU=Enterprise Computers,DC=mydomain,DC=local' -limit 10000) #Re-run the query to generate a new list against the Enterprise OU.

forEach ($ComputersInEnterprise in $ADComputersToSchool) #for loop to move everything to the correct school.
    {
    
    $ComputerObjectNoQuotesEnterprise=($ComputersInEnterprise -replace '"', '') #Remove the quotes.
    $NamePrefix = $ComputerObjectNoQuotesEnterprise.substring(3,2) #grab character 4 and 5 from DN (always starts with CN=), starts from 0.

        if ($NamePrefix -like "W-") { Move-ADObject $ComputerObjectNoQuotesEnterprise -targetpath "OU=West Computers,OU=Enterprise Computers,DC=mydomain,DC=local"}
    elseif ($NamePrefix -like "N-") { Move-ADObject $ComputerObjectNoQuotesEnterprise -targetpath "OU=North Computers,OU=Enterprise Computers,DC=mydomain,DC=local"}
    elseif ($NamePrefix -like "E-") { Move-ADObject $ComputerObjectNoQuotesEnterprise -targetpath "OU=East Computers,OU=Enterprise Computers,DC=mydomain,DC=local"}
    elseif ($NamePrefix -like "D-") { Move-ADObject $ComputerObjectNoQuotesEnterprise -targetpath "OU=District Computers,OU=Enterprise Computers,DC=mydomain,DC=local"}
    else {
           Write-Host "Unable to find a match for the first two characters of the device." #Passively fail if there isn't a match.
         }

    }

#At this point, all matched devices should be in one of their respective OU's.  So now we can do one final check and move any devices we want automatically moved to a sub-OU.
#We can do the final location based sorting.  Add as many If checks as needed to sort them all.  My district has around 30 labs and 50 carts.

#East
$ADComputersBySchoolLocation = (dsquery computer 'OU=East Computers,OU=Enterprise Computers,DC=mydomain,DC=local' -limit 10000)

ForEach ($ComputerByLocation in $ADComputersBySchoolLocation) {  #Get all computers in the location OU.

            $ComputerObjectNoQuotes = ($ComputerByLocation -replace '"', '') #Remove the quotes from the Object name returned.
            #Now that we have the computer object, we need to get the prefix we are aiming for.  A computer object is returned from the query with CN=E-182... so
            #in my case, I am targeting the fourth through eigth characters to determine where it needs to be.  PowerShell uses zero-based numbering for characters, 
            #so 4-8 becomes 3-7.

            $NameWithPrefix = $ComputerObjectNoQuotes.substring(3,5) #Get the prefix characters (E-182 as an example), starting at the 4th and getting the next five.
            #Now we check and move.

            if ($NameWithPrefix -like "E-182") { Move-ADObject $ComputerObjectNoQuotes -TargetPath "OU=Lab 182,OU=East Labs,OU=East Computers,OU=Enterprise Computers,DC=mydomain,DC=local" }

            #If we need to update our naming prefix for some reason, we can simply change the substring we are pulling.

            $NameWithPrefix = $ComputerObjectNoQuotes.substring(3,8) 
            
            if ($NameWithPrefix -like "E-CART09") { Move-ADObject $ComputerObjectNoQuotes -TargetPath "OU=Cart 9,OU=East Carts,OU=East Computers,OU=Enterprise Computers,DC=mydomain,DC=local" }

}

#West

$ADComputersBySchoolLocation = (dsquery computer 'OU=West Computers,OU=Enterprise Computers,DC=mydomain,DC=local' -limit 10000)

ForEach ($ComputerByLocation in $ADComputersBySchoolLocation) {  #Get all computers in the location OU.

            $ComputerObjectNoQuotes = ($ComputerByLocation -replace '"', '') #Remove the quotes from the Object name returned.
            #Now that we have the computer object, we need to get the prefix we are aiming for.  A computer object is returned from the query with CN=W-D210... so
            #in my case, I am targeting the fourth through eigth characters to determine where it needs to be.  PowerShell uses zero-based numbering for characters, 
            #so 4-8 becomes 3-7.

            $NameWithPrefix = $ComputerObjectNoQuotes.substring(3,6) #Get the prefix characters (E-182 as an example), starting at the 4th and getting the next five.
            #Now we check and move.

            if ($NameWithPrefix -like "W-D210") { Move-ADObject $ComputerObjectNoQuotes -TargetPath "OU=Lab D210,OU=West Labs,OU=West Computers,OU=Enterprise Computers,DC=mydomain,DC=local" }

            #If we need to update our naming prefix for some reason, we can simply change the substring we are pulling.

            $NameWithPrefix = $ComputerObjectNoQuotes.substring(3,8) 
            
            if ($NameWithPrefix -like "W-CART01") { Move-ADObject $ComputerObjectNoQuotes -TargetPath "OU=Cart 1,OU=West Carts,OU=West Computers,OU=Enterprise Computers,DC=mydomain,DC=local" }

}


#North

$ADComputersBySchoolLocation = (dsquery computer 'OU=North Computers,OU=Enterprise Computers,DC=mydomain,DC=local' -limit 10000)

ForEach ($ComputerByLocation in $ADComputersBySchoolLocation) {  #Get all computers in the location OU.

            $ComputerObjectNoQuotes = ($ComputerByLocation -replace '"', '') #Remove the quotes from the Object name returned.
            #Now that we have the computer object, we need to get the prefix we are aiming for.  A computer object is returned from the query with CN=N-LRC... so
            #in my case, I am targeting the fourth through eigth characters to determine where it needs to be.  PowerShell uses zero-based numbering for characters, 
            #so 4-8 becomes 3-7.

            $NameWithPrefix = $ComputerObjectNoQuotes.substring(3,5) #Get the prefix characters (N-LRC as an example), starting at the 4th and getting the next five.
            #Now we check and move.

            if ($NameWithPrefix -like "N-LRC") { Move-ADObject $ComputerObjectNoQuotes -TargetPath "OU=Library,OU=North Labs,OU=North Computers,OU=Enterprise Computers,DC=mydomain,DC=local" }

            #If we need to update our naming prefix for some reason, we can simply change the substring we are pulling.

            $NameWithPrefix = $ComputerObjectNoQuotes.substring(3,8) 
            
            if ($NameWithPrefix -like "N-CART02") { Move-ADObject $ComputerObjectNoQuotes -TargetPath "OU=Cart 2,OU=North Carts,OU=North Computers,OU=Enterprise Computers,DC=mydomain,DC=local" }

}



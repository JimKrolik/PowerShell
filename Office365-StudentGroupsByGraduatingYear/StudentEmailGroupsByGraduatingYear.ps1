<#

Author: James Krolik

Purpose: The purpose of this script is to add students to distribution lists by graduating year.

For example: EastStudents-OYG-2023@MyDomain.org

Dependencies:
    1. This script requires the Windows Feature Remote Server Administration Tools be enabled to import the ActiveDirectory module.
    2. An Active Directory distribution list already be created.
    3. A CSV file with the following headers:

        SchoolID - The school they belong in (we use 1, 2, and 3 to determine which campus a student is in).
        StudentAccount - Their Active Directory account name.
        Enroll_Status - Whether or not the student is actively enrolled.  We use "0" in PowerSchool to signify an actively enrolled student.

#>

Import-Module ActiveDirectory

$file = "C:\Scripts\student_data.csv" #File for reading student data from.
$log = "C:\Scripts\Student Groups by Graduating Year\log.txt" #log file

$date = get-date -format g #Get the current Date/Time

write-host $date | out-file $log

$users = import-csv $file

#The last two digits of the current school year.
$year = 19 #2019-2020 school year

$senior5thYear = $year
$senior = $year + 1
$junior = $year + 2
$sophomore = $year + 3
$freshman = $year + 4

ForEach ($user in $users) { #For each line in the CSV.

 #The syntax for reading the clumn in CSV is the element ($user in this case) with a period and the CSV header name.
 $schoolCode = $user.SchoolID
 $username = $user.StudentAccount
 $studentActive = $user.Enroll_Status

    if ($studentActive -eq "0") { #if the account is active, we can process.

    #1 = East, 2 = West, 3 = North

    $gradYear = $username.substring(3,2)

    <#

    Our student ID's contain their graduating year.  For example, in the 2019 school year, we have a student whose ID would theoretically be PS419123.  With the 19 representing
    the graduation year, so we pull the substring starting at character 3 and grabbing the next two characters.  There isn't any reason the CSV could contain the graduating year,
    but this is how the accounts reside in our Student Information System (PowerSchool), and so I am pulling the data directly from there.

    #>
    
    $ADUserName = get-aduser -identity $username #Query Active Directory for the full username string for adding to the group.

    if ($schoolCode -eq "1") { 
    #East Campus 
    
    if ($gradYear -eq $freshman) { 
            $WestGroup = "WestStudents-OYG-20" + $freshman                                     #Define our three groups
            $EastGroup = "EastStudents-OYG-20" + $freshman
            $NorthGroup = "NorthStudents-OYG-20" + $freshman

            Add-ADGroupMember -identity $EastGroup -members $ADUserName                        #Add to the list for this campus
            Remove-ADGroupMember -identity $WestGroup -members $ADUserName -Confirm:$false     #Remove from the other distribution list if they have transferred.
            Remove-ADGroupMember -identity $Northgroup -members $ADUserName -confirm:$false
            write-host "Added $username to East Freshman $gradYear" | out-file $log            #Write information to the log.
            continue                                                                           #Continue will tell the script to iterate the For loop and move onto the next line.
        }

        if ($gradYear -eq $sophomore) { 
            $WestGroup = "WestStudents-OYG-20" + $sophomore
            $EastGroup = "EastStudents-OYG-20" + $sophomore
            $Northgroup = "NorthStudents-OYG-20" + $sophomore

            Add-ADGroupMember -identity $EastGroup -members $ADUserName
            Remove-ADGroupMember -identity $WestGroup -members $ADUserName -Confirm:$false
            Remove-ADGroupMember -identity $Northgroup -members $ADUserName -confirm:$false
            write-host "Added $username to East Sophomore $gradYear" | out-file $log
            continue
        }

        if ($gradYear -eq $junior) { 
            $WestGroup = "WestStudents-OYG-20" + $junior
            $EastGroup = "EastStudents-OYG-20" + $junior
            $Northgroup = "NorthStudents-OYG-20" + $junior

            Add-ADGroupMember -identity $EastGroup -members $ADUserName
            Remove-ADGroupMember -identity $WestGroup -members $ADUserName -Confirm:$false
            Remove-ADGroupMember -identity $Northgroup -members $ADUserName -confirm:$false
            write-host "Added $username to East Junior $gradYear" | out-file $log
            continue
        }
       
        if ($gradYear -eq $senior) { 
            $WestGroup = "WestStudents-OYG-20" + $senior
            $EastGroup = "EastStudents-OYG-20" + $senior
            $Northgroup = "NorthStudents-OYG-20" + $senior

            Add-ADGroupMember -identity $EastGroup -members $ADUserName
            Remove-ADGroupMember -identity $WestGroup -members $ADUserName -Confirm:$false
            Remove-ADGroupMember -identity $Northgroup -members $ADUserName -confirm:$false
            write-host "Added $username to East Senior $gradYear" | out-file $log
            continue
        }

        if ($gradYear -eq $senior5thYear ) { 
            $WestGroup = "WestStudents-OYG-20" + $senior5thYear 
            $EastGroup = "EastStudents-OYG-20" + $senior5thYear 
            $Northgroup = "NorthStudents-OYG-20" + $senior5thYear 

            Add-ADGroupMember -identity $EastGroup -members $ADUserName
            Remove-ADGroupMember -identity $WestGroup -members $ADUserName -Confirm:$false
            Remove-ADGroupMember -identity $Northgroup -members $ADUserName -confirm:$false
            write-host "Added $username to East Senior $gradYear" | out-file $log
            continue
        }  
    
    
    } #end East Campus

    if ($schoolCode -eq "2") { 
        #West Campus
    
        if ($gradYear -eq $freshman) { 

            $WestGroup = "WestStudents-OYG-20" + $freshman
            $EastGroup = "EastStudents-OYG-20" + $freshman
            $Northgroup = "NorthStudents-OYG-20" + $freshman

            Add-ADGroupMember -identity $WestGroup -members $ADUserName
            Remove-ADGroupMember -identity $EastGroup -members $ADUserName -Confirm:$false
            Remove-ADGroupMember -identity $Northgroup -members $ADUserName -confirm:$false
            write-host "Added $username to West Freshman $gradYear" | out-file $log
            continue
        }

        if ($gradYear -eq $sophomore) { 
            $WestGroup = "WestStudents-OYG-20" + $sophomore
            $EastGroup = "EastStudents-OYG-20" + $sophomore
            $Northgroup = "NorthStudents-OYG-20" + $sophomore

            Add-ADGroupMember -identity $WestGroup -members $ADUserName
            Remove-ADGroupMember -identity $EastGroup -members $ADUserName -Confirm:$false
            Remove-ADGroupMember -identity $Northgroup -members $ADUserName -confirm:$false
            write-host "Added $username to West Sophomore $gradYear" | out-file $log
            continue
        }

        if ($gradYear -eq $junior) { 
            $WestGroup = "WestStudents-OYG-20" + $junior
            $EastGroup = "EastStudents-OYG-20" + $junior
            $Northgroup = "NorthStudents-OYG-20" + $junior

            Add-ADGroupMember -identity $WestGroup -members $ADUserName
            Remove-ADGroupMember -identity $EastGroup -members $ADUserName -Confirm:$false
            Remove-ADGroupMember -identity $Northgroup -members $ADUserName -confirm:$false
            write-host "Added $username to West Junior $gradYear" | out-file $log
            continue
        }
       
        if ($gradYear -eq $senior) { 
            $WestGroup = "WestStudents-OYG-20" + $senior
            $EastGroup = "EastStudents-OYG-20" + $senior
            $Northgroup = "NorthStudents-OYG-20" + $senior

            Add-ADGroupMember -identity $WestGroup -members $ADUserName
            Remove-ADGroupMember -identity $EastGroup -members $ADUserName -Confirm:$false
            Remove-ADGroupMember -identity $Northgroup -members $ADUserName -confirm:$false
            write-host "Added $username to West Senior $gradYear" | out-file $log
            continue
        }

        if ($gradYear -eq $senior5thYear ) { 
            $WestGroup = "WestStudents-OYG-20" + $senior5thYear 
            $EastGroup = "EastStudents-OYG-20" + $senior5thYear 
            $Northgroup = "NorthStudents-OYG-20" + $senior5thYear 

            Add-ADGroupMember -identity $WestGroup -members $ADUserName
            Remove-ADGroupMember -identity $EastGroup -members $ADUserName -Confirm:$false
            Remove-ADGroupMember -identity $Northgroup -members $ADUserName -confirm:$false
            write-host "Added $username to West Senior $gradYear" | out-file $log
            continue
        }  
    
    } #end West Campus

    if ($schoolCode -eq "3") { 
    #North Campus
    
    if ($gradYear -eq $freshman) { 
            $WestGroup = "WestStudents-OYG-20" + $freshman
            $EastGroup = "EastStudents-OYG-20" + $freshman
            $Northgroup = "NorthStudents-OYG-20" + $freshman

            Add-ADGroupMember -identity $Northgroup -members $ADUserName
            Remove-ADGroupMember -identity $EastGroup -members $ADUserName -Confirm:$false
            Remove-ADGroupMember -identity $WestGroup -members $ADUserName -confirm:$false
            write-host "Added $username to North Freshman $gradYear" | out-file $log
            continue
        }

        if ($gradYear -eq $sophomore) { 
            $WestGroup = "WestStudents-OYG-20" + $sophomore
            $EastGroup = "EastStudents-OYG-20" + $sophomore
            $Northgroup = "NorthStudents-OYG-20" + $sophomore

            Add-ADGroupMember -identity $Northgroup -members $ADUserName
            Remove-ADGroupMember -identity $EastGroup -members $ADUserName -Confirm:$false
            Remove-ADGroupMember -identity $WestGroup -members $ADUserName -confirm:$false
            write-host "Added $username to North Sophomore $gradYear" | out-file $log
            continue
        }

        if ($gradYear -eq $junior) { 
            $WestGroup = "WestStudents-OYG-20" + $junior
            $EastGroup = "EastStudents-OYG-20" + $junior
            $Northgroup = "NorthStudents-OYG-20" + $junior

            Add-ADGroupMember -identity $Northgroup -members $ADUserName
            Remove-ADGroupMember -identity $EastGroup -members $ADUserName -Confirm:$false
            Remove-ADGroupMember -identity $WestGroup -members $ADUserName -confirm:$false
            write-host "Added $username to North Junior $gradYear" | out-file $log
            continue
        }
       
        if ($gradYear -eq $senior) { 
            $WestGroup = "WestStudents-OYG-20" + $senior
            $EastGroup = "EastStudents-OYG-20" + $senior
            $Northgroup = "NorthStudents-OYG-20" + $senior

            Add-ADGroupMember -identity $Northgroup -members $ADUserName
            Remove-ADGroupMember -identity $EastGroup -members $ADUserName -Confirm:$false
            Remove-ADGroupMember -identity $WestGroup -members $ADUserName -confirm:$false
            write-host "Added $username to North Senior $gradYear" | out-file $log
            continue
        }

        if ($gradYear -eq $senior5thYear ) { 
            $WestGroup = "WestStudents-OYG-20" + $senior5thYear 
            $EastGroup = "EastStudents-OYG-20" + $senior5thYear 
            $Northgroup = "NorthStudents-OYG-20" + $senior5thYear 

            Add-ADGroupMember -identity $Northgroup -members $ADUserName
            Remove-ADGroupMember -identity $EastGroup -members $ADUserName -Confirm:$false
            Remove-ADGroupMember -identity $WestGroup -members $ADUserName -confirm:$false
            write-host "Added $username to North Senior $gradYear" | out-file $log
            continue
        }  
    
    
    } #end North Campus


    } #end Actively Enrolled Check


} #end ForEach Loop

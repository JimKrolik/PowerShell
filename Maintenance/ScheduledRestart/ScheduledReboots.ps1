<#

Authored by:
James Krolik

The purpose of this script is to determine if a server has a pending restart and schedule a restart based on a CSV.  It is designed to be run as part of an automatic script.
This script is adapted from a self-healing script I have running in my environment to check if servers need a restart, are powered on, have low disk space, etc.
The source could be readily be adapted to pull from a SQL database or some other place containing the required information instead of a CSV.
If a reboot is pending and tomorrow is the scheduled reboot day, the script will schedule a reboot at midnight.

Pre-Requisites:
    
    This script required the Test-PendingReboot module be installed prior.  This was tested with version 1.10.
    Install-Script -Name Test-PendingReboot
    Website: https://www.powershellgallery.com/packages/Test-PendingReboot/

Requirements:  

    This script requires remote administrator rights to the targeted machines.

#>

<#
$PSScriptRoot refers to the directory the script was run from.  
You can also use the full path to the file.  Example:  C:\SomeDirectory\Test.csv
#>

$File = $PSScriptRoot + "\ServerRebootSchedule.csv"  #Path to CSV. 

<#######################################

            Function Definitions

#######################################>


function isRebootPending() {

#This function will query the device and return if a reboot is pending via True or False.

Param([String]$HostName)

    $pending = Test-PendingReboot -ComputerName $HostName

    return $pending.isRebootPending

}


<##################

    Begin Program 

 ##################>


#If the file doesn't exist, exit.
$checkFile = test-path $File
if ($checkfile -eq $false) { #If the file doesn't exist, obviously there won't be any work to do and we must abort.

write-host $File "does not exist.  Unable to continue.  Exiting."

$File + " does not exist.  Unable to continue.  Exiting." | out-file 'Error.txt' -append
exit
}

$ServersCSV = import-csv $File


ForEach ($Server in $ServersCSV) #loop through each and every line
        {

        $hostname = $Server.Hostname     #Read the 'Hostname' field from the CSV
        $IPAddress = $Server.IPAddress   #Read the 'IPAddress' field from the CSV
        $RebootDay = $Server.RebootDay   #Read the 'RebootDay' field from the CSV.  
                                         #Days are 0 Sunday, 1 Monday, ... 6 Saturday

        $pending = isRebootPending -HostName $HostName

        if ($pending -eq $true) { 
        
            write-warning -Message "There is a reboot pending."

            #Get day of week
            [int]$DayOfWeek = get-date | Select-Object -ExpandProperty DayOfWeek

            #Schedule reboot if tomorrow is the scheduled reboot day.
            #0 - Sunday, 1 - Monday ... 6 - Saturday
            #If the CSV field is empty, no reboot will be scheduled.
            
            if ($RebootDay -eq $true) {

            write-host "Reboot day was specified, checking to see if reboot is scheduled."
            
            if ([int]$RebootDay -lt 0 -or [int]$RebootDay -gt 6) { 
            
                Write-warning "Warning: Invalid reboot day specified, skipping..."
                continue
            
            }


                    if ([int]$dayOfWeek -eq ([int]$RebootDay - 1)) {
                    #Schedule Reboot for midnight
                    write-host "Reboot scheduled."

                    $MidnightTomorrow = (get-date -year (get-date).year -month (get-date).month -day ((get-date).day + 1) -hour 0 -minute 0 -second 0)  #Calculate time until midnight.
                    $now = get-date #Get today.
                    $seconds = ($MidnightTomorrow - $now).TotalSeconds #Calculate the seconds from now until midnight since the shutdown command accepts seconds by default.

                            shutdown.exe -m \\$hostname -r -t $seconds -c "Managed restart for midnight." 2>$null
                
                            if ($LASTEXITCODE -eq 1190) {  #Code 1190 indicates a reboot is already pending.
                                write-Warning "A reboot has already been scheduled."
                            }


             } #End check if tomorrow is reboot day.



        } #End if RebootDay check.

    }  #End if Pending check.

}  #End ForEach Statement


  
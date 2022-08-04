 <#	
	.NOTES
	===========================================================================
        Created by:    James Krolik
	Created on:   	06/01/2021
	Updated on:	08/04/2022
	Filename:     	WorkstationCleanup.ps1
	===========================================================================
	.DESCRIPTION
	This script is designed to be run against machines that are in a low disk space state and will perform the following:

        Delete user profiles older than 30 days
        Clean all remaining user profile temp files
        Clean up the main Windows temp folders

        If Deep Clean is specified:
        Clean up the Windows installer cache
        Clean up the Windows update cache


    .USAGE
        WorkstationCleanup.ps1 
        WorkstationCleanup.ps1 -deepClean $true

    .DEPENDENCIES
        The delprof2.exe utility must be present in the same folder the script is run from.  
        https://helgeklein.com/free-tools/delprof2-user-profile-deletion-tool/
	
    .CHANGE LOG
        Added functions for: 
	   Deleting old files in a directory
           Finding zip files (or other extensions) in a folder, looking for a matching folder, and then purging the zip file.
#>

<#################
# Function Block #
#################>
function deleteOldFiles() {
<#
This function accepts a date, an extension and a path to purge any files nested within older 
than x days (defaulted to 30) and also accepts a recursive flag.
#>
    Param (         
        [Parameter(Mandatory=$false)]
        [String]$days = 30,
        [Parameter(Mandatory=$true)]
        [String]$filePath,
        [Parameter(Mandatory=$true)]
        [String]$extension,
        [Parameter(Mandatory=$false)]
        [Bool]$recursive = $false
        )

        $filesToRemove = Get-ChildItem -Path "$filePath" | where {$_.LastWriteTime -lt (Get-Date).AddDays(-30) } | where {$_.Extension -eq $extension } 

        forEach($file in $filesToRemove) {
            Remove-Item $file.fullname -Force
        }
}

function checkForMatchingZip() {
<#
This function will look for all files with a .zip (by default) extension and check for a 
matching folder name within the same folder.
#>
    Param (         
        [Parameter(Mandatory=$true)]
        [String]$filePath,
        [Parameter(Mandatory=$false)]
        [String]$extension=".zip",
        [Parameter(Mandatory=$false)]
        [Bool]$recursive = $false
        )

        $filesToRemove = Get-ChildItem -Path "$filePath" -Recurse $recursive | where {$_.Extension -eq $extension } 
        $lengthOfExtension = $extension.Length

        #For each file with the extension
        forEach($file in $filesToRemove) {
            #Mathemetically calculate the length of the folder minus the extension.
            $lengthOfFile = $file.FullName.Length
            $lengthOfFolder = $lengthOfFile - $lengthOfExtension

            #Build our folder path
            $folderToCheck = $file.fullName.Substring(0, $lengthOfFolder)

            #If the folder exists, remove the zip.
            if (Test-Path -Path $folderToCheck) {
                Remove-Item -Path $file.fullname -Force -Verbose
            }
            else {
                #Leaving this here in case we want to add functionality later.
            }
        }
}

<################
 Parameter Block
################>

Param(

    [Parameter(Mandatory=$false)]
    [Bool]$deepClean=$false

)


<##########################
 Delete old user Profiles
##########################>

#If delprof2.exe is present in the script directory, run it, otherwise, skip it to avoid generating an error.
if (Test-Path -path $PSScriptRoot+"\delprof2.exe") {
    $PSScriptRoot+"\delprof2.exe /d:30 /ed:default /ed:public /q /i /u"
}

<#########################
 Clean Users Temp Folders
#########################>

$users = Get-ChildItem -Path "C:\Users"

$users | ForEach-Object {

    $path = "C:\Users\$($_.Name)\AppData\Local\Temp"
    Remove-Item "$path\*" -Recurse -Force
    
    #Downloads folders
    $downloadsPath = "C:\Users\$($_.Name)\Downloads"
	
<#################
 Delete old files
#################>

#Delete files older than 30 days.
deleteOldFiles -filePath "$downloadsPath" -days 30 -extension ".exe" -recursive $false
deleteOldFiles -filePath "$downloadsPath" -days 30 -extension ".msi" -recursive $false

#Delete zip files that have a matching folder
checkForMatchingZip -filePath "$downloadsPath" -extension ".zip" -recursive $true

}

<###########################
 Clean Windows Temp Folders
###########################>

Remove-Item "C:\Temp\*" -Recurse -Force
Remove-Item "C:\Windows\Temp\*" -Recurse -Force

<#####################
 Windows Update Cache
######################>

#Stop Windows Update service
Stop-Service "wuauserv"
Start-Sleep -Seconds 2

#Clean
Remove-Item "C:\Windows\SoftwareDistribution\*" -Recurse -Force

if (Test-Path -path "C:\WINDOWS.old") { Remove-Item "C:\WINDOWS.old" -Recurse -Force }
if (Test-Path -path "C:\Windows10Upgrade") { Remove-Item "C:\Windows10Upgrade" -Recurse -Force }
#I use single quotes and literalpath here so the $ isn't interpreted.
if (Test-Path -LiteralPath "C:\$WINDOWS.~BT") { Remove-Item 'C:\$WINDOWS.~BT' -Recurse -Force }
if (Test-Path -LiteralPath "C:\$Windows.~WS") { Remove-Item 'C:\$Windows.~WS' -Recurse -Force }

Start-Sleep -Seconds 2
Start-Service "wuauserv"


if ($deepClean -eq $true) {
#Purge all orphaned files in the installer cache.

$InstallerPath = "C:\Windows\Installer"

$RegPaths = @(
	"HKLM:\Software\Microsoft\Windows\CurrentVersion\Installer\UserData\*\Products\*\InstallProperties",
	"HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Installer\UserData\*\Products\*\InstallProperties"
)

$ProdProp = @{ 
	Path = $RegPaths
	Name = @('DisplayName','LocalPackage')
	ErrorAction = "SilentlyContinue"
}
					
$Product = Get-ItemProperty @ProdProp
$MSIFiles = Get-ChildItem -Path $InstallerPath -Filter "*.msi"

$MSIFiles | where { 
    -not($Product.LocalPackage -contains $_.FullName)
     } | Remove-Item -Force


#Reset the base for Windows to seal any Windows Updates into the current version and remove the old files.
Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase


}

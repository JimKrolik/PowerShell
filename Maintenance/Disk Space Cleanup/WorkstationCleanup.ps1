<#
 <#	
	.NOTES
	===========================================================================
     Created by:    James Krolik
	 Created on:   	06/01/2021
	 Updated on:	06/01/2021
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
        
#>

<################
 Parameter Block
################>

Param(

    [Parameter(Mandatory=$true)]
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

if (Test-Path -path "C:\$WINDOWS.~BT") { Remove-Item "C:\$WINDOWS.~BT" -Recurse -Force }
if (Test-Path -path "C:\WINDOWS.old") { Remove-Item "C:\$WINDOWS.~BT" -Recurse -Force }
if (Test-Path -path "C:\Windows10Upgrade") { Remove-Item "C:\$WINDOWS.~BT" -Recurse -Force }

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
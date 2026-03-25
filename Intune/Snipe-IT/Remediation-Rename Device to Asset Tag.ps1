<#
Authored by:
James Krolik

This script is designed to run as a compliance policy inside of Intune and works in tandem with the detection script.
It uses Snipe-IT as the asset source and anchors against the serial number.
#>

$baseURL = ''    #The base URL to your instance.
$targetURL = $baseURL + "/api/v1"

$apiToken = ''   #Insert your API token here.
$logPath = "C:\OOBE Flags"
$logFile = "$logPath" + "\deviceName.txt" #If you want logging, update this file.


function getDevice() {
    Param (         
        [Parameter(Mandatory=$true)]
        [String]$serialNumber
        )

    $Params = @{
        "URI" = "$url/hardware/byserial/$serialNumber"
        "Method" = 'GET'
    }

    $headers = @{
        "Accept" = "application/json"
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $token"
    }

    $getDevice = Invoke-RestMethod @Params -headers $headers
    return $getDevice
}

$serialNumber = (GWMI -Class Win32_Bios | select SerialNumber).serialNumber
$response = getDevice -serialNumber $serialNumber

$fileExists = Test-Path $logPath
if (!$fileExists) { #Create the folder if it doesn't exist.
  New-Item -Path $logPath -ItemType Directory
}
write-output "Target asset tag:" | out-file $logFile -append
write-output "$response.rows.asset_tag" | out-file $logFile -append
write-output " " | out-file $logFile -append
write-output "Response:" | out-file $logFile -append
write-output "$response" | out-file $logFile -append

Rename-Computer -NewName "$response.rows.asset_tag" -WhatIf   #Remove the -WhatIf to put into production.  You can also add a forced restart if needed.

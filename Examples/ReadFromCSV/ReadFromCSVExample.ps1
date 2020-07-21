<#

Authored by
James Krolik

The purpose of this script is an example of reading headers data line by line from a CSV.

Requirements:
    
       This simply requires a flat CSV file with as many headers as needed.
       In the example below, I have a flat CSV with two headers: Serial, Name

#>

<#
$PSScriptRoot refers to the directory the script was run from.  
You can also use the full path to the file.  Example:  C:\SomeDirectory\Test.csv
#>

$File = $PSScriptRoot + "\Test.csv"  #Path to CSV.  

$CheckFileExists = Test-path $File   #Variable for checking if the file exists.

If ($CheckFileExists -eq $False) { #If the file doesn't exist, there is nothing to do, so we can exit.

    Write-Host $File "does not exist.  Unable to continue.  Exiting."

    #If you want to log the error to a file named Error.txt in the same directory as the script, uncomment below.
    #$File + " does not exist.  Unable to continue.  Exiting." | out-file 'Error.txt' -append
    Exit
}


$dataInFile = Import-CSV $File
ForEach ($dataFromCSV in $dataInFile) {

$SerialFromCSV = $dataFromCSV.serial
$NameFromCSV = $dataFromCSV.name

<#
Now that we have the data, you can do with it what you will.  Since this is an example, I am echoing the data to the console.
In my production environment, I use this for serial number to PC naming in my SCCM imaging workflow.

#>

Write-Host $SerialFromCSV
Write-Host $NameFromCSV


}


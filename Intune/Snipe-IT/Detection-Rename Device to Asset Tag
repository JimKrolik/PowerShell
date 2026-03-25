<#
Authored by:
James Krolik

This script is designed to run as a compliance policy inside of Intune and works in tandem with the remediation script.
This detects whether or not the name conforms to your naming standard and returns a 0 (matches) or 1 (does not match) to Intune.
#>

# Get the device name
$DeviceName = $env:COMPUTERNAME

# Define regex pattern: CORP- followed by exactly 6 digits.  Update your detection logic accordingly.
$Pattern = '^CORP-\d{6}$'

# Check if the device name matches the pattern
if ($DeviceName -match $Pattern) {
    exit 0
} else {
    exit 1
}

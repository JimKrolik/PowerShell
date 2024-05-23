<#	
	.NOTES
	===========================================================================
	 Created on:   	05/22/2024
	 Updated on:    05/22/2024
	 Created by:   	James Krolik
	===========================================================================
	.DESCRIPTION
		This script is designed to delete devices out of ScreenConnect.
#>

$baseURL = ""
$loginURL = $baseURL + "/login"

#Credentials to the website.
$username = ""
$password = ""

#The session ID of the device to delete.
$sessionID = ""

#Query the main website to establish a session token.
$webrequest = Invoke-WebRequest -uri $loginURL
$response = $webrequest.RawContent

# Regular expression pattern to extract text between"antiForgeryToken":" and ",
$pattern = '"antiForgeryToken":"([^"]+)"'

# Perform the regex match
if ($response -match $pattern) {
    # Extracted text
   $antiForgeryToken = $matches[1]
   
} else {
    $antiForgeryToken = "blank"
}

#Update the login URL
$loginURL = $baseURL + "/Services/AuthenticationService.ashx/TryLogin"

$headers = @{
    "Content-Type" = "application/json"
    "Origin" = "$baseURL"
    "X-Anti-Forgery-Token" = $antiForgeryToken
    }
    $Params = @{
        "URI" = "$loginURL"
        "Method" = 'POST'
    }

$body = '["' + $username + '","' + $password + '",null,null,null]'

#Authenticate to the website and establish the session.
$response = invoke-webrequest @Params -Body $body -Headers $headers -SessionVariable screenConnectSession

#Retrieve the cookie from the authentication response
$cookie = $response.headers.'Set-Cookie'

$sessionsURL = $baseURL + "/Services/PageService.ashx/AddSessionEvents"

$headers = @{
    "Content-Type" = "application/json"
    "X-Anti-Forgery-Token" = "$antiForgeryToken"
    "Cookie" = "$cookie"
    }
    $Params = @{
        "URI" = "$sessionsURL"
        "Method" = 'POST'
    }

#EventType 21 is 'Delete'
#EventType 100 is 'Uninstall and Delete'
#EventType 41 is 'Uninstall'

$body = '[["Workstations"],[{"SessionID":"' + $sessionID + '","EventType":21}]]'

#POST to process the deletion
$response = invoke-webrequest @Params -Body $body -Headers $headers -WebSession $screenConnectSession

#Expected response code should be 200 with a description of OK

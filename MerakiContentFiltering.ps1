# For access to the API, first enable the API for your organization under Organization > Settings > Dashboard API access. Then generate API key under your profile. 
$APIKey = "Put your API key here"

# Since we send the headers which include the API key with every call we put it in a variable for convenience. 
$headers = @{
    "Content-Type" = "application/json"
    "X-Cisco-Meraki-API-Key" = $APIKey
}

# Get the unique ID from your organization (the script assumes only one ID) 
$Organization = Invoke-RestMethod -Method Get -Uri "https://api.meraki.com/api/v1/organizations/" -Headers $Headers
$OrgId = $Organization.id 

# Get all networks within your organization. 
$Networks = Invoke-RestMethod -Method Get -Uri "https://api.meraki.com/api/v1/organizations/$OrgId/networks" -Headers $Headers

# capturing and listing the networks bij name and id. I suggest you capture every network in a variable that makes sense to you. The script just akwardly assigns general names/numbers to each network.
$temp = 0
foreach ($network in $networks) {
New-Variable -Name ("network"+"$temp") -Value $network.id 
Get-Variable -Name ("network"+"$temp")
$temp++
}


# Retrieve the Content filter fro a network (in a Powershell object/array) which includes Category blocking, URL filtering (block and allow) and Search filtering.
$ContentFilter = Invoke-RestMethod -Method Get -Uri "https://api.meraki.com/api/v1/networks/$network0/appliance/contentFiltering" -Headers $Headers

# you can view appropiate items, the script focuses on adding an allowed URL. 
$ContentFilter | Format-List    
$ContentFilter.urlCategoryListSize 
$ContentFilter.blockedUrlCategories
$ContentFilter.blockedUrlPatterns
$ContentFilter.allowedUrlPatterns

# Add an allowed URL 
$ContentFilter.allowedUrlPatterns += "Put name here" # System.Array within Powershell is a collection of fixed size so += creates a new array with the added value.

# Since you can only upload the category ID and with the added description you get an error essage when uploading we replace the blocked categories with only the id instead of id and description.
$ContentFilter.blockedUrlCategories = $ContentFilter.blockedUrlCategories.id

$jsonPayload = ($ContentFilter | ConvertTo-Json)

# Test on one location/network
Invoke-RestMethod -Method Put -Uri "https://n170.meraki.com/api/v1/networks/$network0/appliance/contentFiltering" -Headers $Headers -Body $jsonPayload

#All locations
foreach ($network in $networks) {
$temp2 = $network.id
Invoke-RestMethod -Method Put -Uri "https://n170.meraki.com/api/v1/networks/$temp2/appliance/contentFiltering" -Headers $Headers -Body $jsonPayload
}

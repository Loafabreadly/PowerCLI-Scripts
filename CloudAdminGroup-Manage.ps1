# Version 1.0
# Developed by Brad Snurka <bsnurka@vmware.com>
# USAGE: Run Powershell script, select the option you want from the given list
# RESULT: Provides the current users in CloudAdminGroup, and allows for ADD/REMOVE operations to the CloudAdminGroup

clear
# Define the vCenter server URL
$vCenterServer = Read-Host -Prompt "Please input the VC URL (EX: vcenter.sddc-xx-xxx-xxx-xxx.vmwarevmc.com)"
$pass = Read-Host -Prompt "Enter the Cloudadmin@vmc.local password"


clear

$server = Connect-VIServer -Server $server -User cloudadmin@vmc.local -Password $pass
Write-Host Connected to the vCenter Server successfully.`n

# Define the vCenter token
$vCenterToken = $server.GetCisSessionId()


# Function to GET current administrators
function GetAdministrators {
    $apiEndpoint = "/api/hvc/management/administrators"
    $apiUrl = "https://" + $vCenterServer + $apiEndpoint
    $headers = @{
        'vmware-api-session-id' = $vCenterToken
    }
    $administrators = Invoke-RestMethod -Uri $apiUrl -Headers $headers
    return $administrators
}

# Function to ADD or REMOVE a group
function ModifyAdministratorsGroup {
    param (
        [string] $group,
        [string] $action
    )
    $apiEndpoint = "/api/hvc/management/administrators?action=$action"
    $apiUrl = "https://" + $vCenterServer + $apiEndpoint
    $headers = @{
        'vmware-api-session-id' = $vCenterToken
        'Content-Type' = 'application/json'
    }
    $requestBody = @{
        "group_name" = $group
    }
    $requestBodyJson = $requestBody | ConvertTo-Json -Depth 1 -Compress
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $requestBodyJson
        Write-Host "Group '$group' $action from CloudAdminGroup group for $vcenterServer HVC."
    } catch {
        Write-Host "Error $action group: $($_.Exception.Message)"
        Write-Host I tried to make a call to: $apiUrl
        Write-Host The request body was:`n$requestBodyJson
    }
}

#Loop Control Bool
$exitRequested = $false

# Loop to perform multiple ADD or REMOVE operations
while (-not $exitRequested) {
    Write-Host "Options:"
    Write-Host "1. GET - Get current administrators"
    Write-Host "2. ADD - Add a group to administrators"
    Write-Host "3. REMOVE - Remove a group from administrators"
    Write-Host "4. EXIT - Exit the script"

    $choice = Read-Host "Enter your choice ('GET', 'ADD', 'REMOVE', 'EXIT')"

    switch ($choice) {
        "GET" {
            $administrators = GetAdministrators
            Write-Host "`nCurrent Administrators:"
            $administrators | ForEach-Object { Write-Host $_ }
            Write-Host
            Read-Host "Press ENTER to continue"
        }
        "ADD" {
            $group = Read-Host "`nEnter the group name to add"
            ModifyAdministratorsGroup $group "add"
            Write-Host
            Read-Host "Press ENTER to continue"
        }
        "REMOVE" {
            $group = Read-Host "`nEnter the group name to remove"
            ModifyAdministratorsGroup $group "remove"
            Write-Host
            Read-Host "Press ENTER to continue"
        }
        "EXIT" {
            $exitRequested = $true
        }
        default {
            Write-Host "`nInvalid choice. Please select from the available options."
        }
    }
    clear
}
Disconnect-VIServer -Confirm:$false
Write-Host `nCleaned up vCenter Server Connection.
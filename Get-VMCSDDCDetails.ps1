# Version 1.2
# Developed by Brad Snurka <bsnurka@vmware.com>
# USAGE: Run Powershell script, provide CSP API Token
# RESULT: Outputs Name, SDDC ID, & region for all SDDCs in the ORG


clear
$apiToken = Read-Host -Prompt "Enter your CSP API Token which has permissions to the VMC Application"

# Connect to VMware Cloud on AWS
$server = Connect-Vmc -ApiToken $apiToken
Write-Host Successfully connected to VMC with $server.User 
Write-Host `Organization ID: $server.OrganizationId
Write-Host Linked AWS Account Number for ORG: $(Get-AwsAccount -Server $server).AccountNumber

# Get the list of all SDDCs for the specified organization where the SDDCs are in a READY state
$sddcs = Get-VmcSddc | Where-Object { $_.DeploymentState -eq "READY" }
$sddcTotal = $sddcs.Count
Write-Host `nTotal SDDC Count $sddcTotal
$sddcCounter = 0
$totalClusterCounter = 0
$totalHostCounter = 0

# Iterate through the SDDCs
foreach ($sddc in $sddcs) {
    $sddcCounter++
    Write-Host `n-------------------------------
    Write-Host SDDC Number $counter out of $sddcTotal
    Write-Host SDDC Name: $sddc.Name - Deployed by: $sddc.CreatedByUser on $sddc.CreatedTime 
    Write-Host SDDC ID: $sddc.Id - $sddc.Region 
    Write-Host SDDC Type: $sddc.SddcType - SDDC Group Connection: $sddc.SddcGroupMemberConnectivityStatus 
    Write-Host SDDC Version: $sddc.Version 
    Write-Host Host Count: $sddc.HostCount
    Write-Host AWS Account Link State: $sddc.AccountLinkState
    Write-Host Cloud FQDN: $sddc.VCenterUrl 
    Write-Host NSX API Endpoint: $sddc.NsxApiPublicEndpointUrl
    $totalClusterCounter = $totalClusterCounter + $(Get-VmcSddcCluster -Sddc $sddc).Count
    $totalHostCounter = $totalHostCounter + $sddc.HostCount
}

Write-Host -------------------------------

# Disconnect from VMware Cloud on AWS
Disconnect-Vmc -Confirm:$false
Write-Host Successfully cleaned up the VMC PowerCLI Connection.

Write-Host Overall ORG View - Total SDDCs: $sddcTotal
Write-host Total Clusters across all SDDCs: $totalClusterCounter - Total Hosts across all SDDCs: $totalHostCounter
# Version 1.1
# Developed by Brad Snurka <bsnurka@vmware.com>
# USAGE: Run Powershell script, provide CSP API Token, SDDC name
# RESULT: Outputs Name, SDDC ID, & region for selected SDDC


clear
$apiToken = Read-Host -Prompt "Enter your CSP API Token"
$name = Read-Host -Prompt "Enter the SDDC Name"
$server = Connect-Vmc -ApiToken $apiToken
$awsAcc = Get-AwsAccount -Server $server
$vmcSDDC = Get-VmcSddc -Name $name
Write-Host `nSuccessfully connected with $server.User  defaulting to AWS Acc Number: $awsAcc.AccountNumber
Write-Host `nSDDC Name: $vmcSDDC.Name `nSDDC ID: $vmcSDDC.Id `nRegion: $vmcSDDC.Region
Write-Host Cloud FQDN: $vmcSDDC.VCenterUrl `nSDDC Version: $vmcSDDC.Version `nHost Count: $vmcSDDC.HostCount
Write-Host State: $vmcSDDC.AccessState
Disconnect-Vmc -Confirm:$false
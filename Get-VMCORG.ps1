$apiToken = Read-Host -Prompt 'Enter you CSP API Token'
$server = Connect-Vmc -ApiToken $apiToken
$awsAcc = Get-AwsAccount -Server $server
$vmcDX = Get-VmcSddc -Name 'CSE-DX'
Write-Host ''
Write-Host Successfully connected with $server.User  defaulting to ORG ID  $awsAcc
Write-Host ''
Write-Host $vmcDX.Id / $vmcDX.Name - $vmcDX.Region
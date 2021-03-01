# Version 1.0
# Developed by Brad Snurka <bsnurka@vmware.com>
# USAGE: Run Powershell script, provide vCenter FQDN, CloudAdmin Credentials, Source VM name
# RESULT: Outputs Name, PowerState, CPU, Memory in GB, and VM Folder

Clear-Host
$server = Read-Host -Prompt "Please input the VC URL (EX: vcenter.sddc-xx-xxx-xxx-xxx.vmwarevmc.com)"
$pass = Read-Host -Prompt "Please input the cloudadmin@vmc.local password"
$source = Read-Host -Prompt "What is the Source VM you want to retrieve details about"

Write-Host `nConnecting to SDDC...`n

Connect-VIServer -Server $server -User cloudadmin@vmc.local -Password $pass

Write-Host `nConnected! Retrieving VM list now...`nThis may take a while

$vm = Get-VM| where {$_.Name -match $source}

if ($vm.CreateDate -ne $null) {
    Write-host `nSuccessfully found the VM!
    $vm | Select Name, PowerState, NumCpu, MemoryGB, Folder
}
else {
    Write-Host `nFailed to find the VM :/
}

Disconnect-VIServer -Confirm:$false


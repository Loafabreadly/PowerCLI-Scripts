# Version 1.2
# Developed by Brad Snurka <bsnurka@vmware.com>
# USAGE: Run Powershell script, provide vCenter FQDN, CloudAdmin Credentials, Source & Target Network

Clear-Host
$server = Read-Host -Prompt "Please input the VC URL (EX: vcenter.sddc-xx-xxx-xxx-xxx.vmwarevmc.com)"
$pass = Read-Host -Prompt "Please input the cloudadmin@vmc.local password"
$source = Read-Host -Prompt "What is the Source Network name (Case sensistive) you wish to vacate?"
$target = Read-Host -Prompt "What is the Target Network name (Case sensistive) you wish to attach?"

Write-Host `nConnecting to SDDC...`n

Connect-VIServer -Server $server -User cloudadmin@vmc.local -Password $pass

Write-Host `nConnected! Retrieving VM list now...

$list = Get-VM | Where-Object { ($PSItem | Get-NetworkAdapter | where {$_.networkname -match $source})}

Write-Host "`nHere are all the VMs I found attached to [$source]`n"

$list | Select Name, PowerState

foreach ($vm in $list) {
   $confirm = Read-Host -Prompt "Do you want to change [$vm]'s Network Adapter? (y/n)"
   if ($confirm -eq "y") {
    $vm | Get-NetworkAdapter | Set-NetworkAdapter -Confirm:$false -NetworkName $target
    write-Host "I  have switched [$vm] from network [$source] to network [$target]"
   }
   else {
    Write-Host "`nSkipped [$vm]"
    continue
   }
}

Write-Host "`nThat's all of them! Disconnecting from VC!"
Disconnect-VIServer -Confirm:$false
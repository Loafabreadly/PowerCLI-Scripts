# Version 1.3
# Developed by Brad Snurka <bsnurka@vmware.com>
# USAGE: Run Powershell script, provide vCenter FQDN, CloudAdmin Credentials, Source & Target Network

Clear-Host
$server = Read-Host -Prompt "Please input the VC URL (EX: vcenter.sddc-xx-xxx-xxx-xxx.vmwarevmc.com)"
$pass = Read-Host -Prompt "Please input the cloudadmin@vmc.local password"
$source = Read-Host -Prompt "What is the Source Network name (Case sensistive) you wish to vacate?"
$target = Read-Host -Prompt "What is the Target Network name (Case sensistive) you wish to attach?"


Write-Host `nConnecting to SDDC...`n

Connect-VIServer -Server $server -User cloudadmin@vmc.local -Password $pass

Write-Host `nConnected! Retrieving VM list now...`nThis may take a while

$list = Get-VM | Where-Object { ($PSItem | Get-NetworkAdapter | where {$_.networkname -match $source})}
$total = $list.Count

$list | Select Name, PowerState, NumCpu, MemoryMB
Write-Host "`nI have found a total of $total VMs attached to [$source]`n"

$mass = Read-Host -Prompt "`nDo you want to mass accept these changes? (y/n)"

if ($mass -eq "y") {
    foreach ($vm in $list) {
        $current = $list.IndexOf($vm)
        $current++
        write-Host "($current/$total) Switching [$vm] from network [$source] to network [$target]`n"
        $vm | Get-NetworkAdapter | Set-NetworkAdapter -Confirm:$false -NetworkName $target | Select Parent, Name, NetworkName, ConnectionState   
    }
}
else {
    foreach ($vm in $list) {
    $current = $list.IndexOf($vm)
    $current++
       $confirm = Read-Host -Prompt "($current/$total) Do you want to change [$vm]'s Network Adapter to the $target network? (y/n)"
       if ($confirm -eq "y") {
           write-Host "($current/$total) Switching [$vm] from network [$source] to network [$target]"
           $vm | Get-NetworkAdapter | Set-NetworkAdapter -Confirm:$false -NetworkName $target | Select Parent, Name, NetworkName, ConnectionState            
       }
       else {
           Write-Host "`nSkipped [$vm]`n"
           continue
       }
    }
}

Write-Host "`nThat's all of them! Disconnecting from VC!"
Disconnect-VIServer -Confirm:$false
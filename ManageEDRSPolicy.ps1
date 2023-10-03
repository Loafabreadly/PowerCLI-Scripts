# Version 1.0
# Developed by Brad Snurka <bsnurka@vmware.com>
# USAGE: Run Powershell script, provide CSP API Token, pick an SDDC ID from the list displayed
# RESULT: Allows end-user to View and optionally modify the EDRS policy for a given SDDC.

clear
$apiToken = Read-Host -Prompt "Enter your CSP API Token which has permissions to the VMC Application"

# Connect to VMware Cloud on AWS
$server = Connect-Vmc -ApiToken $apiToken
Write-Host Successfully connected to VMC with $server.User 
Write-Host `Organization ID: $server.OrganizationId

$sddcs = Get-VmcSddc | Where-Object { $_.DeploymentState -eq "READY" }
foreach ($sddc in $sddcs) {
    Write-Host SDDC Name: $sddc.Name - ID: $sddc.Id
}

Write-Host

$sddc = Get-VmcSddc -Id $(Read-Host -Prompt "Enter your SDDC ID")
$clusters = Get-VmcSddcCluster -Sddc $sddc

foreach ($cluster in $clusters) {

    Write-Host Current EDRS Policy for $cluster.Name / $Cluster.Id is $(Get-VmcClusterEdrsPolicy -Cluster $cluster)
    $answer = Read-Host -Prompt "Do you want to change this Clusters policy? (y/n)"
    if ($answer -eq "y") {
        Write-Host "Which EDRS Policy do you want to change to? (https://via.vmw.com/bXhzHP for more details)"
        $policyAnswer = Read-Host -Prompt "EDRS Policy Selection (baseline, performance, cost, rapid-scale)"
        switch -wildcard ($policyAnswer) {
            "baseline" {
                $minHost = Read-Host -Prompt "What is the minimum number of hosts you want defined in the policy?"
                try {
                    $minHostInt = [int]::Parse($minHost)
                } catch {
                    Write-Host Failed to parse INT from minHost String
                }
                $maxHost = Read-Host -Prompt "What is the maximum number of hosts you want defined in the policy?"
                try {
                    $maxHostInt = [int]::Parse($maxHost)
                } catch {
                    Write-Host Failed to parse INT from maxHost String
                }
                Set-VmcClusterEdrsPolicy -Cluster $cluster -PolicyType "storage-scaleup" -MinHostCount $minHostInt -MaxHostCount $maxHostInt
                Write-Host The EDRS Policy for $cluster.Name has been changed to $(Get-VmcClusterEdrsPolicy -Cluster $cluster)
            }
            "performance" {
                $minHost = Read-Host -Prompt "What is the minimum number of hosts you want defined in the policy?"
                try {
                    $minHostInt = [int]::Parse($minHost)
                } catch {
                    Write-Host Failed to parse INT from minHost String
                }
                $maxHost = Read-Host -Prompt "What is the maximum number of hosts you want defined in the policy?"
                try {
                    $maxHostInt = [int]::Parse($maxHost)
                } catch {
                    Write-Host Failed to parse INT from maxHost String
                }
                Set-VmcClusterEdrsPolicy -Cluster $cluster -PolicyType "performance" -MinHostCount $minHostInt -MaxHostCount $maxHostInt
                Write-Host The EDRS Policy for $cluster.Name has been changed to $(Get-VmcClusterEdrsPolicy -Cluster $cluster)
            }
            "cost" {
                $minHost = Read-Host -Prompt "What is the minimum number of hosts you want defined in the policy?"
                try {
                    $minHostInt = [int]::Parse($minHost)
                } catch {
                    Write-Host Failed to parse INT from minHost String
                }
                $maxHost = Read-Host -Prompt "What is the maximum number of hosts you want defined in the policy?"
                try {
                    $maxHostInt = [int]::Parse($maxHost)
                } catch {
                    Write-Host Failed to parse INT from maxHost String
                }
                Set-VmcClusterEdrsPolicy -Cluster $cluster -PolicyType "cost" -MinHostCount $minHostInt -MaxHostCount $maxHostInt
                Write-Host The EDRS Policy for $cluster.Name has been changed to $(Get-VmcClusterEdrsPolicy -Cluster $cluster)
            }
            "rapid-scale" {
                $minHost = Read-Host -Prompt "What is the minimum number of hosts you want defined in the policy?"
                try {
                    $minHostInt = [int]::Parse($minHost)
                } catch {
                    Write-Host Failed to parse INT from minHost String
                }
                $maxHost = Read-Host -Prompt "What is the maximum number of hosts you want defined in the policy?"
                try {
                    $maxHostInt = [int]::Parse($maxHost)
                } catch {
                    Write-Host Failed to parse INT from maxHost String
                }
                $scaleIncrement = Read-Host -Prompt "How many hosts do you want to add at a time?"
                try {
                    $scaleIncrementInt = [int]::Parse($scaleIncrement)
                } catch {
                    Write-Host Failed to parse INT from scaleIncrement String
                }
                Set-VmcClusterEdrsPolicy -Cluster $cluster -PolicyType "rapid-scaleup" -MinHostCount $minHostInt -MaxHostCount $maxHostInt -ScaleUpHostIncrement $scaleIncrementInt
                Write-Host The EDRS Policy for $cluster.Name has been changed to $(Get-VmcClusterEdrsPolicy -Cluster $cluster)
            }
            default {
                Write-Host Setting the Default EDRS Policy
                Set-VmcClusterEdrsPolicy -Cluster $cluster -PolicyType "storage-scaleup" -MinHostCount $($sddc.HostCount) -MaxHostCount $($sddc.HostCount)
                Write-Host The EDRS Policy for $cluster.Name has been changed to $(Get-VmcClusterEdrsPolicy -Cluster $cluster)
            }
        }
    }
}

Write-Host -------------------------------

# Disconnect from VMware Cloud on AWS
Disconnect-Vmc -Confirm:$false
Write-Host Successfully cleaned up the VMC PowerCLI Connection.
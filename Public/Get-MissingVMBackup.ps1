function Get-MissingVmBackup{
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [string[]]$Clusters,
        [parameter(Mandatory)]
        [string[]]$ExcludedServers
    )

    Write-Verbose "Retrieving VMs"
    $vmList = @()
    foreach($cluster in $Clusters){
        $vmList += Get-ClusterResource -Cluster $cluster | Where-Object { $_.ResourceType -eq 'Virtual Machine' -and $_.OwnerGroup.Name -notin $ExcludedServers } | Select-Object -ExpandProperty OwnerGroup | Select-Object -ExpandProperty Name
    }

    Write-Verbose "Retrieving VBR Backup Objects."
    try {
        $backupObjects = Get-VBRJob | Where-Object JobType -eq Backup | Get-VBRJobObject | ForEach-Object{
            $jobObject = $_
            #If the job object is a cluster, find VMs for that cluster
            if($jobObject.Object.ViType -eq "Cluster"){
                Get-VBRServer -Name $jobObject.Object.Name | Find-VBRHvEntity -HostsAndVMs | Where-Object Type -eq VM | Select-Object -ExpandProperty Name
            }
            #Otherwise retrieve VM name
            else{
                $jobObject | Select-Object -ExpandProperty Name
            }
        }
    } catch {Write-Host 'Skipping Disabled Job'}

    $missingVms = [pscustomobject]@{
        MissingVms = $vmList | Where-Object { $_ -notin $backupObjects }
        ExcludedServers = $ExcludedServers
        BackupObjects = $backupObjects
    }
    $missingVms
}
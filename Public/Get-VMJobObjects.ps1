function Get-VMJobObjects {
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline)]
        [string[]]$JobName
    )
    begin{}
    process{
        if($JobName -eq $null){
            $exec = Get-VBRJob
        }else{
            $exec =  Get-VBRJob -Name $JobName
        }
        $exec | Where-Object JobType -eq Backup | Get-VBRJobObject | ForEach-Object{
            $jobObject = $_
            #If the job object is a cluster, find VMs for that cluster
            if($jobObject.Object.ViType -eq "Cluster"){
                Get-VBRServer -Name $jobObject.Object.Name | Find-VBRHvEntity -HostsAndVMs | Where-Object Type -eq VM
            }
            #Otherwise retrieve VM name
            else{
                $jobObject
            }
        }
    }
    end{}
}
function Get-LastXJobStatus {
    [cmdletbinding()]
    param(
        [int]$NoJobs = 5
    )
    $buSessions = Get-VBRBackupSession
    $jobs = Get-VBRJob | Select-Object Name,IsScheduleEnabled,IsRunning,@{n="LastRun";e={$_.ScheduleOptions.LatestRunLocal}},@{n="FullBackupScheduleKind";e={$_.BackupTargetOptions.FullBackupScheduleKind}},@{n="LatestStatus";e={$_.Info.LatestStatus}} | Sort-Object Name

    foreach ($job in $jobs){
        #Retrieve Last X number of job sessions
        $lastXSessions = $buSessions | Where-Object {$_.JobName -eq $job.Name} | Sort-Object EndTimeUTC -Descending | Select-Object -First $NoJobs
        
        #Get all VMs associated with this job
        $vmRuns = Get-VMJobObjects -JobName $job.Name | Select-Object -ExpandProperty Name | Sort-Object | Get-Unique | ForEach-Object {
            #build default session array
            foreach($session in $lastXSessions){
                [pscustomobject]@{
                    JobName = $job.Name
                    ServerName = $_
                    BackupSessionId = $session.Id
                    CreationTime = "$($session.CreationTime) Run"
                    Status = "Not Run"
                }
            }
        }

        $lastXSessions | ForEach-Object {
            #Alias backup session
            $currentBackupSession = $_
            #Get all VMs associated with session
            $taskSessions = $currentBackupSession | Get-VBRTaskSession
            #Foreach task (VM Job)            
            foreach ($taskSession in $taskSessions){
                #search for associated vm in VM job objects
                foreach($vmRun in $vmRuns){
                    #if found,
                    if(($taskSession.Name -eq $vmRun.ServerName) -and ($vmRun.BackupSessionId -eq $currentBackupSession.Id)){
                        $vmRun.Status = $taskSession.Status
                    }
                }
            }
        }
        $vmRuns
    }
}
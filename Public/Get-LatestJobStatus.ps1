function Get-LatestJobStatus {
    [cmdletbinding()]
    param()

    # Get list of last jobs run and add them to $jobs variable
    $lastXJobRuns = Get-LastXJobStatus
    $jobs = Get-VBRJob | Select-Object Name,IsScheduleEnabled,IsRunning,@{n="LastRun";e={$_.ScheduleOptions.LatestRunLocal}},@{n="FullBackupScheduleKind";e={$_.BackupTargetOptions.FullBackupScheduleKind}},@{n="LatestStatus";e={$_.Info.LatestStatus}} | Sort-Object Name

    # For every job, get information about each server in job
    foreach ($job in $jobs){
        Try {
            $lastXJobRunsForCurrentJob = $lastXJobRuns | Where-Object {$_.JobName -eq $job.Name}
            $pivotedData = Get-PivotedObject -Data $lastXJobRunsForCurrentJob -Entity 'ServerName' -Attribute 'CreationTime' -Value 'Status'
            [pscustomobject]@{
                Job = $job
                LastJobRunDetails = $pivotedData
            }

        #This catch is needed, otherwise disabled jobs in Veeam generate an error
        } Catch {Write-Host 'Skipping Disabled Job'}
    }
}
function Get-LatestJobObjectStatus{
    [cmdletbinding()]
    param()

    Write-Verbose "Retrieving VBR Backup Session."
    $buSession = Get-VBRBackupSession

    Write-Verbose "Selecting latest backup sessions."
    $latestBackupSessions = [System.Collections.ArrayList]@()
    foreach ($job in ($buSession | Group-Object JobName)){
         $latestBackupSessions += $job | Select-Object -ExpandProperty Group | Sort-Object EndTimeUTC -Descending | Select-Object -First 1 
    }

    Write-Verbose "Retrieving tasks for each session."
    $latestBackupSessions | ForEach-Object{
        $session = $_
        $session | Get-VBRTaskSession | ForEach-Object {
            $ts = $_
            [pscustomobject]@{
                CreationTime = $session.CreationTime
                EndTime = $session.EndTime
                JobName = $ts.JobName
                Name = $ts.Name
                Status = $ts.Status.ToString()
            }
        }
    }
}
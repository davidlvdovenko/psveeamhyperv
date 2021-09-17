function Get-BackupCheck {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$HyperVClusters,
        [Parameter(Mandatory)]
        [string]$VeeamServer,
        [Parameter(Mandatory)]
        [string[]]$ExcludedServers,
        [Parameter(Mandatory)]
        [string]$CompanyName
    )

    #License Info
    $veeamLicense = Get-VBRInstalledLicense | Select-Object Status,ExpirationDate,SupportExpirationDate
    #STATUS BY JOB
    $jobs = Get-LatestJobStatus

    #MISSING FROM BACKUP

    $missingFromBackup = Get-MissingVmBackup -Clusters $HyperVClusters -ExcludedServers $ExcludedServers

    $backupCheck = [pscustomobject]@{
        CompanyName = $CompanyName
        VeeamServer = $VeeamServer
        HyperVClusters = $HyperVClusters
        Jobs = $jobs
        VeeamLicenseInfo = $veeamLicense
        MissingFromBackup = $missingFromBackup
    }

    $backupCheck
}
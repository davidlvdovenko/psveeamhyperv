try{
    $ErrorActionPreference = "Stop"
    
    # Import configuration from JSON File #
    $config = Get-Content ".\ReportConfig.json" | ConvertFrom-Json

    # Define Variables from config file
    $MSPName = $config.MSPName

    # Load Veeam Powershell SnapIn #
    Add-PSSnapin VeeamPSSnapin
    
    # Authenticate and Connect to Veeam Server #
    Connect-VBRServer -User $config.Username -Password $config.Password -Server $config.VeeamServer

    # Import WowBackupReport Module #
    Import-Module -Name $config.ScriptDirectory -Force -Verbose

    # Generate new report
    $htmlFileName = "BackupReport_$($config.CompanyName -replace (' |[\W]',''))_$(get-date -Format yyyyMMdd_HHmmss).html"
    New-BackupCheckReport -BackupCheck (Get-BackupCheck -VeeamServer $config.VeeamServer -HyperVClusters $config.HyperVClusters -ExcludedServers $config.ExcludedServers -CompanyName $config.CompanyName -Verbose) > ".\$htmlFileName" -Verbose
    
    # Send Email to users specified in the config file #
    Write-Host "Script: Sending Email"
    $mailSplat = @{
        To = $config.Email.To
        From = $config.Email.From
        Subject = "$MSPName Backup Report: $($config.CompanyName) ($(Get-Date))"
        Body = "Please see attached for the $($config.CompanyName) backup report."
        SmtpServer = $config.Email.Server
        Attachments = $htmlFileName
    }
    Send-MailMessage @mailSplat
    Remove-Item "$htmlFileName"
    Disconnect-VBRServer
}
catch{
    # Close VBRServer Connection if Script fails #
    Disconnect-VBRServer
    
    # Errors get spit out into error.log #
    Add-Content -Path ".\error.log" -Value "[$(Get-Date)] ERROR: $($error[0].Exception.Message)"
    
    # Print Error to Terminal (For debugging) #
    $errormessage = "ERROR: $($error[0].Exception.Message)"
    Write-Output $errormessage

}

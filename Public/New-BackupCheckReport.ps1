function New-BackupCheckReport {
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        $BackupCheck
    )

    # Importing Excluded VMs Details JSON Config File
    $exconfig = Get-Content ".\ReportExclusions.json" | ConvertFrom-Json
    $configfile = Get-Content ".\ReportConfig.json" | ConvertFrom-Json

    # Define Variables from Config File
    $MSPName = $configfile.MSPName

    function Get-StatusLabel {
        param (
            $Status
        )
        switch($status){
            "Success" {"success"}
            "Valid" {"success"}
            "Warning" {"warning"}
            "Failed" {"danger"}
            default {"danger"}
        }        
    }

    function Get-DateStatusLabel {
        param(
            $ExpireDate
        )

    }
    html {
        head{
            Title "$($BackupCheck.CompanyName) Backup Report"
            $links = @{ 
                rel="stylesheet"
                href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css"
                #integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" 
                #crossorigin="anonymous"
            }

            foreach ($link in $links){
                link @link
            }
        }
        body{
            nav -class "navbar navbar-dark bg-dark"{
                a -class "navbar-brand" {
                    img -Class "mr-3" -src "https://www.wowrack.com/blog/wp-content/uploads/2016/07/logo-2.png" -width 30
                    "$MSPName Backup Report"
                } -href "#"
                span -class "navbar-text" {
                    "$(Get-Date)"
                }
            }
            #Top of page
            div -Class "container"{
                br
                h1 "$($BackupCheck.CompanyName)"
                br
                div -class "row" -id "statusDashboard" {
                    div -class "col border border-info rounded m-1 p-1 text-center" {
                        a -class "text-dark" -href "#vmBackupStatus" { h4 "Backing Up" }
                        $backupObjectCount = ($BackupCheck.MissingFromBackup.BackupObjects | Sort-Object | Get-Unique | Measure-Object).Count
                        h1 "$($backupObjectCount)"
                    }
                    div -class "col border border-warning rounded m-1 p-1 text-center" {
                        a -class "text-dark" -href "#excluded" { h4 "Excluded" }
                        h1 "$($BackupCheck.MissingFromBackup.ExcludedServers.Count)"
                    }
                    div -class "col border border-danger rounded m-1 p-1 text-center" {
                        a -class "text-dark" -href "#notInBackupJob" { h4 "Not Backing Up" }
                        h1 "$($BackupCheck.MissingFromBackup.MissingVms.Count)"
                    }
                }
                br
                #Clusters/Hosts
                div -class "row" {
                    
                    div -id "clusterHostAccordion" {
                        h4 "Clusters/Hosts"

                        if($BackupCheck.HyperVClusters){
                            div -class "card" {
                                #Card header attributes
                                $hyperVClusterCardAttr = @{
                                    "data-toggle"="collapse"
                                    "data-target"="#hyperVClusters"
                                    "aria-expanded"="true"
                                    "aria-controls"="hyperVClusters"
                                }
                                #Card header
                                div -id "hyperVClusterCard" -class "card-header" -style "cursor:pointer" -Attributes $hyperVClusterCardAttr {
                                    h5 -class "mb-0"{
                                        "Hyper-V Clusters"
                                        span -class "badge badge-primary badge-pill ml-5" {
                                            $BackupCheck.HyperVClusters.Count
                                        }
                                    }
                                }
                                #Card body attributes
                                $hyperVClustersAttr = @{
                                    "aria-labelledby"="hyperVClusterCard"
                                    "data-parent"="clusterHostAccordion"
                                }
                                #Card body
                                div -id "hyperVClusters" -class "collapse" -Attributes $hyperVClustersAttr {
                                    div -class "card-body" {
                                        foreach($cluster in $BackupCheck.HyperVClusters){
                                            $cluster
                                            br
                                        }
                                    }
                                }
                            }
                        }
                    }   
                }
                br
                div -class "row" {
                    div -class "col"{
                        h4 "Veeam Information"
                        table -class "table table-borderless table-sm" {
                            tbody {
                                tr {
                                    td -class "border-0" {
                                        span -class "font-weight-bold" { "Server: "}
                                    }
                                    td -class "border-0" { "$($BackupCheck.VeeamServer)"}
                                }
                                tr {
                                    td -class "border-0" {
                                        span -class "font-weight-bold" { "License Status: " }
                                    }
                                    td -class "border-0" { 
                                        
                                        span -class "text-$(Get-StatusLabel $BackupCheck.VeeamLicenseInfo.Status)" "$($BackupCheck.VeeamLicenseInfo.Status)"
                                    }
                                }
                                tr{
                                    $veeamExpireDate = ($BackupCheck.VeeamLicenseInfo.ExpirationDate).ToString("MM/dd/yyyy")
                                    td -class "border-0" {
                                        span -class "font-weight-bold" { "License Expiration: " }
                                    }
                                    td  -class "border-0"{
                                        "$veeamExpireDate"
                                    }
                                }
                            }
                        }
                    }
                }
            }
            br
            #Backup Job table
            div -class "container" -id "vmBackupStatus" {
                div -class "row" {
                    h3 "Veeam Job Status"
                    table -class "table border border-info" {
                        thead -class "border border-info" {
                            th -class "border-0" { "Job Name" }
                            th -class "border-0" { "Enabled" }
                            th -class "border-0" { "Schedule Kind" }
                            th -class "border-0" { "Currently Running" }
                            th -class "border-0" { "Last Run" }
                            th -class "border-0" { "Latest Status" }
                        }
                        $id = 0
                        tbody {
                            foreach ($job in ($BackupCheck.Jobs)){
                                $parentAttributes = @{"data-toggle"="collapse";"data-target"="#child$id";"aria-expanded"="true";"aria-controls"="child$id"}
                                tr -id "parent$($id)" -Style "background-color:#f6f8f9;cursor:pointer"  -Attributes $parentAttributes {
                                    td  "$($job.job.Name)"
                                    td "$($job.job.IsScheduleEnabled)"
                                    td "$($job.job.FullBackupScheduleKind)"
                                    td "$($job.job.IsRunning)"
                                    td "$($job.job.LastRun)"
                                    td -class "text-$(Get-StatusLabel $job.job.LatestStatus)" "$($job.job.LatestStatus)"
                                }#tr
                                $childAttributes = @{"aria-labelledby"="parent$id";"data-parent"="#accordion"}
                                tr -class "collapse" -id "child$id" -Attributes $childAttributes {
                                    td -Attributes @{"colspan"="6"} {
                                        table -class "table table-borderless table-sm " {
                                            thead {
                                                th "Server"
                                                foreach($header in ($job.LastJobRunDetails[0] | Get-Member -Name "*Run")){
                                                    th "$($header.Name)"
                                                }
                                            }
                                            tbody {
                                                foreach($jobTask in ($job.LastJobRunDetails)){
                                                    tr{
                                                        td "$($jobTask.ServerName)"
                                                        foreach($header in ($job.LastJobRunDetails[0] | Get-Member -Name "*Run" | Select-Object -ExpandProperty Name)){
                                                            $bgColor = switch ($jobTask.$header) {
                                                                "Success" { "bg-success"  }
                                                                "Failed" { "bg-danger"}
                                                                "Not Run" { "bg-secondary"}
                                                                
                                                            }
                                                            td{
                                                                div -class "d-flex justify-content-center" { div -Class "rounded-circle $bgColor" -style "height: 20px; width: 20px" {} }#{ <!--$jobTask.$header }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                $id += 1
                            }
                        }
                    }#table    
                }#row
            }#iv

            br
            div -class "container border border-warning rounded p-3" -id "excluded" {
                div -class "container"{
                    div -class "row" { h3 "Excluded VMs" }
                    div -class "row" {

                        # List of all Excluded VMs
                        ul -class "list-group list-group-flush" {
                            foreach ($server in ($BackupCheck.MissingFromBackup.ExcludedServers)){
                                $exdetails = $exconfig.ExclusionDetails.$server
                                li -class "list-group-item" "<b>$server</b> | $exdetails"
                            }
                        }
                    }
                }
            }
            br
            div -class "container border border-danger rounded p-3" -id "notInBackupJob" {
                div -class "container"{
                    div -class "row" { h3 "Not Found in Backup Job" }
                    div -class "row" {

                        # List of all missing VMs
                        ul -class "list-group list-group-flush" {
                            foreach ($server in ($BackupCheck.MissingFromBackup.MissingVms)){
                                li -class "list-group-item" "$server"
                            }
                        }
                    }
                }
            }
            br
            $scripts = @{
                src="https://code.jquery.com/jquery-3.2.1.slim.min.js" 
                integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" 
                crossorigin="anonymous"
            },
            @{
                src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"
                integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q"
                crossorigin="anonymous"
            },
            @{
                src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" 
                integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" 
                crossorigin="anonymous"
            }
            foreach ($script in $scripts){
                script @script
            }
        }
        $footerStyle = @"

height: 60px;
line-height: 60px;
background-color: #f5f5f5;
"@
        Footer -Class "footer bg-dark" -Style $footerStyle {
            div -class "container" {

            }
        }
    }#html

}

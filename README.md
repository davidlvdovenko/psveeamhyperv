# psveeamhyperv
A bundle of powershell scripts that sends reports over an SMTP Relay about Backup Jobs found in Veeam and compares it against a Hyper-V cluster.

For more information: https://www.davidlvdovenko.net/blog-powershell-veeam-hyperv/

## Introduction

Prerequisites: Setup Veeam, Microsoft Hyper-V server, SMTP Relay, and a general understanding of PowerShell and WINS.

Before we begin, full disclosure – I did not write any of these scripts. I found them and decided it could be a great tool for anyone looking for a solution. With that out the way – let’s take a look at what this does and how to use it.

This collection of PowerShell scripts takes a Hyper V server’s list of VMs and compares it to backup jobs and tasks found on a Veeam Backup and Replication server. It then spits out the results in an easy-to-read HTML file and emails it to you using an SMTP relay.

This script could see itself being used in a highly virtualized environment, where new VMs are being spun up and down every day. Keeping track of backups manually could be a real pain and this is where this script shines. Simply edit a config file with your configuration and you are off to the races.

## Environment

The environment setup is super simple. We simply have a Hyper-V Server and Veeam server on the same network with the Veeam server backing up VMs from the Hyper-V server in backup jobs depending on how you set up your Veeam configuration. In my scenario, at work, we also had a separate machine or VM on the same network called VM-AUTOMATION which hosted the scripts. The Automation VM was responsible for hosting these scripts and have them run using Task Scheduler daily. By doing this, we eliminate the need for any human intervention to run this script. We simply wake up every day with a new report waiting for us in our mailboxes.

## Installation


Before we begin, if you chose to do what I did and have a script host VM, you will need to install the Veeam Backup and Replication Console on that VM. Make sure it is the same version as the one on the Veeam Server. By installing the console, the console will also install the necessary PowerShell snap-ins that will be used by the PowerShell scripts…

To begin, go ahead and follow the link to my repository for all the scripts and configuration files needed for this to work:

     https://github.com/davidlvdovenko/psveeamhyperv

To explain what is going on in the repository – below is a breakdown of some of the main files you will find there and what they do:

BackupReportScript.ps1 | This is the main script. It initializes all variables, calls all the other scripts, and sends the report.
ReportConfig.json | This file contains all the configuration options for the script. The config file will be described in more detail below.
ReportExclusions.json | This file contains the exclusion details to track excluded VMs.

In order to get the script working, we need to make sure it has the correct settings needed to connect to the server. As an added note, the server names are resolved using WINS so make sure you have that set up and working. Below is an example of a configuration file for ReportConfig.json. Please take your time and make sure all settings here are correct. Everything here is pretty self-explanatory. Also, after you finish this config file, don’t forget the “ReportExclusions.json” file as well…


    {

    “CompanyName”: “Customer Name”,

    “HyperVClusters”: [

         “HYPERVSERVER1”,

         “HYPERVSERVER2”

    ],

    “ExcludedServers”: [

         “EXCLUDEDVM1”,

         “EXCLUDEDVM2”,

         “EXCLUDEDVM3”,

         “EXCLUDEDVM4”

    ],

    “ScriptDirectory”: “C:\\Users\\user\\Desktop\\Powershell Veeam Hyper-V Backup Report\\BackupReport.psm1”,

    “VeeamServer”:”VEEAMSERVER1″,

    “Username”:”VeeamAdministrator”,

    “Password”: “VeeamAdminPassword”,

    “MSPName”: “MSP Company”,

    “Email”:{

         “To”:[

              “email1@example.com”,”email2@example.com”

         ],

         “From”:”FromThisEmail@example.com”,

         “Server”:”relay.example.com”

          }

    }


Now comes the easy part. Go to your task scheduler and run the main “BackupReportScript.ps1” as an administrator at any scheduled time that you would like. It’s as simple as that.

If you have questions about the Veeam Snap-In for PowerShell you can visit the Veeam wiki and learn more about the different commands you can use. Below is the link to the wiki:

     https://helpcenter.veeam.com/docs/backup/powershell/getting_started.html

## Troubleshooting

If you happen to run into any issues while using the script, errors, or difficulties setting it up, contact me and I will attempt to reach and help you as best I can. Common issues or problems will also be listed here for everybody’s reference. Cheers, and Enjoy!

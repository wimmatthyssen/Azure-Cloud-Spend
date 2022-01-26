<#
.SYNOPSIS

A script used to get the start date, the end date and het current cost for all Subccriptions in a Tenant for the current billing period.

.DESCRIPTION

A script used get the start date, the end date and het current cost for all Subccriptions in a Tenant for the current billing period. 
First of all the script will check if PowerShell runs as an Administrator (when not running from Cloud Shell), otherwise the script will be exited as this is required.
Then it well get the start date, the end date and calculate the current cost for the current biling periond and display it for all Subscriptions in the Tenant.

.NOTES

Filename:       Get-Current-BillingPeriod-StartDate-EndDate-and-CurrentCost-for-all-Subscriptions-in-Tenant.ps1
Created:        26/01/2022
Last modified:  26/01/2022
Author:         Wim Matthyssen
PowerShell:     Azure Cloud Shell or Azure PowerShell
Version:        Install latest Azure Powershell modules (at least Az version 5.9.0 and Az.Network version 4.7.0 is required)
Action:         Change variables were needed to fit your needs. 
Disclaimer:     This script is provided "As Is" with no warranties.

.EXAMPLE

.\Get-Current-BillingPeriod-StartDate-EndDate-and-CurrentCost-for-all-Subscriptions-in-Tenant.ps1

.LINK


#>

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Variables

$global:currenttime= Set-PSBreakpoint -Variable currenttime -Mode Read -Action {$global:currenttime= Get-Date -UFormat "%A %m/%d/%Y %R"}
$foregroundColor1 = "Red"
$foregroundColor2 = "Yellow"
$writeEmptyLine = "`n"
$writeSeperatorSpaces = " - "

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Check if PowerShell runs as Administrator (when not running from Cloud Shell), otherwise exit the script

if ($PSVersionTable.Platform -eq "Unix") {
    Write-Host ($writeEmptyLine + "# Running in Cloud Shell" + $writeSeperatorSpaces + $currentTime)`
    -foregroundcolor $foregroundColor1 $writeEmptyLine
    
    # Start script execution    
    Write-Host ($writeEmptyLine + "# Script started" + $writeSeperatorSpaces + $currentTime)`
    -foregroundcolor $foregroundColor1 $writeEmptyLine 
} else {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdministrator = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        # Check if running as Administrator, otherwise exit the script
        if ($isAdministrator -eq $false) {
        Write-Host ($writeEmptyLine + "# Please run PowerShell as Administrator" + $writeSeperatorSpaces + $currentTime)`
        -foregroundcolor $foregroundColor1 $writeEmptyLine
        Start-Sleep -s 3
        exit
        } else {
        # If running as Administrator, start script execution    
        Write-Host ($writeEmptyLine + "# Script started" + $writeSeperatorSpaces + $currentTime)`
        -foregroundcolor $foregroundColor1 $writeEmptyLine 
        }
}

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Suppress breaking change warning messages

Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Get start date, end date and current cost

$subscriptions = Get-AzSubscription
foreach ($sub in $subscriptions)
{
    $sub | Select-AzSubscription
    
    $currentBillingPeriod = Get-AzBillingPeriod -MaxCount 1
    
    # Get start date
    $startDate = $currentBillingPeriod.BillingPeriodStartDate.ToString("yyyy-MM-dd")
    Write-Host ($writeEmptyLine + "# Current billing period start date: " + $startDate)`
    -foregroundcolor $foregroundColor2  

    # Get end date
    $endDate = $currentBillingPeriod.BillingPeriodEndDate.ToString("yyyy-MM-dd")
    Write-Host ($writeEmptyLine + "# Current billing period end date: " + $endDate)`
    -foregroundcolor $foregroundColor2 

    # Get current cost
    try 
    {
        $found =Get-AzConsumptionUsageDetail -StartDate $startDate -EndDate $endDate -ea 0
    
        if ($found.PretaxCost){
            $currentCost = $found | Measure-Object -Property PretaxCost -Sum
            Write-Host ($writeEmptyLine + "# Current Cost of Subscription: " + $currentCost.Sum)`
            -foregroundcolor $foregroundColor2 $writeEmptyLine
        } else {
            $msg = $writeEmptyLine + "# Current Cost of Subscription: 0 or Cost Management is not supported for the subscription (type) with Subscription ID: {0}" -f $sub.ToString() 
            Write-Host $msg -foregroundcolor $foregroundColor1 $writeEmptyLine
        }
    } catch {
        $msg="Error: {0}" -f $sub.ToString() ; Write-Host $msg -foregroundcolor $foregroundColor2 $writeEmptyLine 
    }  
}  

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Write script completed

Write-Host ($writeEmptyLine + "# Script completed" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor1 $writeEmptyLine 

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------








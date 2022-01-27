<#
.SYNOPSIS

A script used to get the start date, the end date and het current cost for all subscriptions in a tenant for the current billing period.

.DESCRIPTION

A script used get the start date, the end date and het current cost for all subscriptions in a tenant for the current billing period. 
First of all the script will get the start date for the current billing period.
Then it will get the end date for the current billing period. 
And finally it will calculate the current cost for the current billing period.
All of the above will be displayed per subscription in the tenant.

The script will work with all types of Azure Subscriptions (EA, Pay-as-you-Go, Visual Studio Enterprise, MSDN subscriptions, …), except with CSP subscriptions.

.NOTES

Filename:       Get-Current-BillingPeriod-StartDate-EndDate-and-CurrentCost-for-all-Subscriptions-in-Tenant.ps1
Created:        26/01/2022
Last modified:  26/01/2022
Author:         Wim Matthyssen
PowerShell:     Azure Cloud Shell or Azure PowerShell
Version:        Install latest Azure PowerShell modules (at least Az version 7.1.0 and Az.Billing version 2.0.0 is required)
Action:         Change variables were needed to fit your needs. 
Disclaimer:     This script is provided "As Is" with no warranties.

.EXAMPLE

Connect-AzAccount
Get-AzTenant (if not using the default tenant)
Set-AzContext -tenantID "xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxx" (if not using the default tenant)
.\Get-Current-BillingPeriod-StartDate-EndDate-and-CurrentCost-for-all-Subscriptions-in-Tenant.ps1

.LINK

https://wmatthyssen.com/2022/01/27/azure-cloud-spend-get-the-start-date-end-date-and-current-cost-for-the-current-billing-period-of-all-subscriptions-in-a-tenant-with-azure-powershell/
#>

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Variables

$global:currenttime= Set-PSBreakpoint -Variable currenttime -Mode Read -Action {$global:currenttime= Get-Date -UFormat "%A %m/%d/%Y %R"}
$foregroundColor1 = "Red"
$foregroundColor2 = "Yellow"
$writeEmptyLine = "`n"
$writeSeperatorSpaces = " - "

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Suppress breaking change warning messages

Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Start script execution

Write-Host ($writeEmptyLine + "# Script started. Depending on the amount of subscriptions, it will need around 1 - 2  minute(s) to complete" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor1 $writeEmptyLine 
 
## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Get start date, end date and current cost

# Loop trough all subscriptions in tenant and run commands
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
        $found = Get-AzConsumptionUsageDetail -StartDate $startDate -EndDate $endDate -ea 0
    
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

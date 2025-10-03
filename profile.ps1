# Azure Functions profile.ps1
#
# This profile.ps1 will get executed every "cold start" of your Function App.
# "cold start" occurs when:
#
# * A Function App starts up for the very first time
# * A Function App starts up after being de-allocated due to inactivity
#
# You can define helper functions, run commands, or specify environment variables
# NOTE: any variables defined that are not environment variables will get reset after the first execution

# Authenticate with Azure PowerShell using MSI.
# Remove this if you are not planning on using MSI or Azure PowerShell.

$modulesToImport = @(
    'Microsoft.Graph.Beta.Applications',
    'Microsoft.Graph.Users',
    'Microsoft.Graph.Authentication'
)

foreach ($module in $modulesToImport) {
    if (-not (Get-Module -Name $module)) {
        try {
            Write-Host "Importing module: $module"
            #Remove-Module -Name $module #-ErrorAction SilentlyContinue
            Import-Module -Name $module #-ErrorAction SilentlyContinue
        }
        catch {
            Write-Error "Failed to import $($module): $_"
        }
    }
}

# Use environment variable for Client ID (set in ARM template)
$clientId = $env:GRAPH_CLIENT_ID

if ($env:MSI_SECRET -and $clientId) {
    Connect-MgGraph -Identity -ClientId $clientId -NoWelcome
}

Write-Output "==========================================="
Write-Output "CONTEXT"
Write-Output ""
$context = Get-MgContext
Write-Output $context
Write-Output "==========================================="

# Uncomment the next line to enable legacy AzureRm alias in Azure PowerShell.
# Enable-AzureRmAlias

# You can also define functions or aliases that can be referenced in any of your PowerShell functions.

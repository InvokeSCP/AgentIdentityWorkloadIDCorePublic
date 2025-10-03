using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$tenantId = $Request.Headers.tenantId

$appsregisteredinTenant = 0
$appsnotregisteredinTenant = 0
$totalappsinTenant = 0

$totalappsinTenant = (Get-MgBetaServicePrincipal -All |? {$_.AppOwnerOrganizationId -ne "f8cdef31-a31e-4b4a-93e4-5f571e91255a"}).count
$appsregisteredinTenant = (Get-MgBetaServicePrincipal -All |?{$_.AppOwnerOrganizationId -eq $tenantId}).count
$appsnotregisteredinTenant = (Get-MgBetaServicePrincipal -All |?{$_.AppOwnerOrganizationId -ne $tenantId -and $_.AppOwnerOrganizationId -ne "f8cdef31-a31e-4b4a-93e4-5f571e91255a"}).count

$spObj = [PSCustomObject]@{
            "Total Service Principals discovered in this tenant"            = $totalappsinTenant
            "Service Principals with an app registration in this tenant"                  = $appsregisteredinTenant
            "Service Principals without an app registration in this tenant"               = $appsnotregisteredinTenant
        }

$body = $spObj | ConvertTo-Json -Compress

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})

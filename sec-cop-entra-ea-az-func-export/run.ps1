using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$tenantId = $Request.Headers.tenantId

$array = @()
Get-MgBetaServicePrincipal -All |?{$_.AppOwnerOrganizationId -ne "f8cdef31-a31e-4b4a-93e4-5f571e91255a"} | ForEach-Object {
    $spObj = [PSCustomObject]@{
        Id                     = $_.Id
        DisplayName            = $_.DisplayName
        AppOwnerOrganizationId = $_.AppOwnerOrganizationId
        AccountEnabled = $_.AccountEnabled
        AppId = $_.AppId
    }
    $array += $spObj
}
$body = $array | ConvertTo-Json -Compress

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})

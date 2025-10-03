using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Get all app registrations
$apps = Get-MgBetaApplication -All

# Define warning threshold (e.g., 30 days before expiry)
$warningDays = 30
$now = Get-Date

$results = foreach ($app in $apps) {
    if ($app.PasswordCredentials.Count -gt 0) {
        foreach ($secret in $app.PasswordCredentials) {
            $expiry = Get-Date $secret.EndDateTime
            $status = if ($expiry -lt $now) {
                "Expired"
            }
            elseif ($expiry -lt $now.AddDays($warningDays)) {
                "Nearing Expiry"
            }
            else {
                "Valid"
            }

            [PSCustomObject]@{
                AppName    = $app.DisplayName
                AppId      = $app.AppId
                ExpiryDate = $expiry
                Status     = $status
            }
        }
    }
}

$body = $results | ConvertTo-Json -Compress

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})

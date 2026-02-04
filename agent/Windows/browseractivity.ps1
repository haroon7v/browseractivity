$awServerUrl = "http://localhost:5600/api/0"
$clientName = "aw-client-web"
$timePeriod = -24 # last 1 day

try {
    # find bucketId
    $bucketsEndpoint = "$awServerUrl/buckets/"
    $buckets         = Invoke-RestMethod -Uri $bucketsEndpoint -Method Get
    $bucketId        = $null
    foreach ($bucket in $buckets.PSObject.Properties) {
        if ($bucket.Value.client -eq $clientName -and $bucket.Value.hostname -ne "unknown") {
            $bucketId = $bucket.Name
            break
        }
    }

    if (-not $bucketId) { throw "No bucket found for client '$clientName'" }

    # find events
    $startTime      = (Get-Date).AddHours($timePeriod).ToUniversalTime().ToString("o")
    $eventsEndpoint = "$awServerUrl/buckets/$bucketId/events?start=$startTime&limit=-1"
    $response       = Invoke-RestMethod -Uri $eventsEndpoint -Method Get

    if ($response) {
        foreach ($event in $response) {
            $url = $event.data.url
            $browser = $event.data.browser
            try {
                $uri      = [uri]$url
                $protocol = $uri.Scheme
                $domain   = $uri.Host
            } catch {
                # Handle invalid URLs gracefully
                $protocol = "Unknown"
                $domain   = "Unknown"
            }

            if ($protocol -ne "http" -and $protocol -ne "https") { continue; }
            if ($domain -eq "Unknown" -or [string]::IsNullOrWhiteSpace($domain)) { continue; }

            $xml += "<BROWSERACTIVITY>"
            $xml += "<URL>$url</URL>"
            $xml += "<DOMAIN>$domain</DOMAIN>"
            $xml += "<TITLE>$($event.data.title)</TITLE>"
            $xml += "<PROTOCOL>$protocol</PROTOCOL>"
            $xml += "<ACCESSED_AT>$($event.timestamp)</ACCESSED_AT>"
            $xml += "<DURATION>$($event.duration)</DURATION>" # duration in seconds.decimal
            $xml += "<BROWSER>$browser</BROWSER>"
            $xml += "</BROWSERACTIVITY>"
        }
    }
    else {
        $xml += "<BROWSERACTIVITY/>"
    }
    Write-Host $xml
}
catch {
    Write-Error "Error: $_"
}

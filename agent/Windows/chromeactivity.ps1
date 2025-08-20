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
            try {
                $uri      = [uri]$url
                $protocol = $uri.Scheme
                $domain   = $uri.Host
            } catch {
                # Handle invalid URLs gracefully
                $protocol = "Unknown"
                $domain   = "Unknown"
            }

            if ($protocol -eq "chrome" -or $domain -eq "Unknown") { continue; }

            $xml += "<BROWSERACTIVITY>"
            $xml += "<DOMAIN>$domain</DOMAIN>"
            $xml += "<TITLE>$($event.data.title)</TITLE>"
            $xml += "<PROTOCOL>$protocol</PROTOCOL>"
            $xml += "<ACCESSED_AT>$($event.timestamp)</ACCESSED_AT>"
            $xml += "<DURATION>$($event.duration)</DURATION>" # duration in seconds.decimal
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

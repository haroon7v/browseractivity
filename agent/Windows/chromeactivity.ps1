$xml             = ""
$sqlitePath      = "C:\Program Files\OCS Inventory Agent\sqlite3.exe"

Get-ChildItem -Path "C:\Users" | ForEach-Object {
    $userProfilePath = $_.FullName
    $username = $_.Name
    $chromeHistoryPath = "$userProfilePath\AppData\Local\Google\Chrome\User Data\Default\History"

    if (($username -eq "Public") -or !(Test-Path $chromeHistoryPath)) { return }

    $tempHistoryPath = "$env:TEMP\ChromeHistory_$username.db"

    try {
        Copy-Item -Path $chromeHistoryPath -Destination $tempHistoryPath -Force
        $rawResults = & $sqlitePath $tempHistoryPath "
            PRAGMA journal_mode=WAL;
            SELECT
                datetime(visits.visit_time/1000000-11644473600, 'unixepoch') AS VisitTime,
                urls.url AS URL,
                urls.title AS Title
            FROM
                urls
            JOIN
                visits ON urls.id = visits.url
            WHERE
                visits.visit_time > (strftime('%s', 'now') + 11644473600) * 1000000 - 86400000000
            ORDER BY
                visits.visit_time DESC
        " 

        $rawResults -split "`n" | ForEach-Object {
            $columns = $_ -split '\|'
            if ($columns.Count -eq 3) {
                $visitTime = $columns[0]
                $url = $columns[1]
                $title = $columns[2]

                try {
                    $uri = [uri]$url
                    $protocol = $uri.Scheme
                    $domain = $uri.Host
                } catch {
                    # Handle invalid URLs gracefully
                    $protocol = "Unknown"
                    $domain = "Unknown"
                }

                $xml += "<BROWSERACTIVITY>"
                $xml += "<DOMAIN>$domain</DOMAIN>"
                $xml += "<TITLE>$title</TITLE>"
                $xml += "<PROTOCOL>$protocol</PROTOCOL>"
                $xml += "<ACCESSEDAT>$visitTime</ACCESSEDAT>"
                $xml += "<USERNAME>$username</USERNAME>"
                $xml += "</BROWSERACTIVITY>"
            }
        }
    } catch {
        # NOTHING TO DO
    } finally {
        Remove-Item -Path $tempHistoryPath -Force -ErrorAction SilentlyContinue
    }
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::WriteLine($xml)

$subnet = "192.168.1"
$timeout = 100
$ports = @(80, 443, 8080, 8443) # Specify ports

foreach ($i in 1..254) {
    $ip = $subnet + "." + $i
    $ping = New-Object System.Net.NetworkInformation.Ping
    $pingReply = $ping.Send($ip, $timeout)

    if ($pingReply.Status -eq "Success") {
        $hostname = $ip
        $openPorts = @()

        foreach ($port in $ports) {
            $tcpClient = New-Object System.Net.Sockets.TcpClient

            try {
                $tcpClient.Connect($ip, $port)

                if ($tcpClient.Connected) {
                    $openPorts += $port
                }

                $tcpClient.Close()
            }
            catch {
                # Ignore errors.
            }
        }

        if ($openPorts) {
            $hostname = (Resolve-DnsName $ip -ErrorAction SilentlyContinue).NameHost

            Write-Host -NoNewline "Device found at IP: $($ip)" -ForegroundColor Green
            Write-Host -NoNewline " | Hostname: $($hostname)" -ForegroundColor Yellow
            Write-Host " | Open Ports: $($openPorts -join ', ')" -ForegroundColor Cyan

            # Flush output buffer.
            Out-Null
        } else {
            $hostname = (Resolve-DnsName $ip -ErrorAction SilentlyContinue).NameHost

            Write-Host -NoNewline "Device found at IP: $($ip)" -ForegroundColor Green
            Write-Host -NoNewline " | Hostname: $($hostname)" -ForegroundColor Yellow
            Write-Host " | No Open Ports Found" -ForegroundColor Gray

            # Flush output buffer.
            Out-Null
        }
    } else {
        Write-Host "Scanning IP: $($ip)" -ForegroundColor Gray
    }
}

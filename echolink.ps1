$url = "https://www.echolink.org/proxylist.jsp"
$response = Invoke-WebRequest -Uri $url
$htmlDoc = $response.ParsedHtml
$table = $htmlDoc.getElementsByTagName("table") | Where-Object { $_.getAttribute("border") -eq "1" }
$rows = $table.getElementsByTagName("tr")
$readyProxy = $null
foreach ($row in $rows) {
    if ($row.className -eq "normal-row") {
        $status = $row.getElementsByTagName("td") | Where-Object { $_.cellIndex -eq 4 } | ForEach-Object { $_.innerText.Trim() }
        if ($status -eq "Ready") {
            $readyProxy = $row
            break
        }
    }
}
if ($readyProxy -ne $null) {
    $cells = $readyProxy.getElementsByTagName("td") | ForEach-Object { $_.innerText.Trim() }
    $proxyName = $cells[0]
    $proxy = $cells[1]
	$regPath = "HKCU:\Software\K1RFD\EchoLink\Options"
    Set-ItemProperty -Path $regPath -Name "ProxyName" -Value $proxyName
    Set-ItemProperty -Path $regPath -Name "Proxy" -Value $proxy
    Write-Output "EchoLink proxy registry updated."
    Write-Output "ProxyName: $proxyName"
    Write-Output "Proxy: $proxy"
} else {
    Write-Output "There is not any ready proxy."
}
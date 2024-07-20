# Script content
$script = @"
# Email config
\$smtpServer = "smtp.example.com"
\$smtpFrom = "you@example.com"
\$smtpTo = "recipient@example.com"
\$messageSubject = "Security Test Report"
\$smtpUser = "you@example.com"
\$smtpPass = "yourpassword"

# Collect data
\$sysInfo = Get-ComputerInfo | Select-Object -Property CsName, WindowsVersion, OsArchitecture
\$networkInfo = Get-NetAdapter | Select-Object -Property Name, Status, MacAddress
\$portScanResults = Test-NetConnection -ComputerName "192.168.1.1" -Port 22,80,443
\$firewallStatus = Get-NetFirewallProfile | Select-Object -Property Name, Enabled
\$antivirusStatus = Get-CimInstance -Namespace "root/SecurityCenter2" -ClassName "AntiVirusProduct" | Select-Object -Property displayName

# Compile report
\$report = @"
System Info:
\$($sysInfo | Format-List | Out-String)

Network Info:
\$($networkInfo | Format-Table | Out-String)

Port Scan:
\$($portScanResults | Format-Table | Out-String)

Firewall:
\$($firewallStatus | Format-Table | Out-String)

Antivirus:
\$($antivirusStatus | Format-Table | Out-String)
"@

# Send email
\$mailMessage = New-Object system.net.mail.mailmessage
\$mailMessage.from = \$smtpFrom
\$mailMessage.To.add(\$smtpTo)
\$mailMessage.Subject = \$messageSubject
\$mailMessage.Body = \$report
\$smtp = New-Object Net.Mail.SmtpClient(\$smtpServer)
\$smtp.Credentials = New-Object System.Net.NetworkCredential(\$smtpUser, \$smtpPass)
\$smtp.Send(\$mailMessage)
"@

# Encode and execute
$encodedScript = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($script))
Invoke-Expression "powershell -EncodedCommand $encodedScript"

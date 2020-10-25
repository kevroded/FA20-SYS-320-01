# send an email

# Body of the email
$msg = "Hello there."
write-host -BackgroundColor Red -ForegroundColor white $msg

# Email From Address
$email = "kevin.rode@mymail.champlain.edu"

# To address
$toEmail = "deployer@csi-web"

# send email
Send-MailMessage -From $email -To $toEmail -Subject "A Greeting" -Body $msg -SmtpServer 192.168.6.71
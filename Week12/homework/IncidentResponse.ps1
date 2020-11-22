# Incident Response Toolkit
# This script is designed to gather important artifacts from a maachine for use in IR processes

# Prompt for where to save files
$out = Read-Host -Prompt "What folder should the files be saved in?"
if(!(Test-Path $out))
{
    New-Item -ItemType Directory -Force -Path $out
}
$zip_out = Read-Host -Prompt "What folder should zip file be saved in? NOTE: Not the same as the previous directory"
if(!(Test-Path $zip_out))
{
    New-Item -ItemType Directory -Force -Path $zip_out
}

# CSV Save Function
function Save-File {
    param(
        $output
    )
    
    process {Export-Csv -InputObject $_ -Path "$output" -NoTypeInformation -Append -Force}
}

# Checksum function
function checksum {
    param(
        $file,
        $output
    )
    Get-FileHash -Algorithm MD5 -Path $file | format-table -HideTableHeaders | Out-File -Append -FilePath $output
}

# Gather all running proccesses and their paths
gwmi win32_process | select Handle, name, ExecutablePath | Save-File -output "$out\processes.csv"
checksum -file "$out\processes.csv" -output "$out\checksum.txt"

# Gather all services and the paths to their executables
gwmi win32_service | select Name, State, PathName | Save-File -output "$out\services.csv"
checksum -file "$out\services.csv" -output "$out\checksum.txt"

# Show all TCP network sockets
Get-NetTCPConnection | Save-File -output "$out\sockets.csv"
checksum -file "$out\sockets.csv" -output "$out\checksum.txt"

# Gather all User information
gwmi Win32_UserAccount | select Name, Domain, AccountType, SID, InstallDate | Save-File -output "$out\users.csv"
checksum -file "$out\users.csv" -output "$out\checksum.txt"

# Network Adapter Information
Get-NetAdapter | Save-File -output "$out\adapter.csv"
checksum -file "$out\adapter.csv" -output "$out\checksum.txt"

# Get Installed Applications
# This was added because if the computer was used in an enterprise envirometn unauthorized software can be quickly recognized
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Save-File -output "$out\apps.csv"
checksum -file "$out\apps.csv" -output "$out\checksum.txt"

# Get 3rd Party Drivers
# This was added so that any new drivers added during a compromise can be examined
Get-WindowsDriver -Online | Select Driver, ProviderName, Date, OriginalFileName | Save-File -output "$out\drivers.csv"
checksum -file "$out\drivers.csv" -output "$out\checksum.txt"

#Get Autostart programs
# This was added so that any malicious autostart programs could be identified
Get-CimInstance -ClassName Win32_StartupCommand | select -Property Command, Description, User, Location | Save-File -output "$out\autostart.csv"
checksum -file "$out\autostart.csv" -output "$out\checksum.txt"

# DNS Cache
# This was added to see if during a breach a malicious url was accessed
Get-DnsClientCache | Save-File -output "$out\dns.csv"
checksum -file "$out\dns.csv" -output "$out\checksum.txt"

# Zip resulting Directory
Compress-Archive -Path $out -DestinationPath "$zip_out\IR_Results.zip"
checksum -file "$zip_out\IR_Results.zip" -output "$zip_out\checksum.txt"

# Email Zip File
$email = "kevin.rode@mymail.champlain.edu"
$ToEmail = "deployer@csi-web"
$msg = "Please see the attached files"
Send-MailMessage -From $email -To $toEmail -Subject "Week 12 Lab Files" -Body $msg -Attachments "$zip_out\IR_Results.zip" -SmtpServer 192.168.6.71

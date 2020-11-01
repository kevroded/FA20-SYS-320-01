# Use the get-wmi cmdlet
# Get-WmiObject -class Win32_service | select Name, PathName, ProcessId

#Get-WmiObject -list | where { $_.Name -ilike "Win32_[n-o]*"} | Sort-Object

#Get-WmiObject -Class Win32_Account | Format-Table

# Get Network adapter information
Get-WmiObject Win32_networkadapter | Format-Table
# Get the IP, gateway, DNS
Get-WmiObject win32_networkadapterconfiguration | where { $_.IPAddress } | select IPAddress, DefaultIPGateway, DNSServerSearchOrder | Format-Table
# Get DHCP server
Get-WmiObject win32_networkadapterconfiguration | where { $_.IPAddress } | select DHCPServer
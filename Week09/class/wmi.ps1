# Use the get-wmi cmdlet
# Get-WmiObject -class Win32_service | select Name, PathName, ProcessId

#Get-WmiObject -list | where { $_.Name -ilike "Win32_[n-o]*"} | Sort-Object

#Get-WmiObject -Class Win32_Account | Format-Table

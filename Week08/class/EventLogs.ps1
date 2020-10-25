# Review the security event log

# List all the available event logs
Get-EventLog -list

# create a prompt to allow the user to select the event log they want to view
$readLog = Read-host -Prompt "Please select a log to review from the above list"

# Print log results
Get-EventLog -LogName $readLog -Newest 40 | where {$_.Message -ilike "*new process has been*" }| Export-Csv -NoTypeInformation `
-Path "E:\FA20-SYS-320-01\Week08\class\$readLog-log.csv"

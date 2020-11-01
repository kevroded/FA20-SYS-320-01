# Get running services and proccesses and save them to separate files
Get-Process | Export-Csv -NoTypeInformation -Path E:\FA20-SYS-320-01\Week09\homework\process.csv
Get-Service | where {$_.Status -eq "Running"}|Export-Csv -NoTypeInformation -Path E:\FA20-SYS-320-01\Week09\homework\service.csv
#Start windows calculator
Start-Process -FilePath "calc"
# Wait for key press
Read-Host -Prompt "Press enter to close calculator"
# stop windows calculator
Stop-Process -Name "Calculator"
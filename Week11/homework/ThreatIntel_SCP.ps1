# Allows the user to view all services or just thgose running or stopped
# Array of options
$optionArray = @('All', 'Stopped', 'Running', 'q')
# Reads option
$option = Read-Host -Prompt 'Would you like to view [All] [Running] or [Stopped] services? Press [q] to quit'
# Checks that option is one of the accepted options
if ( -not ($optionArray -contains $option))  
    {
        Write-Output "Option not found. Please specify 'All' 'Running' or 'Stopped'"
    }
# If the option was 'q' the program exits
if ($option -eq 'q')
    {
        exit
    }
else 
# If the option was all then all services are returned
# Also set up to export to CSV so they can be uploaded
    {
        if ( $option -eq "All" ) 
            {
                Get-Service | Export-Csv -NoTypeInformation -Path "E:\FA20-SYS-320-01\Week11\homework\kevin.rode.logs"
            }
        # Else the Get-Service CMDlet is run with the option as the parameter to filter results
        # Also set up to export to CSV so they can be uploaded
        else
            {
                Get-Service | where {$_.Status -eq $option} | Export-Csv -NoTypeInformation -Path "E:\FA20-SYS-320-01\Week11\homework\kevin.rode.logs"
            }
        
    }

# Copy files to remote server
Set-SCPFile -ComputerName "192.168.6.71" -Credential (Get-Credential cyber.local\kevin.rode) -RemotePath '/home/kevin.rode' -LocalFile 'E:\FA20-SYS-320-01\Week11\homework\kevin.rode.logs'

# Confirm the file was copied
# Open SSH session
New-SSHSession -ComputerName '192.168.6.71' -Credential (Get-Credential cyber.local\kevin.rode)
# While loop for reading and running commands
while ($true) {
    $cmd = read-host -Prompt "Enter a Command"

    (Invoke-SSHCommand -index 0 $cmd).Output
}

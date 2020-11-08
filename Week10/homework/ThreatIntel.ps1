$optionArray = @('All', 'Stopped', 'Running', 'q')
$option = Read-Host -Prompt 'Would you like to view [All] [Running] or [Stopped] services? Press [q] to quit'
if ( -not ($optionArray -contains $option))  
    {
        Write-Output "Option not found. Please specify 'All' 'Running' or 'Stopped'"
    }
if ($option -eq 'q')
    {
        exit
    }
else 
    {
        if ( $option -eq "All" )
            {
                Get-Service
            }
        else
            {
                Get-Service | where {$_.Status -eq $option}
            }
    }
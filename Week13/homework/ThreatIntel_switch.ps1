# Parses threat intel files for a list of bad ips then makes firewall rules out of them

# Array of websites containing threat intel
$drop_urls = @('https://rules.emergingthreats.net/blockrules/emerging-botcc.rules','https://rules.emergingthreats.net/blockrules/compromised-ips.txt')
# Loop through the URLs for the rules list
foreach ($u in $drop_urls) {
    # Extract the filename
    $temp = $u.split("/")
    # The last element in the array plucked off is the filename
    $file_name = $temp[-1]
    if (Test-Path $file_name) {
        continue
    } else {
    # Download the rules list
    Invoke-WebRequest -Uri $u -OutFile $file_name
    }
}

# Array containing the filename
$input_paths = @('.\compromised-ips.txt','.\emerging-botcc.rules')

# Extract the IP addresses
$regex_drop = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'

# Append the IP addresses to the temporary IP list
Select-String -Path $input_paths -Pattern $regex_drop | `
ForEach-Object { $_.Matches } | `
ForEach-Object { $_.Value } | Sort-Object | Get-Unique | `
Out-File -FilePath "ips-bad.tmp"
# Query the user for how to save the firewall rules
$val = Read-Host -Prompt "Would you like to save the rules for Windows[0] IPTables[1] or Cisco[2] "
# Use a switch statement to decide what ruleset should be made
switch ( $val )
{

    0 {(Get-Content -Path ".\ips-bad.tmp") | % `
    { $_ -replace "^", "netsh advfirewall firewall add rule name='IP block' dir=in interface=any action=block remoteip="} | `
    Out-File -FilePath "netsh.windows" }
    1 {(Get-Content -Path ".\ips-bad.tmp") | % `
    { $_ -replace "^", "iptables -A INPUT -s " -replace "$", " -j DROP" } | `
    Out-File -FilePath "iptables.bash" }
    2 {(Get-Content -Path ".\ips-bad.tmp") | % `
    { $_ -replace "^", "access-list 1 deny ip " -replace "$", " 0.0.0.0 any" } | `
    Out-File -FilePath "access-list.cisco" }
}
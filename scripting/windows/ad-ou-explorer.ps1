# Ensure ActiveDirectory module is imported
Import-Module ActiveDirectory -ErrorAction Stop

# Get all Organizational Units
$OUs = Get-ADOrganizationalUnit -Filter * | Sort-Object Name

# Display OUs with index numbers
Write-Host "Available Organizational Units:`n"
for ($i = 0; $i -lt $OUs.Count; $i++) {
    Write-Host "$i) $($OUs[$i].Name) - $($OUs[$i].DistinguishedName)"
}

# Ask user to select an OU
$ouIndex = Read-Host "`nEnter the number of the OU you want to query"
if ($ouIndex -notmatch '^\d+$' -or [int]$ouIndex -ge $OUs.Count) {
    Write-Host "Invalid selection. Exiting." -ForegroundColor Red
    exit
}

$selectedOU = $OUs[$ouIndex].DistinguishedName

# Ask whether to search recursively
$recursive = Read-Host "`nSearch sub-OUs recursively? (y/n)"
$searchScope = if ($recursive -eq 'y') { 'Subtree' } else { 'OneLevel' }

# Ask what to list (Users, Groups, or Computers)
$type = Read-Host "`nDo you want to list 'Users', 'Groups', or 'Computers'? (type 'user', 'group', or 'computer')"

$data = @()

switch ($type.ToLower()) {
    "user" {
        Write-Host "`nListing users in OU: $selectedOU (Recursive: $($recursive -eq 'y'))`n"
        $data = Get-ADUser -Filter * -SearchBase $selectedOU -SearchScope $searchScope -Properties DisplayName, SamAccountName, UserPrincipalName, EmailAddress, Enabled, LastLogonDate, PasswordLastSet, Department, Title |
            Select-Object Name, 
                SamAccountName, 
                UserPrincipalName, 
                EmailAddress,
                Enabled,
                @{Name='LastLogon';Expression={$_.LastLogonDate -as [datetime]}},
                @{Name='PasswordLastSet';Expression={$_.PasswordLastSet -as [datetime]}},
                Department,
                Title,
                @{Name='OU';Expression={$_.DistinguishedName -replace '^.*?,(OU=.*)', '$1' -split ',' | Select-Object -First 1}}
    }
    "group" {
        Write-Host "`nListing groups in OU: $selectedOU (Recursive: $($recursive -eq 'y'))`n"
        $data = Get-ADGroup -Filter * -SearchBase $selectedOU -SearchScope $searchScope -Properties Name, SamAccountName, GroupCategory, GroupScope, Description, Members |
            Select-Object Name, 
                SamAccountName, 
                GroupCategory, 
                GroupScope,
                @{Name='MemberCount';Expression={$_.Members.Count}},
                Description,
                @{Name='OU';Expression={$_.DistinguishedName -replace '^.*?,(OU=.*)', '$1' -split ',' | Select-Object -First 1}}
    }
    "computer" {
        Write-Host "`nListing computers in OU: $selectedOU (Recursive: $($recursive -eq 'y'))`n"
        $data = Get-ADComputer -Filter * -SearchBase $selectedOU -SearchScope $searchScope -Properties Name, DNSHostName, OperatingSystem, OperatingSystemVersion, LastLogonDate, Enabled, Description |
            Select-Object Name, 
                DNSHostName,
                OperatingSystem, 
                OperatingSystemVersion,
                @{Name='LastLogon';Expression={$_.LastLogonDate -as [datetime]}},
                Enabled,
                Description,
                @{Name='OU';Expression={$_.DistinguishedName -replace '^.*?,(OU=.*)', '$1' -split ',' | Select-Object -First 1}}
    }
    default {
        Write-Host "Invalid type. Please type 'user', 'group', or 'computer'." -ForegroundColor Red
        exit
    }
}

# Check if any objects were found
if ($data.Count -eq 0) {
    Write-Host "`nNo $type found in the selected OU (Recursive: $($recursive -eq 'y'))." -ForegroundColor Yellow
    exit
}

# Show the data
$data | Format-Table -AutoSize

# Export to CSV if requested
$export = Read-Host "`nDo you want to export the results to CSV? (y/n)"
if ($export.ToLower() -eq "y") {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $filename = "$($type.ToLower())-list-$timestamp.csv"
    $fullPath = Join-Path -Path (Get-Location) -ChildPath $filename
    $data | Export-Csv -Path $fullPath -NoTypeInformation -Force
    Write-Host "`nExported to: $fullPath" -ForegroundColor Green
}
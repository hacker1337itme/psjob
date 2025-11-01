# DC1-Setup.ps1 - Run on 2304_DC1 as Administrator

# Import modules
Import-Module ActiveDirectory
Import-Module GroupPolicy

Write-Host "=== Setting up Domain1 Infrastructure ===" -ForegroundColor Green

# Exercise 1 - Task 1: Create OU, groups and users
Write-Host "Creating Ventes OU and groups..." -ForegroundColor Yellow

# Create Ventes OU
try {
    New-ADOrganizationalUnit -Name "Ventes" -Path "DC=domain1,DC=com" -ProtectedFromAccidentalDeletion $false
    Write-Host "Ventes OU created" -ForegroundColor Green
}
catch {
    Write-Host "Ventes OU already exists or error: $_" -ForegroundColor Yellow
}

# Create Global Groups
$GlobalGroups = @("Ventes_Global_Group1", "Ventes_Global_Group2")
foreach ($Group in $GlobalGroups) {
    try {
        New-ADGroup -Name $Group -GroupCategory Security -GroupScope Global -Path "OU=Ventes,DC=domain1,DC=com" -Description "$Group for sales department"
        Write-Host "Global group $Group created" -ForegroundColor Green
    }
    catch {
        Write-Host "Group $Group already exists or error: $_" -ForegroundColor Yellow
    }
}

# Create Domain Local Groups
$LocalGroups = @("Ventes_Local_Group1", "Ventes_Local_Group2")
foreach ($Group in $LocalGroups) {
    try {
        New-ADGroup -Name $Group -GroupCategory Security -GroupScope DomainLocal -Path "OU=Ventes,DC=domain1,DC=com" -Description "Domain local $Group"
        Write-Host "Domain local group $Group created" -ForegroundColor Green
    }
    catch {
        Write-Host "Group $Group already exists or error: $_" -ForegroundColor Yellow
    }
}

# Create Users
Write-Host "Creating users..." -ForegroundColor Yellow
$UserPassword = ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force

$Users = @(
    @{Name="VenteUser1"; SamAccountName="venteuser1"; Group="Ventes_Global_Group1"},
    @{Name="VenteUser2"; SamAccountName="venteuser2"; Group="Ventes_Global_Group1"},
    @{Name="VenteUser3"; SamAccountName="venteuser3"; Group="Ventes_Global_Group2"},
    @{Name="VenteUser4"; SamAccountName="venteuser4"; Group="Ventes_Global_Group2"}
)

foreach ($User in $Users) {
    try {
        New-ADUser -Name $User.Name -GivenName $User.Name -Surname "User" -SamAccountName $User.SamAccountName -UserPrincipalName "$($User.SamAccountName)@domain1.com" -Path "OU=Ventes,DC=domain1,DC=com" -AccountPassword $UserPassword -Enabled $true -ChangePasswordAtLogon $false
        Add-ADGroupMember -Identity $User.Group -Members $User.SamAccountName
        Write-Host "User $($User.Name) created and added to $($User.Group)" -ForegroundColor Green
    }
    catch {
        Write-Host "User $($User.Name) already exists or error: $_" -ForegroundColor Yellow
    }
}

# Exercise 1 - Task 3: Add global groups to local groups
Write-Host "Configuring group membership..." -ForegroundColor Yellow
try {
    Add-ADGroupMember -Identity "Ventes_Local_Group1" -Members "Ventes_Global_Group1"
    Add-ADGroupMember -Identity "Ventes_Local_Group2" -Members "Ventes_Global_Group2"
    Write-Host "Global groups added to domain local groups" -ForegroundColor Green
}
catch {
    Write-Host "Group membership already configured or error: $_" -ForegroundColor Yellow
}

# Exercise 2 - Task 2: Create incoming trust from Domain2
Write-Host "Configuring forest trust..." -ForegroundColor Yellow
try {
    # Check if trust already exists
    $ExistingTrust = Get-ADTrust -Filter "Name -like 'domain2.com'"
    if (-not $ExistingTrust) {
        # Create incoming trust
        New-ADTrust -Name "domain2.com" -Direction Inbound -TrustType Forest -TargetDomainName "domain2.com"
        Write-Host "Incoming trust from domain2.com created" -ForegroundColor Green
    } else {
        Write-Host "Trust already exists" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Trust configuration may require additional setup: $_" -ForegroundColor Red
}

# Exercise 3 - Task 1: Configure domain password policy
Write-Host "Configuring domain password policy..." -ForegroundColor Yellow

# Configure password policy via PowerShell Direct
try {
    # Password Policy
    Set-ADDefaultDomainPasswordPolicy -Identity domain1.com -MinPasswordLength 8 -PasswordHistoryCount 24 -ComplexityEnabled $true -ReversibleEncryptionEnabled $false -MinPasswordAge "1.00:00:00" -MaxPasswordAge "90.00:00:00"
    
    # Account Lockout Policy  
    Set-ADAccountLockoutThreshold -Identity "DC=domain1,DC=com" -Threshold 5 -DateTime "0.00:30:00"
    
    Write-Host "Domain password policy configured successfully" -ForegroundColor Green
}
catch {
    Write-Host "Error configuring password policy: $_" -ForegroundColor Red
}

Write-Host "`n=== Domain1 Setup Complete ===" -ForegroundColor Green
Write-Host "Groups and Users created in Ventes OU" -ForegroundColor Cyan
Write-Host "Global groups added to Domain Local groups" -ForegroundColor Cyan
Write-Host "Forest trust configured for Domain2" -ForegroundColor Cyan
Write-Host "Password policy applied" -ForegroundColor Cyan

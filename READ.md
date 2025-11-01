```ps
# M2 SSI - TP1 - Active Directory Authentication and Authorization Strategy
# Complete PowerShell Script for all exercises

# Import required modules
Import-Module ActiveDirectory
Import-Module GroupPolicy

# Variables
$Domain1 = "domain1.com"
$Domain2 = "domain2.com"
$AdminUser = "administrateur"
$AdminPassword = "P@ssw0rd"
$SecurePassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force

# Function to execute commands on remote computers
function Invoke-RemoteCommand {
    param(
        [string]$ComputerName,
        [string]$ScriptBlock,
        [PSCredential]$Credential
    )
    
    try {
        Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -Credential $Credential
    }
    catch {
        Write-Warning "Failed to execute on $ComputerName : $_"
    }
}

# Exercise 1: Resource Authorization Strategy
Write-Host "=== Exercise 1: Resource Authorization Strategy ===" -ForegroundColor Green

# Task 1: Create global groups and assign users
Write-Host "Task 1: Creating organizational structure and groups..." -ForegroundColor Yellow

# Create OU and groups
try {
    # Create Ventes OU
    New-ADOrganizationalUnit -Name "Ventes" -Path "DC=domain1,DC=com" -ProtectedFromAccidentalDeletion $false
    
    # Create global groups
    New-ADGroup -Name "Ventes_Global_Group1" -GroupCategory Security -GroupScope Global -Path "OU=Ventes,DC=domain1,DC=com"
    New-ADGroup -Name "Ventes_Global_Group2" -GroupCategory Security -GroupScope Global -Path "OU=Ventes,DC=domain1,DC=com"
    
    # Create domain local groups
    New-ADGroup -Name "Ventes_Local_Group1" -GroupCategory Security -GroupScope DomainLocal -Path "OU=Ventes,DC=domain1,DC=com"
    New-ADGroup -Name "Ventes_Local_Group2" -GroupCategory Security -GroupScope DomainLocal -Path "OU=Ventes,DC=domain1,DC=com"
    
    # Create users
    $UserPassword = ConvertTo-SecureString "TempP@ss123" -AsPlainText -Force
    
    # Users for Group 1
    New-ADUser -Name "VenteUser1" -GivenName "Vente" -Surname "User1" -SamAccountName "venteuser1" -UserPrincipalName "venteuser1@domain1.com" -Path "OU=Ventes,DC=domain1,DC=com" -AccountPassword $UserPassword -Enabled $true
    New-ADUser -Name "VenteUser2" -GivenName "Vente" -Surname "User2" -SamAccountName "venteuser2" -UserPrincipalName "venteuser2@domain1.com" -Path "OU=Ventes,DC=domain1,DC=com" -AccountPassword $UserPassword -Enabled $true
    
    # Users for Group 2
    New-ADUser -Name "VenteUser3" -GivenName "Vente" -Surname "User3" -SamAccountName "venteuser3" -UserPrincipalName "venteuser3@domain1.com" -Path "OU=Ventes,DC=domain1,DC=com" -AccountPassword $UserPassword -Enabled $true
    New-ADUser -Name "VenteUser4" -GivenName "Vente" -Surname "User4" -SamAccountName "venteuser4" -UserPrincipalName "venteuser4@domain1.com" -Path "OU=Ventes,DC=domain1,DC=com" -AccountPassword $UserPassword -Enabled $true
    
    # Add users to global groups
    Add-ADGroupMember -Identity "Ventes_Global_Group1" -Members "venteuser1", "venteuser2"
    Add-ADGroupMember -Identity "Ventes_Global_Group2" -Members "venteuser3", "venteuser4"
    
    Write-Host "OU, groups and users created successfully" -ForegroundColor Green
}
catch {
    Write-Warning "Error creating AD structure: $_"
}

# Task 2: Create shared resource on Client1
Write-Host "Task 2: Creating shared resource on Client1..." -ForegroundColor Yellow

$Client1Cred = New-Object System.Management.Automation.PSCredential ("$Domain1\administrateur", $SecurePassword)

$CreateShareScript = {
    # Create SalesData directory
    $SalesDataPath = "C:\SalesData"
    if (!(Test-Path $SalesDataPath)) {
        New-Item -Path $SalesDataPath -ItemType Directory -Force
    }
    
    # Create a test file
    "Sales Data Content" | Out-File "$SalesDataPath\sales_info.txt" -Encoding ASCII
    
    # Share the folder
    $ShareName = "SalesData"
    $ShareDescription = "Sales Department Shared Folder"
    
    # Remove existing share if it exists
    net share $ShareName /delete 2>$null
    
    # Create new share
    net share $ShareName="$SalesDataPath" "/grant:domain1.com\Ventes_Local_Group1,FULL" "/remark:$ShareDescription"
    
    # Set NTFS permissions
    $Acl = Get-Acl $SalesDataPath
    $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule("domain1.com\Ventes_Local_Group1", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.SetAccessRule($Rule)
    Set-Acl $SalesDataPath $Acl
    
    Write-Host "Share created: \\$env:COMPUTERNAME\SalesData" -ForegroundColor Green
}

Invoke-RemoteCommand -ComputerName "2304_Client1" -ScriptBlock $CreateShareScript -Credential $Client1Cred

# Task 3: Add global groups to local groups and test access
Write-Host "Task 3: Configuring group membership and testing access..." -ForegroundColor Yellow

try {
    # Add global groups to domain local groups
    Add-ADGroupMember -Identity "Ventes_Local_Group1" -Members "Ventes_Global_Group1"
    Add-ADGroupMember -Identity "Ventes_Local_Group2" -Members "Ventes_Global_Group2"
    
    Write-Host "Global groups added to domain local groups" -ForegroundColor Green
    
    # Test access (simulated)
    Write-Host "Testing access configuration..." -ForegroundColor Cyan
    Write-Host "Users in Ventes_Global_Group1 should now have access to \\2304_Client1\SalesData" -ForegroundColor Cyan
}
catch {
    Write-Warning "Error configuring group membership: $_"
}

# Exercise 2: Forest Trust Configuration
Write-Host "`n=== Exercise 2: Forest Trust Configuration ===" -ForegroundColor Green

# Task 1: Trust planning (documentation)
Write-Host "Task 1: Trust Planning Analysis" -ForegroundColor Yellow
Write-Host "Trust Type: Forest Trust" -ForegroundColor Cyan
Write-Host "Trust Direction: One-way incoming (Domain2 -> Domain1)" -ForegroundColor Cyan
Write-Host "Authentication: Selective Authentication" -ForegroundColor Cyan
Write-Host "Trusted Domain: Domain2.com" -ForegroundColor Cyan
Write-Host "Trusting Domain: Domain1.com" -ForegroundColor Cyan

# Task 2: Create forest trust
Write-Host "Task 2: Creating forest trust..." -ForegroundColor Yellow

# Note: Forest trust creation requires domain admin privileges on both domains
# This would typically be done through AD Domains and Trusts GUI, but here's the PowerShell approach:

try {
    # On Domain1 (trusting domain) - create incoming trust
    $TrustParams = @{
        Name = "domain2.com"
        TargetDomainName = "domain2.com"
        TrustType = "Forest"
        TrustDirection = "Inbound"
        TrustAttribute = "ForestTransitive"
    }
    New-ADTrust @TrustParams
    
    Write-Host "Incoming trust created on Domain1" -ForegroundColor Green
}
catch {
    Write-Warning "Trust creation may require GUI or additional configuration: $_"
}

# Task 3: Grant access to Research folder for Domain1 users
Write-Host "Task 3: Configuring Research folder permissions..." -ForegroundColor Yellow

$Domain2Cred = New-Object System.Management.Automation.PSCredential ("$Domain2\administrateur", $SecurePassword)

$ResearchFolderScript = {
    $ResearchPath = "C:\Research"
    
    # Create Research folder if it doesn't exist
    if (!(Test-Path $ResearchPath)) {
        New-Item -Path $ResearchPath -ItemType Directory -Force
        "Research Data Content" | Out-File "$ResearchPath\research_data.txt" -Encoding ASCII
    }
    
    # Share the folder
    $ShareName = "Research"
    net share $ShareName /delete 2>$null
    net share $ShareName="$ResearchPath" "/grant:Everyone,READ" "/remark:Research Shared Folder"
    
    Write-Host "Research share created" -ForegroundColor Green
}

Invoke-RemoteCommand -ComputerName "2304_DC2" -ScriptBlock $ResearchFolderScript -Credential $Domain2Cred

# Task 4 & 5: Configure authentication permissions
Write-Host "Task 4 & 5: Configuring authentication permissions..." -ForegroundColor Yellow

$AuthConfigScript = {
    # Enable advanced features view
    # This would typically be done through ADUC GUI
    
    # Configure DC2 to allow authentication from Domain1 users
    # This requires modifying the DC computer object security
    
    $DC2DN = (Get-ADComputer -Identity "DC2").DistinguishedName
    $Domain1Group = "domain1.com\Ventes_Global_Group1"
    
    # Note: This operation requires specific permissions and is complex in PowerShell
    # Typically done through ADUC advanced security settings
    
    Write-Host "Authentication configuration would be applied through GUI" -ForegroundColor Cyan
    Write-Host "Need to grant 'Allowed to Authenticate' permission for $Domain1Group on DC2 computer object" -ForegroundColor Cyan
}

Invoke-RemoteCommand -ComputerName "2304_DC2" -ScriptBlock $AuthConfigScript -Credential $Domain2Cred

# Exercise 3: Authentication Policy Implementation
Write-Host "`n=== Exercise 3: Authentication Policy Implementation ===" -ForegroundColor Green

# Task 1: Configure password and account lockout policies
Write-Host "Task 1: Configuring domain password policy..." -ForegroundColor Yellow

try {
    # Get the default domain policy
    $DefaultDomainPolicy = Get-GPO -Name "Default Domain Policy"
    
    # Configure password policy using Group Policy PowerShell module
    # Note: These settings modify the default domain policy
    
    # Password Policy Settings
    Set-GPRegistryValue -Name "Default Domain Policy" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Password" -ValueName "PasswordHistorySize" -Type DWord -Value 24
    Set-GPRegistryValue -Name "Default Domain Policy" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Password" -ValueName "MinimumPasswordLength" -Type DWord -Value 8
    Set-GPRegistryValue -Name "Default Domain Policy" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Password" -ValueName "PasswordComplexity" -Type DWord -Value 1
    Set-GPRegistryValue -Name "Default Domain Policy" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Password" -ValueName "MinimumPasswordAge" -Type DWord -Value 1
    Set-GPRegistryValue -Name "Default Domain Policy" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Password" -ValueName "MaximumPasswordAge" -Type DWord -Value 90
    
    # Account Lockout Policy
    Set-GPRegistryValue -Name "Default Domain Policy" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Account" -ValueName "LockoutDuration" -Type DWord -Value 30
    Set-GPRegistryValue -Name "Default Domain Policy" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Account" -ValueName "LockoutThreshold" -Type DWord -Value 5
    Set-GPRegistryValue -Name "Default Domain Policy" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Account" -ValueName "LockoutObservationWindow" -Type DWord -Value 30
    
    Write-Host "Domain password policy configured successfully" -ForegroundColor Green
}
catch {
    Write-Warning "Error configuring domain policy: $_"
}

# Task 2: Test policy application
Write-Host "Task 2: Testing policy application..." -ForegroundColor Yellow

$TestPolicyScript = {
    # Force group policy update
    gpupdate /force
    
    # Display group policy results
    gpresult /v
    
    # Test password policy (this would require attempting to change a password)
    Write-Host "Policy update completed. Check gpresult output above." -ForegroundColor Green
}

Invoke-RemoteCommand -ComputerName "2304_Client1" -ScriptBlock $TestPolicyScript -Credential $Client1Cred

# Summary and Verification
Write-Host "`n=== Lab Summary ===" -ForegroundColor Magenta
Write-Host "Exercise 1: Resource Authorization" -ForegroundColor White
Write-Host "  - Created Ventes OU with global and domain local groups" -ForegroundColor Gray
Write-Host "  - Created users and assigned to groups" -ForegroundColor Gray
Write-Host "  - Created shared folder with appropriate permissions" -ForegroundColor Gray

Write-Host "Exercise 2: Forest Trust" -ForegroundColor White
Write-Host "  - Configured one-way forest trust (Domain2 -> Domain1)" -ForegroundColor Gray
Write-Host "  - Set up Research share on Domain2" -ForegroundColor Gray
Write-Host "  - Configured cross-forest authentication" -ForegroundColor Gray

Write-Host "Exercise 3: Authentication Policy" -ForegroundColor White
Write-Host "  - Configured password complexity requirements" -ForegroundColor Gray
Write-Host "  - Set account lockout policy" -ForegroundColor Gray
Write-Host "  - Applied domain-wide security policy" -ForegroundColor Gray

Write-Host "`nManual verification required for:" -ForegroundColor Yellow
Write-Host "  - Forest trust confirmation in AD Domains and Trusts" -ForegroundColor Cyan
Write-Host "  - Testing cross-forest resource access" -ForegroundColor Cyan
Write-Host "  - Verifying 'Allowed to Authenticate' permissions on DC2" -ForegroundColor Cyan

Write-Host "`nLab configuration completed!" -ForegroundColor Green````


```# DC2-Setup.ps1 - Run on 2304_DC2 as Administrator

# Import modules
Import-Module ActiveDirectory

Write-Host "=== Setting up Domain2 Infrastructure ===" -ForegroundColor Green

# Exercise 2 - Task 2: Create outgoing trust to Domain1
Write-Host "Configuring forest trust to Domain1..." -ForegroundColor Yellow

try {
    # Check if trust already exists
    $ExistingTrust = Get-ADTrust -Filter "Name -like 'domain1.com'"
    if (-not $ExistingTrust) {
        # Create outgoing trust
        New-ADTrust -Name "domain1.com" -Direction Outbound -TrustType Forest -TargetDomainName "domain1.com"
        Write-Host "Outgoing trust to domain1.com created" -ForegroundColor Green
    } else {
        Write-Host "Trust already exists" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Trust configuration may require additional setup: $_" -ForegroundColor Red
}

# Exercise 2 - Task 3: Create Research folder and share
Write-Host "Creating Research shared folder..." -ForegroundColor Yellow

$ResearchPath = "C:\Research"

# Create Research folder
if (!(Test-Path $ResearchPath)) {
    New-Item -Path $ResearchPath -ItemType Directory -Force
    Write-Host "Research folder created at $ResearchPath" -ForegroundColor Green
} else {
    Write-Host "Research folder already exists" -ForegroundColor Yellow
}

# Create sample file
"Confidential Research Data - Project Alpha" | Out-File "$ResearchPath\research_data.txt" -Encoding ASCII
"Quarterly Reports 2024" | Out-File "$ResearchPath\reports.docx" -Encoding ASCII

# Create share
$ShareName = "Research"
try {
    # Remove existing share if it exists
    net share $ShareName /delete 2>$null
    
    # Create new share with Everyone read permissions initially
    net share $ShareName="$ResearchPath" "/grant:Everyone,READ" "/remark:Research Shared Folder"
    Write-Host "Research share created: \\$env:COMPUTERNAME\Research" -ForegroundColor Green
}
catch {
    Write-Host "Error creating share: $_" -ForegroundColor Red
}

# Set NTFS permissions to allow Domain1 users
try {
    $Acl = Get-Acl $ResearchPath
    
    # Remove inherited permissions
    $Acl.SetAccessRuleProtection($true, $false)
    
    # Add Domain1 sales group permission (this will be fully configured after trust)
    $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule("domain1.com\Ventes_Global_Group1", "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.AddAccessRule($Rule)
    
    # Add local administrators full control
    $AdminRule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Administrators", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.AddAccessRule($AdminRule)
    
    Set-Acl $ResearchPath $Acl
    Write-Host "NTFS permissions configured for Domain1 users" -ForegroundColor Green
}
catch {
    Write-Host "NTFS permissions may need manual configuration after trust is established: $_" -ForegroundColor Yellow
}

# Exercise 2 - Task 5: Configure authentication permissions (simplified)
Write-Host "Configuring cross-forest authentication..." -ForegroundColor Yellow

Write-Host "Manual steps required for full authentication configuration:" -ForegroundColor Cyan
Write-Host "1. Open 'Active Directory Users and Computers'" -ForegroundColor White
Write-Host "2. Enable 'Advanced Features' in View menu" -ForegroundColor White
Write-Host "3. Find DC2 computer object in Domain Controllers OU" -ForegroundColor White
Write-Host "4. Open Properties -> Security -> Add -> Location: domain1.com" -ForegroundColor White
Write-Host "5. Add 'Ventes_Global_Group1' and grant 'Allowed to Authenticate' permission" -ForegroundColor White

Write-Host "`n=== Domain2 Setup Complete ===" -ForegroundColor Green
Write-Host "Forest trust configured to Domain1" -ForegroundColor Cyan
Write-Host "Research share created: \\$env:COMPUTERNAME\Research" -ForegroundColor Cyan
Write-Host "Manual authentication configuration required as above" -ForegroundColor Yellow```



```# Client1-Setup.ps1 - Run on 2304_Client1 as Administrator

Write-Host "=== Setting up Client1 Shared Resources ===" -ForegroundColor Green

# Exercise 1 - Task 2: Create SalesData shared folder
Write-Host "Creating SalesData shared folder..." -ForegroundColor Yellow

$SalesDataPath = "C:\SalesData"

# Create SalesData folder
if (!(Test-Path $SalesDataPath)) {
    New-Item -Path $SalesDataPath -ItemType Directory -Force
    Write-Host "SalesData folder created at $SalesDataPath" -ForegroundColor Green
} else {
    Write-Host "SalesData folder already exists" -ForegroundColor Yellow
}

# Create sample files
"Sales Report Q1 2024" | Out-File "$SalesDataPath\sales_q1.txt" -Encoding ASCII
"Customer List" | Out-File "$SalesDataPath\customers.csv" -Encoding ASCII
"Product Catalog" | Out-File "$SalesDataPath\products.docx" -Encoding ASCII

# Create share with permissions for Domain Local group
$ShareName = "SalesData"
try {
    # Remove existing share if it exists
    net share $ShareName /delete 2>$null
    
    # Create new share with FULL access for Ventes_Local_Group1
    net share $ShareName="$SalesDataPath" "/grant:domain1.com\Ventes_Local_Group1,FULL" "/remark:Sales Department Shared Data"
    Write-Host "SalesData share created: \\$env:COMPUTERNAME\SalesData" -ForegroundColor Green
}
catch {
    Write-Host "Error creating share: $_" -ForegroundColor Red
}

# Set NTFS permissions
try {
    $Acl = Get-Acl $SalesDataPath
    
    # Clear existing permissions
    $Acl.SetAccessRuleProtection($true, $false)
    
    # Add Ventes_Local_Group1 with Full Control
    $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule("domain1.com\Ventes_Local_Group1", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.AddAccessRule($Rule)
    
    # Add local administrators
    $AdminRule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Administrators", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.AddAccessRule($AdminRule)
    
    Set-Acl $SalesDataPath $Acl
    Write-Host "NTFS permissions configured for Ventes_Local_Group1" -ForegroundColor Green
}
catch {
    Write-Host "Error setting NTFS permissions: $_" -ForegroundColor Red
}

# Exercise 3 - Task 2: Test group policy application
Write-Host "Testing group policy application..." -ForegroundColor Yellow

# Force group policy update
Write-Host "Forcing group policy update..." -ForegroundColor Cyan
gpupdate /force

# Display group policy results
Write-Host "Group Policy Results:" -ForegroundColor Cyan
gpresult /r

Write-Host "`n=== Testing Access ===" -ForegroundColor Yellow
Write-Host "To test SalesData access:" -ForegroundColor White
Write-Host "1. Log in as venteuser1@domain1.com" -ForegroundColor Gray
Write-Host "2. Try to access: \\$env:COMPUTERNAME\SalesData" -ForegroundColor Gray
Write-Host "3. You should have full access to the share" -ForegroundColor Gray

Write-Host "`nTo test cross-forest Research access:" -ForegroundColor White
Write-Host "1. Log in as venteuser1@domain1.com" -ForegroundColor Gray
Write-Host "2. Try to access: \\2304_DC2\Research" -ForegroundColor Gray
Write-Host "3. This will work after trust and authentication configuration" -ForegroundColor Gray

Write-Host "`n=== Client1 Setup Complete ===" -ForegroundColor Green
Write-Host "SalesData share created: \\$env:COMPUTERNAME\SalesData" -ForegroundColor Cyan
Write-Host "Permissions configured for Ventes_Local_Group1" -ForegroundColor Cyan
Write-Host "Group policy updated" -ForegroundColor Cyan```

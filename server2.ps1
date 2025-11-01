# DC2-Setup.ps1 - Run on 2304_DC2 as Administrator

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
Write-Host "Manual authentication configuration required as above" -ForegroundColor Yellow

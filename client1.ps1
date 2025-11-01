# Client1-Setup.ps1 - Run on 2304_Client1 as Administrator

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
Write-Host "Group policy updated" -ForegroundColor Cyan

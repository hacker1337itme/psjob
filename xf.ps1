Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Main Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "User and Computer Management"
$form.Size = New-Object System.Drawing.Size(800, 600)
$form.StartPosition = "CenterScreen"
$form.MaximizeBox = $false
$form.FormBorderStyle = "FixedDialog"

# Tab Control
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Location = New-Object System.Drawing.Point(10, 10)
$tabControl.Size = New-Object System.Drawing.Size(760, 520)
$form.Controls.Add($tabControl)

# Tab 1: Add User
$tabPage1 = New-Object System.Windows.Forms.TabPage
$tabPage1.Text = "Add User"
$tabControl.Controls.Add($tabPage1)

# Add User Controls
$lblUsername = New-Object System.Windows.Forms.Label
$lblUsername.Location = New-Object System.Drawing.Point(20, 20)
$lblUsername.Size = New-Object System.Drawing.Size(100, 20)
$lblUsername.Text = "Username:"
$tabPage1.Controls.Add($lblUsername)

$txtUsername = New-Object System.Windows.Forms.TextBox
$txtUsername.Location = New-Object System.Drawing.Point(120, 20)
$txtUsername.Size = New-Object System.Drawing.Size(200, 20)
$tabPage1.Controls.Add($txtUsername)

$lblPassword = New-Object System.Windows.Forms.Label
$lblPassword.Location = New-Object System.Drawing.Point(20, 50)
$lblPassword.Size = New-Object System.Drawing.Size(100, 20)
$lblPassword.Text = "Password:"
$tabPage1.Controls.Add($lblPassword)

$txtPassword = New-Object System.Windows.Forms.TextBox
$txtPassword.Location = New-Object System.Drawing.Point(120, 50)
$txtPassword.Size = New-Object System.Drawing.Size(200, 20)
$txtPassword.PasswordChar = '*'
$tabPage1.Controls.Add($txtPassword)

$lblFullName = New-Object System.Windows.Forms.Label
$lblFullName.Location = New-Object System.Drawing.Point(20, 80)
$lblFullName.Size = New-Object System.Drawing.Size(100, 20)
$lblFullName.Text = "Full Name:"
$tabPage1.Controls.Add($lblFullName)

$txtFullName = New-Object System.Windows.Forms.TextBox
$txtFullName.Location = New-Object System.Drawing.Point(120, 80)
$txtFullName.Size = New-Object System.Drawing.Size(200, 20)
$tabPage1.Controls.Add($txtFullName)

$lblDescription = New-Object System.Windows.Forms.Label
$lblDescription.Location = New-Object System.Drawing.Point(20, 110)
$lblDescription.Size = New-Object System.Drawing.Size(100, 20)
$lblDescription.Text = "Description:"
$tabPage1.Controls.Add($lblDescription)

$txtDescription = New-Object System.Windows.Forms.TextBox
$txtDescription.Location = New-Object System.Drawing.Point(120, 110)
$txtDescription.Size = New-Object System.Drawing.Size(200, 20)
$tabPage1.Controls.Add($txtDescription)

$lblInfo = New-Object System.Windows.Forms.Label
$lblInfo.Location = New-Object System.Drawing.Point(20, 140)
$lblInfo.Size = New-Object System.Drawing.Size(100, 20)
$lblInfo.Text = "User Info:"
$tabPage1.Controls.Add($lblInfo)

$txtInfo = New-Object System.Windows.Forms.TextBox
$txtInfo.Location = New-Object System.Drawing.Point(120, 140)
$txtInfo.Size = New-Object System.Drawing.Size(200, 60)
$txtInfo.Multiline = $true
$tabPage1.Controls.Add($txtInfo)

$btnAddUser = New-Object System.Windows.Forms.Button
$btnAddUser.Location = New-Object System.Drawing.Point(120, 220)
$btnAddUser.Size = New-Object System.Drawing.Size(100, 30)
$btnAddUser.Text = "Add User"
$btnAddUser.Add_Click({
    AddUser
})
$tabPage1.Controls.Add($btnAddUser)

$lblAddUserStatus = New-Object System.Windows.Forms.Label
$lblAddUserStatus.Location = New-Object System.Drawing.Point(20, 260)
$lblAddUserStatus.Size = New-Object System.Drawing.Size(300, 50)
$lblAddUserStatus.Text = ""
$tabPage1.Controls.Add($lblAddUserStatus)

# Tab 2: Change Password
$tabPage2 = New-Object System.Windows.Forms.TabPage
$tabPage2.Text = "Change Password"
$tabControl.Controls.Add($tabPage2)

# Change Password Controls
$lblChangeUser = New-Object System.Windows.Forms.Label
$lblChangeUser.Location = New-Object System.Drawing.Point(20, 20)
$lblChangeUser.Size = New-Object System.Drawing.Size(100, 20)
$lblChangeUser.Text = "Username:"
$tabPage2.Controls.Add($lblChangeUser)

$txtChangeUser = New-Object System.Windows.Forms.TextBox
$txtChangeUser.Location = New-Object System.Drawing.Point(120, 20)
$txtChangeUser.Size = New-Object System.Drawing.Size(200, 20)
$tabPage2.Controls.Add($txtChangeUser)

$lblNewPassword = New-Object System.Windows.Forms.Label
$lblNewPassword.Location = New-Object System.Drawing.Point(20, 50)
$lblNewPassword.Size = New-Object System.Drawing.Size(100, 20)
$lblNewPassword.Text = "New Password:"
$tabPage2.Controls.Add($lblNewPassword)

$txtNewPassword = New-Object System.Windows.Forms.TextBox
$txtNewPassword.Location = New-Object System.Drawing.Point(120, 50)
$txtNewPassword.Size = New-Object System.Drawing.Size(200, 20)
$txtNewPassword.PasswordChar = '*'
$tabPage2.Controls.Add($txtNewPassword)

$btnChangePassword = New-Object System.Windows.Forms.Button
$btnChangePassword.Location = New-Object System.Drawing.Point(120, 80)
$btnChangePassword.Size = New-Object System.Drawing.Size(120, 30)
$btnChangePassword.Text = "Change Password"
$btnChangePassword.Add_Click({
    ChangePassword
})
$tabPage2.Controls.Add($btnChangePassword)

$lblChangePasswordStatus = New-Object System.Windows.Forms.Label
$lblChangePasswordStatus.Location = New-Object System.Drawing.Point(20, 120)
$lblChangePasswordStatus.Size = New-Object System.Drawing.Size(300, 50)
$lblChangePasswordStatus.Text = ""
$tabPage2.Controls.Add($lblChangePasswordStatus)

# Tab 3: Rename Computer
$tabPage3 = New-Object System.Windows.Forms.TabPage
$tabPage3.Text = "Rename Computer"
$tabControl.Controls.Add($tabPage3)

# Rename Computer Controls
$lblCurrentPCName = New-Object System.Windows.Forms.Label
$lblCurrentPCName.Location = New-Object System.Drawing.Point(20, 20)
$lblCurrentPCName.Size = New-Object System.Drawing.Size(300, 20)
$lblCurrentPCName.Text = "Current Computer Name: $env:COMPUTERNAME"
$tabPage3.Controls.Add($lblCurrentPCName)

$lblNewPCName = New-Object System.Windows.Forms.Label
$lblNewPCName.Location = New-Object System.Drawing.Point(20, 50)
$lblNewPCName.Size = New-Object System.Drawing.Size(100, 20)
$lblNewPCName.Text = "New Name:"
$tabPage3.Controls.Add($lblNewPCName)

$txtNewPCName = New-Object System.Windows.Forms.TextBox
$txtNewPCName.Location = New-Object System.Drawing.Point(120, 50)
$txtNewPCName.Size = New-Object System.Drawing.Size(200, 20)
$tabPage3.Controls.Add($txtNewPCName)

$btnRenamePC = New-Object System.Windows.Forms.Button
$btnRenamePC.Location = New-Object System.Drawing.Point(120, 80)
$btnRenamePC.Size = New-Object System.Drawing.Size(100, 30)
$btnRenamePC.Text = "Rename PC"
$btnRenamePC.Add_Click({
    RenameComputer
})
$tabPage3.Controls.Add($btnRenamePC)

$lblRenameStatus = New-Object System.Windows.Forms.Label
$lblRenameStatus.Location = New-Object System.Drawing.Point(20, 120)
$lblRenameStatus.Size = New-Object System.Drawing.Size(300, 50)
$lblRenameStatus.Text = ""
$tabPage3.Controls.Add($lblRenameStatus)

# Tab 4: List Users
$tabPage4 = New-Object System.Windows.Forms.TabPage
$tabPage4.Text = "List Users"
$tabControl.Controls.Add($tabPage4)

# List Users Controls
$btnRefreshUsers = New-Object System.Windows.Forms.Button
$btnRefreshUsers.Location = New-Object System.Drawing.Point(20, 20)
$btnRefreshUsers.Size = New-Object System.Drawing.Size(100, 30)
$btnRefreshUsers.Text = "Refresh List"
$btnRefreshUsers.Add_Click({
    ListUsers
})
$tabPage4.Controls.Add($btnRefreshUsers)

$listViewUsers = New-Object System.Windows.Forms.ListView
$listViewUsers.Location = New-Object System.Drawing.Point(20, 60)
$listViewUsers.Size = New-Object System.Drawing.Size(700, 350)
$listViewUsers.View = [System.Windows.Forms.View]::Details
$listViewUsers.FullRowSelect = $true
$listViewUsers.GridLines = $true

# Add columns
$listViewUsers.Columns.Add("Username", 100)
$listViewUsers.Columns.Add("Full Name", 150)
$listViewUsers.Columns.Add("Description", 200)
$listViewUsers.Columns.Add("Enabled", 80)
$listViewUsers.Columns.Add("Last Logon", 150)
$tabPage4.Controls.Add($listViewUsers)

# Status Label for all tabs
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Location = New-Object System.Drawing.Point(10, 540)
$lblStatus.Size = New-Object System.Drawing.Size(760, 20)
$lblStatus.Text = "Ready"
$form.Controls.Add($lblStatus)

# Functions
function AddUser {
    $username = $txtUsername.Text
    $password = $txtPassword.Text
    $fullName = $txtFullName.Text
    $description = $txtDescription.Text
    $info = $txtInfo.Text

    if ([string]::IsNullOrWhiteSpace($username) -or [string]::IsNullOrWhiteSpace($password)) {
        $lblAddUserStatus.Text = "Username and password are required!"
        $lblAddUserStatus.ForeColor = "Red"
        return
    }

    try {
        # Check if user already exists
        if (Get-LocalUser -Name $username -ErrorAction SilentlyContinue) {
            $lblAddUserStatus.Text = "User '$username' already exists!"
            $lblAddUserStatus.ForeColor = "Red"
            return
        }

        # Create secure password
        $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force

        # Create user
        $userParams = @{
            Name = $username
            Password = $securePassword
            FullName = $fullName
            Description = $description
        }

        New-LocalUser @userParams

        # Set additional info if provided
        if (-not [string]::IsNullOrWhiteSpace($info)) {
            # You can extend this to set additional user properties
            Set-LocalUser -Name $username -Description "$description - $info"
        }

        $lblAddUserStatus.Text = "User '$username' created successfully!"
        $lblAddUserStatus.ForeColor = "Green"
        
        # Clear fields
        $txtUsername.Text = ""
        $txtPassword.Text = ""
        $txtFullName.Text = ""
        $txtDescription.Text = ""
        $txtInfo.Text = ""

        $lblStatus.Text = "User added successfully: $username"
    }
    catch {
        $lblAddUserStatus.Text = "Error creating user: $($_.Exception.Message)"
        $lblAddUserStatus.ForeColor = "Red"
        $lblStatus.Text = "Error: $($_.Exception.Message)"
    }
}

function ChangePassword {
    $username = $txtChangeUser.Text
    $newPassword = $txtNewPassword.Text

    if ([string]::IsNullOrWhiteSpace($username) -or [string]::IsNullOrWhiteSpace($newPassword)) {
        $lblChangePasswordStatus.Text = "Username and new password are required!"
        $lblChangePasswordStatus.ForeColor = "Red"
        return
    }

    try {
        # Check if user exists
        $user = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
        if (-not $user) {
            $lblChangePasswordStatus.Text = "User '$username' not found!"
            $lblChangePasswordStatus.ForeColor = "Red"
            return
        }

        # Create secure password
        $securePassword = ConvertTo-SecureString -String $newPassword -AsPlainText -Force

        # Change password
        Set-LocalUser -Name $username -Password $securePassword

        $lblChangePasswordStatus.Text = "Password changed successfully for user '$username'!"
        $lblChangePasswordStatus.ForeColor = "Green"
        
        # Clear fields
        $txtChangeUser.Text = ""
        $txtNewPassword.Text = ""

        $lblStatus.Text = "Password changed for user: $username"
    }
    catch {
        $lblChangePasswordStatus.Text = "Error changing password: $($_.Exception.Message)"
        $lblChangePasswordStatus.ForeColor = "Red"
        $lblStatus.Text = "Error: $($_.Exception.Message)"
    }
}

function RenameComputer {
    $newName = $txtNewPCName.Text

    if ([string]::IsNullOrWhiteSpace($newName)) {
        $lblRenameStatus.Text = "New computer name is required!"
        $lblRenameStatus.ForeColor = "Red"
        return
    }

    try {
        # Check if running as administrator
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        
        if (-not $isAdmin) {
            $lblRenameStatus.Text = "Administrator rights required to rename computer!"
            $lblRenameStatus.ForeColor = "Red"
            return
        }

        # Rename computer
        Rename-Computer -NewName $newName -Force

        $lblRenameStatus.Text = "Computer will be renamed to '$newName' after restart. Please restart the computer."
        $lblRenameStatus.ForeColor = "Green"
        $lblCurrentPCName.Text = "Current Computer Name: $env:COMPUTERNAME (Will change to: $newName after restart)"

        $lblStatus.Text = "Computer rename scheduled. Restart required."
    }
    catch {
        $lblRenameStatus.Text = "Error renaming computer: $($_.Exception.Message)"
        $lblRenameStatus.ForeColor = "Red"
        $lblStatus.Text = "Error: $($_.Exception.Message)"
    }
}

function ListUsers {
    try {
        $listViewUsers.Items.Clear()
        
        $users = Get-LocalUser | Sort-Object Name
        
        foreach ($user in $users) {
            $lastLogon = if ($user.LastLogon) { 
                [DateTime]::FromFileTime($user.LastLogon).ToString("yyyy-MM-dd HH:mm:ss") 
            } else { 
                "Never" 
            }
            
            $item = New-Object System.Windows.Forms.ListViewItem($user.Name)
            $item.SubItems.Add($user.FullName) | Out-Null
            $item.SubItems.Add($user.Description) | Out-Null
            $item.SubItems.Add($user.Enabled.ToString()) | Out-Null
            $item.SubItems.Add($lastLogon) | Out-Null
            
            $listViewUsers.Items.Add($item) | Out-Null
        }
        
        $lblStatus.Text = "User list refreshed. Total users: $($users.Count)"
    }
    catch {
        $lblStatus.Text = "Error loading user list: $($_.Exception.Message)"
    }
}

# Load initial user list
ListUsers

# Show the form
$form.ShowDialog() | Out-Null

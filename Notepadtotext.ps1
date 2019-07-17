################################################################################ 
#
#  Name    : Clipboard to text file 
#
################################################################################

# Setting up files

if ( ! $PSISE ) {
    # Hide this window if not ran using PS ISE
    $t = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
    add-type -name win -member $t -namespace native
    [native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)
	
}




$Date = get-date -format "yyyy-MM-dd"

$script:Testfile = Test-Path -Path "$($env:USERPROFILE)\Desktop\Clipbaords\Clipboard-$Date.txt"
$Script:Textfile = "$($env:USERPROFILE)\Desktop\Clipboard-$Date.txt"
$script:BaseClipboard = $script:BaseClipboardcheck
$Script:Time = Get-Date -format "HH:mm"
#Images

$Script:ImageFoldertest = Test-Path -Path "$($env:USERPROFILE)\Desktop\Clipbaords\Images"
$Script:ImageFolder = "$($env:USERPROFILE)\Desktop\Clipbaords\Images"



if (!$Testfile) {
    New-Item  -ItemType File -Path "$($env:USERPROFILE)\Desktop\Clipbaords" -Force -Name "Clipboard-$Date.txt"
}

# Loading external assemblies

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing



# Functions
function Save_Box {
    $Script:Time + "`r`n" + $script:BaseClipboard + "`r`n" | Out-File -FilePath $script:Textfile -Append
}

function Timer_Tick {
    
            $script:BaseClipboardcheck  = [System.Windows.Forms.Clipboard]::GetDataObject()
    if ($script:BaseClipboardcheck.ContainsImage()) {
        Save_Image -Isimage $script:BaseClipboardcheck
        Set-Clipboard -Value $script:BaseClipboard
    }
   
    else {
        $script:BaseClipboardcheck = ("$( Get-Clipboard -Raw )").ToString()
        if ( $script:BaseClipboard -ne $script:BaseClipboardcheck ) { 
            Clipboard_Output 
            Save_Box
        }
    }
}

function Clipboard_Output {
    $script:BaseClipboard = $script:BaseClipboardcheck
    $OutputRichTextBox.Text += "---------------------------------------" 
    $OutputRichTextBox.Text += "`r`n"
    $OutputRichTextBox.Text += "$($Script:Time)" + "`r`n"
    $OutputRichTextBox.Text += "`r`n"	
    $OutputRichTextBox.Text += $script:BaseClipboard
    $OutputRichTextBox.Text += "`r`n"	
    $script:BaseClipboard = ("$( Get-Clipboard -Raw )").ToString()
}

function Save_Image {
    param (
        $Isimage
    )	
    if (!$Script:ImageFoldertest) {
        New-Item  -ItemType Directory -Path "$($env:USERPROFILE)\Desktop\Clipbaords" -Force -Name "Images"
    }
    $Script:Imgtime = "$((Get-Date).Hour)" + "$((Get-Date).Minute)" + "$((Get-Date).Second)"
    $filename = "$Script:ImageFolder\$Script:Imgtime.png"
    [System.Drawing.Bitmap]$Isimage.getimage().Save($filename, [System.Drawing.Imaging.ImageFormat]::Png)
		
    $OutputRichTextBox.Text += "---------------------------------------" 
    $OutputRichTextBox.Text += "`r`n"
    $OutputRichTextBox.Text += "$($Script:Time)" + "`r`n"
    $OutputRichTextBox.Text += "`r`n"	
    $OutputRichTextBox.Text += "Saved Image to $filename"
    $OutputRichTextBox.Text += "`r`n"	
	Return  
}






#region Form
# Clipboardtotext

$Clipboardtotext = New-Object System.Windows.Forms.Form
$Clipboardtotext.ClientSize = New-Object System.Drawing.Size(338, 557)
$Clipboardtotext.Name = "Clipboardtotext"
$Clipboardtotext.Text = "Clipboard to text file"

# OutputRichTextBox

$OutputRichTextBox = New-Object System.Windows.Forms.RichTextBox
$OutputRichTextBox.Anchor = [System.Windows.Forms.AnchorStyles]"Top,Bottom,Left,Right"
$OutputRichTextBox.Location = New-Object System.Drawing.Point(12, 57)
$OutputRichTextBox.Name = "OutputRichTextBox"
$OutputRichTextBox.Size = New-Object System.Drawing.Size(314, 488)
$OutputRichTextBox.TabIndex = 0
$OutputRichTextBox.Text = "A .txt file on your desktop called \Clipbaords\$($Date).txt .`r `nClick 'Start Check' to start monitoring your clipboard."

# StartClipboard

$StartClipboard = New-Object System.Windows.Forms.Button
$StartClipboard.Location = New-Object System.Drawing.Point(12, 12)
$StartClipboard.Name = "StartClipboard"
$StartClipboard.Size = New-Object System.Drawing.Size(123, 39)
$StartClipboard.TabIndex = 1
$StartClipboard.Text = "Start Check"
$StartClipboard.UseVisualStyleBackColor = $true
$StartClipboard.ADD_Click( {

        $OutputRichTextBox.Text = ""
        $StartClipboard.Enabled = $false	
        Timer_Start  
    })


$ToolTip = New-Object System.Windows.Forms.ToolTip
$ToolTip.SetToolTip( $StartClipboard , "Click to start monitoring your clipboard.")

# ExitButton

$ExitButton = New-Object System.Windows.Forms.Button
$ExitButton.Location = New-Object System.Drawing.Point(203, 12)
$ExitButton.Anchor = [System.Windows.Forms.AnchorStyles]"Top,Right"
$ExitButton.Name = "ExitButton"
$ExitButton.Size = New-Object System.Drawing.Size(123, 39)
$ExitButton.TabIndex = 1
$ExitButton.Text = "Save and Exit"
$ExitButton.UseVisualStyleBackColor = $true
$ExitButton.ADD_Click( { OnFormClosing_Clipboardtotext })
$ToolTip.SetToolTip($ExitButton , "Save to txt and close.")
function Timer_Start {
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 1000     # fire every 2s
    $timer.add_tick( { Timer_Tick })
    $timer.start()
}


$Clipboardtotext.Controls.AddRange(@($OutputRichTextBox, $StartClipboard, $ExitButton))

#endregion


function OnFormClosing_Clipboardtotext { 
    Save_Box
    $Clipboardtotext.Dispose()
}

$Clipboardtotext.ShowDialog()



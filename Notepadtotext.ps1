################################################################################ 
#
#  Name    : Clipboard to text file 
#
################################################################################

# Setting up files
$Date = get-date -format "yyyy-MM"

$script:Testfile = Test-Path -Path "$($env:USERPROFILE)\Desktop\Clipboard-$Date.txt"
$Script:Textfile = "$($env:USERPROFILE)\Desktop\Clipboard-$Date.txt"
$script:Clipboard = ""

if (!$Testfile){
	New-Item  -ItemType File -Path "$($env:USERPROFILE)\Desktop\" -Force -Name "Clipboard-$Date.txt"
}

# Loading external assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Functions
function Save_Box {
	[System.String]$OutputRichTextBox.Text  | Out-File -FilePath $script:Textfile -Append
}

function Loop_Check {
	while($true){
#$KeyPress = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
$KeyPress = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
if (($Keypress.VirtualKeyCode -eq '67')){
	Clipboard_Check}
	}
}

function Clipboard_Check {
if ( $script:Clipboard -ne $script:Clipboardcheck ){ Clipboard_Output }
}


function Clipboard_Output {
		 $script:Clipboard  =  $script:Clipboardcheck
		 $OutputRichTextBox.Text += $script:Clipboard
		 $OutputRichTextBox.Text += "`r" + "`n"
		 $OutputRichTextBox.Text += "-------------"
		 $OutputRichTextBox.Text += "`r" + "`n"	
		 $script:Clipboardcheck = ("$( Get-Clipboard -Raw )").ToString()

}

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
$OutputRichTextBox.Text = ""

# SaveAs

$SaveAs = New-Object System.Windows.Forms.Button
$SaveAs.Location = New-Object System.Drawing.Point(12, 12)
$SaveAs.Name = "SaveAs"
$SaveAs.Size = New-Object System.Drawing.Size(123, 39)
$SaveAs.TabIndex = 1
$SaveAs.Text = "Save As"
$SaveAs.UseVisualStyleBackColor = $true
$SaveAs.ADD_Click({ Save_Box })

# ExitButton

$ExitButton = New-Object System.Windows.Forms.Button
$ExitButton.Location = New-Object System.Drawing.Point(203, 12)
$ExitButton.Anchor = [System.Windows.Forms.AnchorStyles]"Top,Right"
$ExitButton.Name = "ExitButton"
$ExitButton.Size = New-Object System.Drawing.Size(123, 39)
$ExitButton.TabIndex = 1
$ExitButton.Text = "Save and Exit"
$ExitButton.UseVisualStyleBackColor = $true


$Clipboardtotext.Controls.AddRange(@($OutputRichTextBox,$SaveAs,$ExitButton))

function OnFormClosing_Clipboardtotext{ 
Save_Box
$Clipboardtotext.Dispose()
}

#$Clipboardtotext.Add_Shown({$Clipboardtotext.Activate()})

$Clipboardtotext.ShowDialog()

$Clipboardtotext.Add_FormClosing( { OnFormClosing_Clipboardtotext} )

## This script works by changing the `safe words` inside of sharedassets2.assets.
## It inserts your desired name as a safe word so Among Us accepts it

## This script was tested only on Among Us v2022.3.29e, other versions might break your game

$NAMES_FILE = "$PSScriptRoot\Among Us_Data\sharedassets2.assets"
$PREFS_FILE = "C:\Users\$env:UserName\AppData\LocalLow\Innersloth\Among Us\playerPrefs"
$ACCURATE_OFFSET = 0x0928B9
$NAME_MAX_LENGTH = 10
$NAME_MIN_LENGTH = 3
$TOTAL_NAME_AND_SPAM_LENGTH = 13

# Check if files exist
if (!(Test-Path -Path $NAMES_FILE -PathType Leaf) -or !(Test-Path -Path $PREFS_FILE -PathType Leaf)) {
	if (!(Test-Path -Path $NAMES_FILE -PathType Leaf)) {
		Write-Output "The file $NAMES_FILE does not exist."
	} else {
		Write-Output "The file $PREFS_FILE does not exist."
	}
	Write-Output "Check your Among Us installation or the location of this script."

	pause
	Exit
}

$name = Read-Host "Enter your desired name for Among Us"
# Check if name is between NAME_MIN_LENGTH and NAME_MAX_LENGTH
if ($name.Length -lt $NAME_MIN_LENGTH -or $name.Length -gt $NAME_MAX_LENGTH)
{
	Write-Error "Your name must be between $NAME_MIN_LENGTH and $NAME_MAX_LENGTH characters long."

	pause
	Exit
}

# Get all data from NAMES_FILE, contains the `safe words` we need to alter
$bytes = [System.IO.File]::ReadAllBytes($NAMES_FILE);

# Do some binary magic to insert a spam name with desired name
# From what I understand, Among Us compares the amount of words and their length,
# so we shorter one name but lengthen another to keep the amount of words and their length the same
$name_to_write = ("`r`n" + $name).PadLeft($TOTAL_NAME_AND_SPAM_LENGTH, "a")

# Write that spam and desired name to the actual game assets
for ($i = 0; $i -lt $name_to_write.Length; $i++)
{
	$bytes[$ACCURATE_OFFSET + $i] = $name_to_write[$i]
}
[System.IO.File]::WriteAllBytes($NAMES_FILE, $bytes)

# Change current name in playerPrefs to desired one
$prefs = Get-Content $PREFS_FILE
$prefs = $prefs.Split(",")
$prefs[0] = $name
$prefs = $prefs -join ","
Set-Content $PREFS_FILE $prefs

Write-Output "Your name is now: $name"
pause

# Enjoy :D
$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$FolderName = ""
$digit = "3"
$numofFolders = 10

$NamePattern = "{0:D${digit}}"

echo $NamePattern

for($i = 1; $i -le $numofFolders; $i++){
    $name = $NamePattern -f $i
    New-Item ${scriptDir}\${FolderName}${name}
}

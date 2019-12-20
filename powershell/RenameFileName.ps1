$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$FileType = "FileInfo" #DirectoryInfo
$filenames = (Get-ChildItem ${scriptDir} | ?{$_.GetType().Name -eq $FileType}).Name
$extensions = (Get-ChildItem ${scriptDir} | ?{$_.GetType().Name -eq $FileType}).Extension
cd $scriptDir

$digit =3 #change
$count = 1 #change
$initName1 = "" #change
$initName2 = "-001" #change

$NamePattern = "{0:D${digit}}"

ForEach($x in $filenames){
    if($x -eq "RenameFileName.ps1"){
        continue
    }
    $name = $NamePattern -f $count
    $NewFileName = ${initName1} + ${name} + ${initName2} + $extensions[$count - 1]
    Rename-Item $x $NewFileName
    $count++
}

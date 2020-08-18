$result = DisplayInputBox
$dir = ""

if($result -eq ""){
    $dir = Split-Path $MyInvocation.MyCommand.Path -Parent
}else{
    echo $result > $dir
}

cd $dir
$basenames = (Get-ChildItem . | ?{$_.GetType().Name -eq "fileinfo"}).BaseName
$extensions = (Get-ChildItem . | ?{$_.GetType().Name -eq "fileinfo"}).Extension
$filenames = (Get-ChildItem . | ?{$_.GetType().Name -eq "fileinfo"}).Name

for($i = 0; $i -lt $extensions.Length; $i++){
    if($extensions[$i] -ne ".ps1"){ continue;}
    if($filenames[$i] -eq "CodeFormatter.ps1"){ continue;}
    
    $outname = $basenames[$index] + "_out" + $extensions[$i]
    FormatIndent -FilePath $filenames[$index] -IndentLength 4 | Out-File $outname
    
    Remove-Item $filenames[$i]
    Rename-Item $outname $filenames[$i]
}

function FormatIndent{
	param($FilePath,$IndentLength = 4)
	$space = ' '
	$indent = 0
	$src = switch -regex -file $FilePath {
		  '{\s*$'   {  ($space * $IndentLength) * $indent++ + $_.Trim(); continue;}
		  '^\s*}'   { ($space * $IndentLength) * --$indent + $_.Trim(); continue;}
		  '^\s*$'   { "" ; continue;}
		  '[^{}]'   { ($space * $IndentLength) * $indent + $_.Trim(); continue;}
	}
	return $src
}

function DisplayInputBox(){
    # Read Assembly
    [void][System.Reflection.Assembly]::Load("Microsoft.VisualBasic, Version=8.0.0.0, Culture=Neutral, PublicKeyToken=b03f5f7f11d50a3a")

    # Message on the InputBox
    $messages = "Paste directory path!`n`nIf you are this script directory, just push OK."

    # Display input box
    $input = [Microsoft.VisualBasic.Interaction]::InputBox($messages)

    return $input
}

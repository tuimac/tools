$regex = "Activ*"
$servicenames = Get-Service -DisplayName $regex | select name
$computername = $env:COMPUTERNAME

while($servicenames.Name.Length -ge 1){
    echo $servicenames[0]
    Get-Service $servicenames[0].Name | Stop-Service -Force
    Set-Service -Name $servicenames[0].Name -StartupType Disabled
    $servicenames = Get-Service -DisplayName $regex | ? {$_.Status -eq } | select name
}

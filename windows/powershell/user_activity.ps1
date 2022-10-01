# Get the all logon success events
$LogonEvents = Get-WinEvent -LogName Security | ? {$_.Id -eq 4624}
# Extract user name from event and count up each user
$userlist = @{}
foreach( $LogonEvent in $LogonEvents ){
    $LogonEventXml = [XML]$LogonEvent.ToXml()
    $LogonUser = ($LogonEventXml.Event.EventData.Data | ? {$_.Name -eq "TargetUserName"}).'#text'
    if($userlist.ContainsKey($LogonUser)){
        $userlist[$LogonUser] += 1
    }else{
        $userlist.Add($LogonUser, 0)
    }
}
$userlist.GetEnumerator() | Select @{N="Col1"; E={$_.Key}}, @{N="Col2"; E={$_.Value}} | Export-Csv "C:\Users\Administrator\Downloads\test.csv" -Delimiter "," -NoTypeInformation 


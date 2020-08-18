function loginRemoteServer($remoteInfo){
    while($true){
        #Get-ChildItem -Path $remoteInfo['dest'] >> C:\log\robocopy.log
        Get-ChildItem -Path $remoteInfo['dest'] 2>&1 | Out-Null
        if($?){
            break
        }else{
            sleep 1
        }
    }
}

function rsync($remoteInfo){
    $waittime = '/W:' + [string]$remoteInfo['interval']
    while($true){
        #robocopy $remoteInfo['src'] $remoteInfo['dest'] /MIR /COPY:DAT /R:0 /LOG+:C:\log\robocopy.log $waittime
        robocopy $remoteInfo['src'] $remoteInfo['dest'] /MIR /COPY:DAT /R:0 $waittime 2>&1 | Out-Null
        if($?){
            break
        }else{
            sleep $remoteInfo['interval']
        }
    }
}

function main(){
    $remoteInfo = @{
        username = 'Administrator'
        password = 'P@ssword'
        src = 'D:\'
        dest = '\\IPorHostname'
        interval = 1
    }
    loginRemoteServer $remoteInfo
    rsync $remoteInfo
}

main

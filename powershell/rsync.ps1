function loginRemoteServer($remoteInfo){
    while($true){
        Get-ChildItem -Path $remoteInfo['dest'] 2>&1 | Out-Null
        if($?){
            break
        }else{
            sleep 1
        }
    }
}

function rsync($remoteInfo){
    $arg = '/COPY:DAT /MIR /R:0 /W:' + [string]$remoteInfo['interval']
    while($true){
        robocopy $remoteInfo['src'] $remoteInfo['dest'] 2>&1 | Out-Null
        if($?){
            sleep $remoteInfo['interval']
        }else{
            break
        }

    }
}

function main(){
    $remoteInfo = @{
        username = 'administrator'
        password = 'P@ssw0rd'
        src = 'C:\tmp'
        dest = '\\IPorHostname\tmp'
        interval = 1
    }

    loginRemoteServer $remoteInfo
    rsync $remoteInfo

}

main

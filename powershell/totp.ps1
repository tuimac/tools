#This code had tried on Powershell version 5.1.14393.2828.
#OS Environment is Windows Server 2016 Datacenter.

$secret = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

function Binary_to_byte($binary_string){
    $byte_array = @()
    $binary_array = $binary_string -split "([0-1]{8})" | ? {$_};
    ForEach($byte_line in $binary_array){
        if($byte_line.Length % 8 -ne 0){continue}
        $byte_chararray = $byte_line.ToCharArray()
        $sum_int = 0
        for($j = 0; $j -lt $byte_chararray.Length; $j++){
            if($byte_chararray[$j] -eq '0'){continue}
            else{$sum_int += ([math]::pow(2, $byte_chararray.Length - ($j + 1)))}
        }
        $byte_array += [int]$sum_int
    }
    return $byte_array
}

function totp($secret_key, $digits, $interval){

	$hash_table = @{
	    "A" = 0;"B" = 1;"C" = 2;"D" = 3;
	    "E" = 4;"F" = 5;"G" = 6;"H" = 7;
	    "I" = 8;"J" = 9;"K" = 10;"L" = 11;
	    "M" = 12;"N" = 13;"O" = 14;"P" = 15;
	    "Q" = 16;"R" = 17;"S" = 18;"T" = 19;
	    "U" = 20;"V" = 21;"W" = 22;"X" = 23;
	    "Y" = 24;"Z" = 25;"2" = 26;"3" = 27;
	    "4" = 28;"5" = 29;"6" = 30;"7" = 31
	}
	$decoded_key = ""
	$base32_key = $secret_key.ToUpper().ToCharArray()
	for($i = 0; $i -lt $base32_key.Length; $i++){
	    if($base32_key[$i] -eq "=") {continue}
	    $binary_data = [Convert]::ToString($hash_table[[string]$base32_key[$i]], 2)
	    $decoded_key += $binary_data.ToString().PadLeft(5, "0")
	}

	######Generate time based key######
	$unix_time = [long](((Get-Date) - (Get-Date("1970/1/1 0:0:0 GMT"))).TotalSeconds)
	$unix_time_binary = ([string]([Convert]::ToString([Math]::Floor($unix_time / $interval), 2))).PadLeft(64, "0")

	######Generate HMAC-SHA1 Digest key######
	$hmac_sha1 = New-Object -TypeName System.Security.Cryptography.HMACSHA1
	$hmac_key = Binary_to_byte $decoded_key
	$time_key = Binary_to_byte $unix_time_binary
	$hmac_sha1.Key = $hmac_key
	$digest_message = $hmac_sha1.ComputeHash($time_key)

	######Generate HOTP value######
	$offset = $digest_message[$digest_messaage.Length - 1] -band 0xf
	$shifted_binary = ($digest_message[$offset] -band 0x7f) -shl 24
	$shifted_binary += ($digest_message[$offset + 1] -band 0xff) -shl 16
	$shifted_binary += ($digest_message[$offset + 2] -band 0xff) -shl 8
	$shifted_binary += $digest_message[$offset+ 3] -band 0xff

	$modulo = [math]::pow(10, $digits)
	$totp_num = "{0:D$digits}" -f [int]($shifted_binary % $modulo)
    return $totp_num
}

function loop_totp(){
    $mfa_code = totp $secret 6 30
    echo $mfa_code
    $remain_time = 30 - (([long](((Get-Date) - (Get-Date("1970/1/1 0:0:0 GMT"))).TotalSeconds)) % 30)

    for($i = $remain_time; $i -ge -5; $i--){
        echo (totp $secret 6 30)
        if((totp $secret 6 30) -ne $mfa_code){
            loop_totp
            break
        }
        if($i -gt 0){
            echo "${i}"
            sleep 1
        }
    }
}

loop_totp

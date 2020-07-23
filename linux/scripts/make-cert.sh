#!/bin/bash

#---------------------------------------------------------------------
#You have to get openvpn packages(openvpn-*.tar.gz).
#https://swupdate.openvpn.org/community/releases/openvpn-*.tar.gz
#And get master.zip to install easy-rsa.
#https://github.com/OpenVPN/easy-rsa/archive/master.zip
#---------------------------------------------------------------------

#Initialize variables

OVPNVER="openvpn-2.4.6"
BASEDIR="$PWD/workplace"
LOG="${BASEDIR}/log-make-cert.log"
COLOR="\e[31m"
COLOR_OFF="\e[m"


#Process start

#mkdir workplace > /dev/null 2>&1
#touch $LOG > /dev/null 2>&1

echo -e "\n" >> $LOG 2>&1
echo -e "${COLOR}##################yum packages install##################\n${COLOR_OFF}" >> $LOG 2>&1

function error(){
	if [ $1 -ne 0 ]; then
		echo -e "$2 was failed!!!\n"
		exit 1
	fi
}

cd $BASEDIR >> $LOG 2>&1

error $? "Change directory"

cp ../master.zip .
cp ../${OVPNVER}.tar.gz .

yum -y install openssl-devel lzo-devel pam-devel gcc make net-tools rpm-build make wget unzip expect >> $LOG 2>&1

error $? "Installing yum packages"

echo -e "1.Installing packages was finished.\n"

echo -e "${COLOR}##################RPM Local Install##################\n${COLOR_OFF}" >> $LOG 2>&1

rpmbuild -tb --clean ${OVPNVER}.tar.gz >> $LOG 2>&1

error $? "Rpmbuild"

yum -y localinstall ~/rpmbuild/RPMS/$(uname -m)/${OVPNVER}-1.$(uname -m).rpm >> $LOG 2>&1

error $? "Yum localinstall"

echo -e "2.RPM Local Install was finished.\n"

echo -e "${COLOR}##################Unzip master.zip##################\n${COLOR_OFF}" >> $LOG 2>&1

unzip master.zip >> $LOG 2>&1

error $? "Unzip master.zip"

cp -r easy-rsa-master/easyrsa3/ /etc/openvpn/ >> $LOG 2>&1

error $? "Copy easyrsa"

echo -e "3.Unzip master.zip was finished.\n"

echo -e "${COLOR}##################Remove files##################\n${COLOR_OFF}" >> $LOG 2>&1

rm -r ~/rpmbuild/RPMS/$(uname -m)/openvpn-* $LOG 2>&1
error $? "Remove files"
rm -f ${OVPNVER}.tar.gz $LOG 2>&1
error $? "Remove files"
rm -rf easy-rsa-master/ $LOG 2>&1
error $? "Remove files"
rm -f master.zip $LOG 2>&1
error $? "Remove files"

echo -e "4.Remove files was finished.\n"

echo -e "${COLOR}##################Make CA cert##################\n${COLOR_OFF}" >> $LOG 2>&1

export LANG=C
CAPASS="root"
COMNAME="tuimac"

cd /etc/openvpn/easyrsa3/

error $? "cd to easyrsa3"

./easyrsa init-pki >> $LOG 2>&1

expect -c "
set timeout 5
spawn ./easyrsa build-ca
expect \"Enter New CA Key Passphrase:\"
send -- \"${CAPASS}\n\"
expect \"*Enter New CA Key Passphrase:\"
send -- \"${CAPASS}\n\"
expect \"Common Name*:\"
send -- \"${COMNAME}\n\"
expect \"CA creation complete*\"
send -- \"exit\"
" >> $LOG 2>&1

error $? "Building CA cert"

cp pki/ca.crt /etc/openvpn/ >> $LOG 2>&1

echo -e "5.Make CA cert was finished.\n"

echo -e "${COLOR}##################Make Server cert##################\n${COLOR_OFF}" >> $LOG 2>&1

expect -c "
spawn ./easyrsa build-server-full server nopass
expect \"Enter pass phrase*:\"
send -- \"${CAPASS}\n\"
expect \"Data Base Updated\"
send -- \"exit\"
" >> $LOG 2>&1

error $? "Make Server cert"

cp /etc/openvpn/easyrsa3/pki/issued/server.crt /etc/openvpn/ >> $LOG 2>&1

cp /etc/openvpn/easyrsa3/pki/private/server.key /etc/openvpn/ >> $LOG 2>&1

echo -e "6.Make Server cert was finished.\n"

echo -e "${COLOR}##################Make DH param##################\n${COLOR_OFF}" >> $LOG 2>&1

./easyrsa gen-dh >> $LOG 2>&1

error $? "Make DH"

cp pki/dh.pem /etc/openvpn/ >> $LOG 2>&1

echo -e "7.Make DH param was finished.\n"

echo -e "${COLOR}##################Make cert revoke list##################\n${COLOR_OFF}" >> $LOG 2>&1
expect -c "
spawn ./easyrsa build-client-full dmy nopass
expect \"Enter pass phrase*:\"
send -- \"${CAPASS}\n\"
expect \"Data Base Updated\"
send -- \"exit\"
" >> $LOG 2>&1

error $? "Make dmy client cert"

expect -c "
spawn ./easyrsa revoke dmy
expect \"*Continue with revocation*:\"
send -- \"yes\"
expect \"Revocation was successful.*\"
send -- \"exit\"
" >> $LOG 2>&1

error $? "Revoke dmy client cert"

rm -f /etc/openvpn/easyrsa3/pki/issued/dmy.crt

error $? "Delete dmy.crt"

rm -f /etc/openvpn/easyrsa3/pki/private/dmy.key

error $? "Delete dmy.key"

rm -f /etc/openvpn/easyrsa3/pki/reqs/dmy.req

error $? "Delete dmy.req"

cp vars.example vars

error $? "Copy vas.example"

sed -e 's/#set_var EASYRSA_CRL_DAYS.*/set_var EASYRSA_CRL_DAYS       3650/' vars >> $LOG 2>&1

error $? "Change vars file"

expect -c "
spawn ./easyrsa gen-crl
expect \"Enter pass phrase*\"
send -- \"${CAPASS}\n\"
expect \"CRL file*\"
send -- \"exit\"
" >> $LOG 2>&1

error $? "Generate crl"

cp /etc/openvpn/easyrsa3/pki/crl.pem /etc/openvpn/

chmod o+r /etc/openvpn/crl.pem

error $? "Change Auth for crl.pem file"

cd ${BASEDIR}
cd ..

echo -e "8.Make cert revoke list is finished!\n"

echo -e "${COLOR}##################Setting Openvpn Config##################\n${COLOR_OFF}" >> $LOG 2>&1

openvpn --genkey --secret /etc/openvpn/ta.key

error $? "Make TLS CertKey"

cp /usr/share/doc/openvpn-*/sample/sample-config-files/server.conf /etc/openvpn

echo "
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key  # This file should be kept secret
dh dh.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "route 10.0.222.0 255.255.255.0"
keepalive 10 120
tls-auth ta.key 0 # This file is secret
cipher AES-256-CBC
user nobody
group nobody
persist-key
persist-tun
status /var/log/openvpn-status.log
log         /var/log/openvpn.log
log-append  /var/log/openvpn.log
verb 3
explicit-exit-notify 1
management localhost 7505
crl-verify crl.pem
" > /etc/openvpn/server.conf

error $? "Configure server.conf"

touch /etc/openvpn/openvpn-startup

echo "
#!/bin/bash
/etc/openvpn/openvpn-shutdown
iptables -I OUTPUT -o tun+ -j ACCEPT
iptables -I FORWARD -o tun+ -j ACCEPT
iptables -I INPUT -i tun+ -j ACCEPT
iptables -I FORWARD -i tun+ -d 10.0.222.0/24 -j ACCEPT
iptables -I FORWARD -i tun+ -d 192.168.1.30 -j ACCEPT
" > /etc/openvpn/openvpn-startup

error $? "Make ovpn start script"

chmod +x /etc/openvpn/openvpn-startup

error $? "Give exe auth to startup"

touch /etc/openvpn/openvpn-shutdown

echo "
#!/bin/bash
delete() {
    rule_number=`iptables -L $target --line-numbers -n -v|grep tun.|awk '{print $1}'|sort -r`
    for num in $rule_number
    do
        iptables -D $target $num
    done
}
target='INPUT'
delete
target='FORWARD'
delete
target='OUTPUT'
delete
" > /etc/openvpn/openvpn-shutdown

error $? "Make ovpn shutdown script"

chmod +x /etc/openvpn/openvpn-shutdown

error $? "Give exe auth to shutdown"

echo -e "9.Setting Openvpn Config is finished!\n"

echo -e "9.Setting Openvpn Config is finished!\n"

BEFORE="#echo 1 > /proc/sys/net/ipv4/ip_forward"
AFTER="echo 1 > /proc/sys/net/ipv4/ip_forward"

sed -e 's/${BEFORE}/${AFTER}/' /etc/rc.d/init.d/openvpn >> $LOG 2>&1
error $? Replace ovpn config

systemctl daemon-reload >> $LOG 2>&1
error $? Daemon-reload

/etc/rc.d/init.d/openvpn start >> $LOG 2>&1
error $? Start openvpn

chkconfig openvpn on >> $LOG 2>&1
error $?? Auto start ovpn

firewall-cmd --remove-service=dhcpv6-client --permanent >> $LOG 2>&
firewall-cmd --add-port=1194/udp --permanent >> $LOG 2>&

echo -e "10.Running Openvpn is finished!\n"

echo -e "${COLOR}##################Make Client Cert##################\n${COLOR_OFF}" >> $LOG 2>&1

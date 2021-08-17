#!/bin/bash

CERTDIR='cert'
OVPNDIR='/etc/openvpn'
PUBLICIP=''

sudo apt install -y openvpn easy-rsa
cd ${OVPNDIR}
make-cadir ${CERTDIR}
cd ${CERTDIR}
./easyrsa init-pki
./easyrsa --batch build-ca nopass
./easyrsa gen-dh
openvpn --genkey --secret ${OVPNDIR}/ta.key
./easyrsa build-server-full server nopass
./easyrsa build-client-full client nopass

cat <<EOF > ${OVPNDIR}/server.conf
port 1194
proto udp
dev tun
ca ${CERTDIR}/pki/ca.crt
cert ${CERTDIR}/pki/issued/server.crt
key ${CERTDIR}/pki/private/server.key
dh ${CERTDIR}/pki/dh.pem
tls-server
keepalive 10 120
tls-auth ${CERTDIR}/ta.key 0
cipher AES-256-CBC
comp-lzo
max-clients 10
persist-key
persist-tun
status /var/log/openvpn-status.log
log         /var/log/openvpn.log
log-append  /var/log/openvpn.log
verb 4
explicit-exit-notify 1
server 10.8.0.0 255.255.255.0
push "route 10.3.0.0 255.255.0.0"
EOF

openvpn --config ${OVPNDIR}/server.conf
iptables -t nat -A POSTROUTING -s 10.3.0.0/16 -o ${DEVICE} -j MASQUERADE
systemctl start openvpn.service
systemctl start openvpn@server.service

cat <<EOF > ${OVPNDIR}/client.ovpn
client
dev tun
proto udp
remote ${PUBLICIP} 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
tls-client
comp-lzo
cipher AES-256-CBC
verb 4
tun-mtu 1500
key-direction 1
EOF

echo '<ca>' >> ${OVPNDIR}/client.ovpn
cat ${CERTDIR}/pki/ca.crt >> ${OVPNDIR}/client.ovpn
echo '</ca>' >> ${OVPNDIR}/client.ovpn

echo '<key>' >> ${OVPNDIR}/client.ovpn
cat ${CERTDIR}/pki/private/server.key >> ${OVPNDIR}/client.ovpn
echo '</key>' >> ${OVPNDIR}/client.ovpn

echo '<cert>' >> ${OVPNDIR}/client.ovpn
cat ${CERTDIR}/pki/issued/server.crt >> ${OVPNDIR}/client.ovpn
echo '</cert>' >> ${OVPNDIR}/client.ovpn

echo '<tls-auth>' >> ${OVPNDIR}/client.ovpn
cat ${CERTDIR}/ta.key >> ${OVPNDIR}/client.ovpn
echo '</tls-auth>' >> ${OVPNDIR}/client.ovpn


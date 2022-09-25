#!/bin/bash

CONFFILE='/etc/bind/named.conf'
ZONEFILE='/etc/bind/tuimac.com'
DOMAIN='tuimac.com'

function genConfFile(){
    IP=$(hostname -i)
    cat <<EOF > ${CONFFILE}
acl allowed-network { localhost; 0.0.0.0/0; };
options {
    directory "/var/bind";
    forward only;
    recursion yes;
    forwarders {
        8.8.8.8;
        8.8.4.4;
        1.1.1.1;
    };
    listen-on-v6 { none; };
    listen-on {
        localhost;
        ${IP};
    };
    allow-query { allowed-network; };
    allow-recursion { allowed-network; };
    version none;
};

logging {
    channel default_log {
        file "/var/log/bind/default.log" versions unlimited size 20M;
        print-time yes;
        print-severity yes;
        print-category yes;
        severity debug;
    };
};

zone "tuimac.com" IN {
    type hint;
    file "${ZONEFILE}";
};
EOF
}

function genZoneFile(){
    HOSTNAME=$(hostname -s)
    cat <<EOF > ${ZONEFILE}
\$TTL 86400
@   IN  SOA ${HOSTNAME}.${DOMAIN}. root.${DOMAIN}. (
    2011071001; Serial
    604800; Refresh
    86400; Retry
    2419200; Expire
    604800; Negative Cache TTL
)
;
@   IN  NS  ${HOSTNAME}.${DOMAIN}.
${HOSTNAME} IN  A   ${IP}
;
EOF
}

function startScript(){
    while true; do
        sleep 10
        python3 dynamicDns.py
    done
}

function startDNS(){
    named -c /etc/bind/named.conf -g -u root
}

function main()(
    genConfFile
    genZoneFile
    #startScript &
    startDNS
)

main

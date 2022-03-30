#!/bin/bash

SYSTEMD='/lib/systemd/system/td-agent.service'
CONF='/etc/td-agent/td-agent.conf'

[[ $USER != 'root' ]] && { echo -n 'Must be root!'; exit 1; }

#curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent4.sh | sh

rpm --import https://packages.treasuredata.com/GPG-KEY-td-agent
cat >/etc/yum.repos.d/td.repo <<'EOF';
[treasuredata]
name=TreasureData
baseurl=http://packages.treasuredata.com/4/redhat/8/\$basearch
gpgcheck=1
gpgkey=https://packages.treasuredata.com/GPG-KEY-td-agent
EOF

systemctl status td-agent.service
td-agent-gem install fluent-plugin-kinesis

cat ${CONF}

sed -i 's/User=td-agent/User=root/' ${SYSTEMD}
sed -i 's/Group=td-agent/Group=root/' ${SYSTEMD}

cat ${SYSTEMD}

systemctl daemon-reload
systemctl start td-agent.service
systemctl status td-agent.service

cat /var/log/td-agent/td-agent.log

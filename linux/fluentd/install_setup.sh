#!/bin/bash

SYSTEMD='/lib/systemd/system/td-agent.service'
CONF='/etc/td-agent/td-agent.conf'
DELIVERY_STREAM='test-audit'

curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent4.sh | sudo sh
sudo systemctl status td-agent.service
sudo td-agent-gem install fluent-plugin-kinesis

sudo cat <<EOF> ${CONF}
<source>
  @type tail
  <parse>
    @type none
  </parse>
  path /var/log/audit/audit.log
  pos_file /var/log/td-agent/audit.pos
  tag kinesis.audit
</source>

<match kinesis.audit>
  @type kinesis_firehose
  region ap-northeast-1
  delivery_stream_name $DELIVERY_STREAM
</match>
EOF

sudo cat ${CONF}

sudo sed -i 's/User=td-agent/User=root/' ${SYSTEMD}
sudo sed -i 's/Group=td-agent/Group=root/' ${SYSTEMD}

sudo cat ${SYSTEMD}

sudo systemctl daemon-reload
sudo systemctl start td-agent.service
sudo systemctl status td-agent.service

sudo cat /var/log/td-agent/td-agent.log

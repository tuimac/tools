#!/bin/bash

curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent4.sh | sudo sh
#sudo systemctl start td-agent.service
sudo systemctl status td-agent.service
sudo td-agent-gem install fluent-plugin-kinesis

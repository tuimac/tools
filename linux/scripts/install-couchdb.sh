#/bin/bash

REPO='/etc/yum.repo.d/apache-couchdb.repo'

[[ $USER != "root" ]] && { echo "Must be root or sudo."; exit 1; }

# Enable epel on Amazon Linux 2
amazon-linux-extras install -y epel

echo '[bintray--apache-couchdb-rpm]
name=Apache-couchdb
baseurl=http://apache.bintray.com/couchdb-rpm/el7/x86_64/
gpgcheck=0
repo_gpgcheck=0
enabled=1'

yum install -y couchdb

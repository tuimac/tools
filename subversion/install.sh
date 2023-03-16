#!/bin/bash

[[ $USER != 'root' ]] && { echo 'Must be root!'; exit 1; }

yum install -y httpd
mkdir /svn
yum install subversion mod_dav_svn
cd /svn
mkdir repos
cd repos
mkdir sample
svnadmin create sample
svn mkdir file:///svn/repos/sample/trunk -m "create"
svn mkdir file:///svn/repos/sample/branches -m "create"
svn mkdir file:///svn/repos/sample/tags -m "create"

cat << EOF > /etc/httpd/conf.d/subversion.conf
<Location /repos>
DAV svn
SVNPath /svn/repos/sample
AuthzSVNAccessFile /svn/repos/sample/authzsvn.conf
Require valid-user
AuthType Basic
AuthName "SVN repos"
AuthUserFile /svn/repos/sample/.htpasswd
</Location>
EOF

htpasswd -cb /svn/repos/sample/.htpasswd ec2-user P@ssw0rd

cat << EOF > /svn/repos/sample/authzsvn.conf
[groups]
dev_grp = ec2-user
[/]
@dev_grp = rw
EOF

chown -R apache:apache /svn/repos/sample
systemctl start httpd
systemctl enable httpd

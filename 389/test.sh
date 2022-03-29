#!/bin/bash

[[ $USER != 'root' ]] && { echo -n 'Must be root!'; exit 1; }

dnf module enable 389-ds -y
dnf install 389-ds-base 389-ds-base-legacy-tools -y
setup-ds.pl

#expect -c "
#set timeout 5
#spawn setup-ds.pl
#"

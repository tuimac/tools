#!/bin/bash

BASE_DN='dc=tuimac,dc=com'
PASSWORD='P@ssw0rd'
LDAP_SERVER='ldaps://ldap.tuimac.com'

ldapsearch -x -H ${LDAP_SERVER} -D "cn=Directory Manager" -w ${PASSWORD} -b ${BASE_DN}

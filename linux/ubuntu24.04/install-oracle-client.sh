#!/bin/bash
#
# Download these modules from https://www.oracle.com/database/technologies/instant-client/downloads.html
# - instantclient-basic-linux.x64-23.26.1.0.0.zip
# - instantclient-sqlplus-linux.x64-23.26.1.0.0.zip
# - instantclient-tools-linux.x64-23.26.1.0.0.zip
#

ORACLE_PACKAGE_PATH="${HOME}/oracle"
ORACLE_CLIENT_INSTALL_DIR="/opt/oracle/"
PACKAGES_LIST=(
    "instantclient-basic-linux.x64-23.26.1.0.0.zip"
    "instantclient-sqlplus-linux.x64-23.26.1.0.0.zip"
    "instantclient-tools-linux.x64-23.26.1.0.0.zip"
)

function main() {
    for package_name in ${PACKAGES_LIST[@]}; do
        if [ -e "${ORACLE_PACKAGE_PATH}/${package_name}" ]; then
            if [ ! -e $ORACLE_CLIENT_INSTALL_DIR ]; then
                sudo mkdir -p $ORACLE_CLIENT_INSTALL_DIR
            fi
            sudo unzip -o "${ORACLE_PACKAGE_PATH}/${package_name}" -d $ORACLE_CLIENT_INSTALL_DIR
            sudo chown -R $USER:$USER $ORACLE_CLIENT_INSTALL_DIR
        fi
    done
    #export ORACLE_HOME=/opt/oracle/instantclient_23_26
    #export LD_LIBRARY_PATH=$ORACLE_HOME/
    #export ORACLE_LIBRARY=$ORACLE_HOME/libclntsh.so
    #export ORACLE_SID=CDB
    #export PATH=$ORACLE_HOME:$PATH
}

main

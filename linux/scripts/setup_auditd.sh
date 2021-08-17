#!/bin/bash

sed -i 's/^num_logs =.*/num_logs = 2/' /etc/audit/auditd.conf
sed -i 's/^max_log_file =.*/max_log_file = 1000/' /etc/audit/auditd.conf

cat <<EOF>> /etc/cron.daily/auditd.cron
#!/bin/sh

##########
# This script can be installed to get a daily log rotation
# based on a cron job.
##########

/sbin/service auditd rotate
EXITVALUE=$?
if [ $EXITVALUE != 0 ]; then
    /usr/bin/logger -t auditd "ALERT exited abnormally with [$EXITVALUE]"
fi
exit 0
cp /var/log/audit/audit.log.1 /var/log/audit/audit.log.$(date '+%Y%m%d')
EOF

chmod +x /etc/cron.daily/auditd.cron

/sbin/service auditd restart

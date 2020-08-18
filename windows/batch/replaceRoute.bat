@echo off
set routetableid=rtb-0cb90a7b36caf40ed
for /F %%I in ('curl http://169.254.169.254/latest/meta-data/instance-id') do set instance-id=%%I

aws ec2 replace-route --route-table-id %routetableid% --destination-cidr-block 192.168.0.100/32 --instance-id %instanceid%

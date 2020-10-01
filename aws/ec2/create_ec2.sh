#!/bin/bash

function create-user-data-file(){
    echo '
#!/bin/bash
NAME='${Name}' 
sed -i "s/preserve_hostname: false/preserve_hostname: true/" /etc/cloud/cloud.cfg
echo  $NAME > /etc/hostname
yum update -y
yum install -y docker jq
usermod -aG docker ec2-user
systemctl enable docker
systemctl start docker
curl -L "https:/lgithub.com/docker/compose/releases/download/1.27.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
reboot
    ' > ${USERDATA}
}

function create-tag-argument(){
    INSTANCE_TAG='ResourceType=instance,Tags=[{Key=Name,Value='${Name}'},{Key=Environment,Value='${Environment}'}]'
    VOLUME_TAG='ResourceType=volume,Tags=[{Key=Name,Value='${Name}'},{Key=Environment,Value='${Environment}'}]'
}

function run-instance(){
    aws ec2 run-instances \
        --image-id ami-06ad9296e6cf1e3cf \
        --instance-type t3.small \
        --key-name test \
        --security-group-ids sg-xxxxxxxxxxxx sg-xxxxxxxxxxxxxx \
        --subnet-id subnet-xxxxxxxxxxxxxxx \
        --capacity-reservation-specification CapacityReservationPreference=none \
        --no-associate-public-ip-address \
        --iam-instance-profile Arn=arn:aws:iam::xxxxxxxxxxxx:instance-profile/test \
        --tag-specifications ${INSTANCE_TAG} ${VOLUME_TAG} \
        --user-data file://${USERDATA}
    rm ${USERDATA}
}

function main(){
    Name='PROD2'
    Environment='PROD'
    USERDATA='userdata.txt'

    create-user-data-file
    create-tag-argument
    run-instance
}

main

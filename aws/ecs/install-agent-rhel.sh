#!/bin/bash

REGION='ap-northeast-1'
CLUSTER='test'

sudo dnf update -y
sudo dnf install python3-pip -y
pip3 install awscli --upgrade --user
mkdir ~/.aws
sh -c "cat <<EOF > ~/.aws/config
[default]
region = $REGION
EOF"

sudo sed -i -e "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
curl -o ecs-agent.tar https://s3.ap-northeast-1.amazonaws.com/amazon-ecs-agent-ap-northeast-1/ecs-agent-latest.tar
sudo sh -c "echo 'net.ipv4.conf.all.route_localnet = 1' >> /etc/sysctl.conf"
sudo sysctl -p /etc/sysctl.conf

yum module remove container-tools
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo sed -i s/7/8/g /etc/yum.repos.d/docker-ce.repo
sudo yum install -y docker-ce
sudo systemctl enable --now docker
sleep 5
sudo systemctl start docker
sudo usermod -aG docker ec2-user

sudo dnf install -y iptables-services
sudo systemctl enable iptables
sudo systemctl start iptables
sudo iptables -t nat -A PREROUTING -p tcp -d 169.254.170.2 --dport 80 -j DNAT --to-destination 127.0.0.1:51679
sudo iptables -t nat -A OUTPUT -d 169.254.170.2 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 51679
sudo chmod 755 /etc/sysconfig/iptables
sudo sh -c 'iptables-save > /etc/sysconfig/iptables'
sudo mkdir -p /etc/ecs /var/log/ecs /var/lib/ecs/data
sudo touch /etc/ecs/ecs.config
sudo sh -c "cat <<EOF > /etc/ecs/ecs.config
ECS_DATADIR=/data
ECS_ENABLE_TASK_IAM_ROLE=true
ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true
ECS_LOGFILE=/log/ecs-agent.log
ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","awslogs"]
ECS_LOGLEVEL=info
ECS_CLUSTER=$CLUSTER
EOF"
sudo docker load --input ./ecs-agent.tar
sudo docker run --name ecs-agent \
	--detach=true \
	--privileged \
	--restart=on-failure:10 \
	--volume=/var/run:/var/run \
	--volume=/var/log/ecs/:/log \
	--volume=/var/lib/ecs/data:/data \
	--volume=/etc/ecs:/etc/ecs \
	--net=host \
	--env-file=/etc/ecs/ecs.config \
	amazon/amazon-ecs-agent:latest

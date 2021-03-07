#!/bin/bash

curl -o ecs-agent.tar https://s3.ap-northeast-1.amazonaws.com/amazon-ecs-agent-ap-northeast-1/ecs-agent-latest.tar
sudo sh -c "echo 'net.ipv4.conf.all.route_localnet = 1' >> /etc/sysctl.conf"
sudo sysctl -p /etc/sysctl.conf
sudo dnf install -y iptables-services docker
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl enable iptables
sudo systemctl start iptables
sudo iptables -t nat -A PREROUTING -p tcp -d 169.254.170.2 --dport 80 -j DNAT --to-destination 127.0.0.1:51679
sudo iptables -t nat -A OUTPUT -d 169.254.170.2 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 51679
sudo chmod 777 /etc/sysconfig/iptables
sudo sh -c 'iptables-save > /etc/sysconfig/iptables'
mkdir -p /etc/ecs /var/log/ecs /var/lib/ecs/data
sudo touch /etc/ecs/ecs.config
sudo sh -c "cat <<EOF > /etc/ecs/ecs.config
ECS_DATADIR=/data
ECS_ENABLE_TASK_IAM_ROLE=true
ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true
ECS_LOGFILE=/log/ecs-agent.log
ECS_AVAILABLE_LOGGING_DRIVERS=["json-file","awslogs"]
ECS_LOGLEVEL=info
ECS_CLUSTER=default
EOF"
docker load --input ./ecs-agent.tar
docker run --name ecs-agent \
	--detach=true \
	--restart=on-failure:10 \
	--volume=/var/run:/var/run \
	--volume=/var/log/ecs/:/log \
	--volume=/var/lib/ecs/data:/data \
	--volume=/etc/ecs:/etc/ecs \
	--net=host \
	--env-file=/etc/ecs/ecs.config \
	amazon/amazon-ecs-agent:latest

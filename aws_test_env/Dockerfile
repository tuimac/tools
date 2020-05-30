FROM centos:8

WORKDIR /root

ADD env/bashrc /root/.bashrc
ADD env/login_screen /root/.login_screen
ADD env/centos/vim.sh /etc/profile.d/vim.sh

ADD requirements.txt /root/requirements.txt
ADD .aws /root/.aws

RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y python3 python-pip vim* iproute curl iputils-ping net-tools unzip git tree && \
    curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
    unzip  awscliv2.zip && \
    bash /root/aws/install && \
    pip install -r requirements.txt && \
    pip3 install -r requirements.txt && \
    mkdir -p /etc/vim/backup && \
    mkdir -p /etc/vim/undo
    
ADD env/vimrc /etc/vim/vimrc

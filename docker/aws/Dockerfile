FROM centos:latest

WORKDIR /root

ADD env/bashrc /root/.bashrc
ADD env/login_screen /root/.login_screen
ADD env/centos/vim.sh /etc/profile.d/vim.sh

ADD requirements.txt /root/requirements.txt
ADD .aws /root/.aws

RUN yum update -y && \
    yum install -y iproute curl unzip git tree vim* && \
    dnf install -y python3 && \
    pip3 install -r requirements.txt && \
    mkdir -p /etc/vim/backup && \
    mkdir -p /etc/vim/undo
    
ADD env/vimrc /etc/vim/vimrc

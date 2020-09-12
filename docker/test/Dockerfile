FROM centos:latest

WORKDIR /root

ADD env/vimrc /etc/vimrc
ADD env/bashrc /root/.bashrc
ADD env/login_screen /root/.login_screen
ADD env/centos/vim.sh /etc/profile.d/vim.sh

RUN yum update -y && \
    yum install -y iproute curl unzip tcpdump net-tools git tree bind-utils traceroute vim* && \
    dnf install -y python3 && \
    mkdir -p /etc/vim/undo && \
    mkdir -p /etc/vim/backup && \
    rm -rf anaconda-ks.cfg anaconda-post.log original-ks.cfg

FROM centos:latest

WORKDIR /root

ADD env/bashrc /root/.bashrc
ADD env/login_screen /root/.login_screen
ADD env/centos/vim.sh /etc/profile.d/vim.sh
ADD env/add_remote_repo /root/add_remote_repo

RUN yum update -y && \
    yum install -y iproute curl unzip git tree vim* && \
    mkdir -p /etc/vim/backup && \
    mkdir -p /etc/vim/undo && \
    rm anaconda-ks.cfg anaconda-post.log original-ks.cfg
    
ADD env/vimrc /etc/vim/vimrc

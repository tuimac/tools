FROM centos:latest

ARG pjtname=httptracker

WORKDIR /root
EXPOSE 8000

ADD env/vimrc /etc/vimrc
ADD env/bashrc /root/.bashrc
ADD env/login_screen /root/.login_screen
ADD env/centos/vim.sh /etc/profile.d/vim.sh
ADD requirements.txt /root/requirements.txt

RUN yum update -y && \
    yum install -y iproute curl unzip tcpdump net-tools git tree bind-utils traceroute vim* && \
    dnf install -y python3 && \
    pip3 install -r requirements.txt && \
    mkdir -p /etc/vim/undo && \
    mkdir -p /etc/vim/backup && \
    rm -rf anaconda-ks.cfg anaconda-post.log original-ks.cfg requirements.txt && \
    git clone https://github.com/tuimac/httptracker.git

ADD env/add_remote_repo /root/$pjtname/add_remote_repo
WORKDIR /root/$pjtname
#CMD ["python3", "httptracker/manage.py", "runserver", "0.0.0.0:8000"]

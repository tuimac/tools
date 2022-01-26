FROM alpine:latest

WORKDIR /root

ADD entrypoint.sh /root/entrypoint.sh
ADD remotessh.sh /root/remotessh.sh

RUN apk update && \
    apk upgrade && \
    apk add --no-cache git bash tzdata vim curl ncurses tree aws-cli openssh && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apk del tzdata && \
    mkdir /etc/vim/backup && \
    mkdir /etc/vim/undo && \
    rm /etc/vim/vimrc && \
    curl -L https://raw.githubusercontent.com/tuimac/tools/master/vim/vimrc -o /etc/vim/vimrc && \
    curl -L https://raw.githubusercontent.com/tuimac/tools/master/linux/bashrc/.bashrc_node_docker -o /root/.bashrc && \
    mkdir /root/.aws && \
    echo ' \
[default] \
region = ap-northeast-1 \
' >> /root/.aws/config && \
    aws s3 cp s3://01-cfn-repository/tuimac.pem . && \
    chmod 600 /root/tuimac.pem

ENTRYPOINT ["bash", "remotessh.sh"]

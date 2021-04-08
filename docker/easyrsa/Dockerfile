FROM alpine:latest

WORKDIR /root

ADD downloadServer.py /root/downloadServer.py
ADD entrypoint.sh /etc/openvpn/entrypoint.sh

RUN apk update && \
    apk upgrade && \
    apk add --no-cache git bash vim easy-rsa python3 && \
    mkdir /etc/vim/backup && \
    mkdir /etc/vim/undo && \
    rm /etc/vim/vimrc && \
    curl -L https://raw.githubusercontent.com/tuimac/tools/master/vim/vimrc -o /etc/vim/vimrc

ENTRYPOINT ["/root/entrypoint.sh"]

FROM alpine:latest

WORKDIR /root

EXPOSE 53/tcp
EXPOSE 53/udp

RUN apk update && \
    apk upgrade && \
    apk add --no-cache git bash tzdata vim curl ncurses bind bind-dnssec-tools && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apk del tzdata && \
    mkdir /etc/vim/backup && \
    mkdir /etc/vim/undo && \
    rm /etc/vim/vimrc && \
    curl -L https://raw.githubusercontent.com/tuimac/tools/master/vim/vimrc -o /etc/vim/vimrc && \
    curl -L https://raw.githubusercontent.com/tuimac/tools/master/linux/bashrc/.bashrc_node_docker -o /root/.bashrc && \
    mkdir /etc/bind/named && \
    touch /var/log/bind9.log

COPY tuimac.private /etc/bind/named/tuimac.private
COPY named.conf /etc/bind/named.conf
COPY entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]

FROM alpine

WORKDIR /root

EXPOSE 53/UDP
EXPOSE 53/TCP

ADD entrypoint.sh /root/entrypoint.sh

RUN apk update && \
    apk upgrade && \
    apk add --no-cache git bash tzdata vim curl ncurses tree bind && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apk del tzdata && \
    mkdir /etc/vim/backup && \
    mkdir /etc/vim/undo && \
    rm /etc/vim/vimrc && \
    curl -L https://raw.githubusercontent.com/tuimac/tools/master/vim/vimrc -o /etc/vim/vimrc && \
    curl -L https://raw.githubusercontent.com/tuimac/tools/master/linux/bashrc/.bashrc_node_docker -o /root/.bashrc && \
    mkdir -p /etc/bind/files

ENTRYPOINT ["/root/entrypoint.sh"]

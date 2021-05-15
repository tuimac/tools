FROM alpine:latest

WORKDIR /root

ADD entrypoint.sh /root/entrypoint.sh
ADD *.ovpn /root/box.ovpn

RUN apk update && \
    apk upgrade && \
    apk add --no-cache git bash tzdata vim curl ncurses tree openvpn && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apk del tzdata && \
    mkdir /etc/vim/backup && \
    mkdir /etc/vim/undo && \
    rm /etc/vim/vimrc && \
    curl -L https://raw.githubusercontent.com/tuimac/tools/master/vim/vimrc -o /etc/vim/vimrc && \
    curl -L https://raw.githubusercontent.com/tuimac/tools/master/linux/bashrc/.bashrc_node_docker -o /root/.bashrc && \
    git clone https://github.com/tuimac/tools

ENTRYPOINT ["openvpn --config box.ovpn"]

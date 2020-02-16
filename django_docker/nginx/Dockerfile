FROM ubuntu:latest
ENV LANG C.UTF-8

MAINTAINER tuimac

RUN apt update && apt -y upgrade && apt -y install nginx iproute2 curl vim iputils-ping net-tools

COPY ./log.conf /etc/nginx/conf.d/log.conf
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./.vimrc /root/.vimrc

ENTRYPOINT /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf

EXPOSE 80

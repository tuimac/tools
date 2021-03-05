FROM alpine

EXPOSE 80

ADD nginx.conf /etc/nginx/nginx.conf
ADD index.html /root/index.html

RUN apk update && \
    apk upgrade && \
    apk add --no-cache nginx

ENTRYPOINT /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf

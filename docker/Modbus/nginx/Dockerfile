FROM alpine

EXPOSE 80

WORKDIR /root

ADD build /root/build
ADD nginx.conf /etc/nginx/nginx.conf

RUN apk update && \
    apk upgrade && \
    apk add --no-cache nginx

ENTRYPOINT /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf

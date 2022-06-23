FROM alpine

EXPOSE 80

RUN apk update && \
    apk upgrade && \
    apk add --no-cache nginx

ENTRYPOINT /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf

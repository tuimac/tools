FROM alpine:latest

WORKDIR /root

ADD entrypoint.sh /root/entrypoint.sh

RUN apk update && \
    apk upgrade && \
    apk add --no-cache bash icu-dev icu-libs python3 py3-pip mysql-client && \
    pip3 install awscli && \
    mkdir ~/.aws && \
    echo -en '[default]\nregion = ap-northeast-3\n' > .aws/config

ENTRYPOINT ["/root/entrypoint.sh"]

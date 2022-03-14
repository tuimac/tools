FROM registry.access.redhat.com/ubi8:8.4

EXPOSE 80

WORKDIR /usr/sbin

RUN yum install -y nginx

USER 998

ENTRYPOINT ["nginx", "-g", "daemon off;"]

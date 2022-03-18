FROM registry.access.redhat.com/ubi8:8.4

EXPOSE 5432

ENV POSTGRESQL_VERSION=13

RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm && \
    dnf -qy module disable postgresql && \
    dnf install -y postgresql${ENV POSTGRESQL_VERSION}-server

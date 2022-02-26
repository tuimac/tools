FROM registry.redhat.io/rhel8/postgresql-13:1-31

ENV PGDATA /var/lib/pgsql/data/userdata

#ADD etc/postgresql.conf /var/lib/pgsql/data/postgresql.conf
#ADD etc/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf
ADD entrypoint.sh /usr/bin/run-postgresql

RUN mkdir /var/lib/pgsql/backup

ENTRYPOINT ["container-entrypoint"]
CMD ["run-postgresql"]

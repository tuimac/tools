FROM registry.redhat.io/rhel8/postgresql-13:1-31

ENV PGDATA /var/lib/pgsql/data/userdata

ADD etc/postgresql.conf /tmp/postgresql.conf
ADD etc/pg_hba.conf /tmp/pg_hba.conf

ENTRYPOINT ["container-entrypoint"]
CMD ["run-postgresql"]

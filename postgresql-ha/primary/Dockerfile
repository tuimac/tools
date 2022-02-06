FROM registry.redhat.io/rhel8/postgresql-13:1-31

ENV PGDATA /var/lib/pgsql/data

ADD entrypoint.sh /var/lib/pgsql/entrypoint.sh
ADD etc/postgresql.conf /var/lib/pgsql/postgresql.conf
ADD etc/pg_hba.conf /var/lib//var/lib/pgsqll/pg_hba.conf

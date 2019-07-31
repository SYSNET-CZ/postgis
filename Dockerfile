#--------- Generic stuff all our Dockerfiles should start with so we get caching ------------
FROM debian:stretch
MAINTAINER Radim Jaeger <rjaeger@sysnet.cz>

RUN  export DEBIAN_FRONTEND=noninteractive
ENV  DEBIAN_FRONTEND noninteractive
RUN  dpkg-divert --local --rename --add /sbin/initctl

RUN apt-get clean && apt-get update && apt-get install -y locales

RUN localedef -i cs_CZ -c -f UTF-8 -A /usr/share/locale/locale.alias cs_CZ.UTF-8
RUN sed -i -e 's/# cs_CZ.UTF-8 UTF-8/cs_CZ.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LANG=cs_CZ.UTF-8 \
    LANGUAGE=cs_CZ:cs \
    LC_ALL=cs_CZ.UTF-8 \
    LC_CTYPE="cs_CZ.UTF-8" \
    LC_NUMERIC="cs_CZ.UTF-8" \
    LC_TIME="cs_CZ.UTF-8" \
    LC_COLLATE="cs_CZ.UTF-8" \
    LC_MONETARY="cs_CZ.UTF-8" \
    LC_MESSAGES="cs_CZ.UTF-8" \
    LC_PAPER="cs_CZ.UTF-8" \
    LC_NAME="cs_CZ.UTF-8" \
    LC_ADDRESS="cs_CZ.UTF-8" \
    LC_TELEPHONE="cs_CZ.UTF-8" \
    LC_MEASUREMENT="cs_CZ.UTF-8" \
    LC_IDENTIFICATION="cs_CZ.UTF-8"

RUN apt-get -y install gnupg2 wget ca-certificates rpl pwgen

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

#-------------Application Specific Stuff ----------------------------------------------------

# We add postgis as well to prevent build errors (that we dont see on local builds) on docker hub e.g.
# The following packages have unmet dependencies:
RUN apt-get update; apt-get install -y postgresql-client-11 postgresql-common postgresql-11 postgresql-11-postgis-2.5 postgresql-11-pgrouting netcat
RUN apt-get install -y osm2pgsql

# Open port 5432 so linked containers can see them
EXPOSE 5432

# Run any additional tasks here that are too tedious to put in this dockerfile directly.
ADD env-data.sh /env-data.sh
ADD setup.sh /setup.sh
RUN chmod +x /setup.sh
RUN /setup.sh

# We will run any commands in this when the container starts
ADD docker-entrypoint.sh /docker-entrypoint.sh
ADD setup-conf.sh /
ADD setup-database.sh /
ADD setup-pg_hba.sh /
ADD setup-replication.sh /
ADD setup-ssl.sh /
ADD setup-user.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT /docker-entrypoint.sh

#!/usr/bin/env bash

source /env-data.sh

# This script will setup new configured user

# Note that $POSTGRES_USER and $POSTGRES_PASS below are optional parameters that can be passed
# via docker run e.g.
#docker run --name="postgis" -e POSTGRES_USER=qgis -e POSTGRES_PASS=qgis -d -v
#/var/docker-data/postgres-dat:/var/lib/postgresql -t qgis/postgis:6

# If you dont specify a user/password in docker run, we will generate one
# here and create a user called 'docker' to go with it.

# Only create credentials if this is a master database
# Slave database will just mirror from master users
echo "Setup postgres User:Password"
echo "postgresql user: $POSTGRES_USER" > /tmp/PGPASSWORD.txt
echo "postgresql password: $POSTGRES_PASS" >> /tmp/PGPASSWORD.txt

# Check user already exists
RESULT=`su - postgres -c "psql postgres -t -c \"SELECT 1 FROM pg_roles WHERE rolname = '$POSTGRES_USER'\""`
COMMAND="ALTER"
if [ -z "$RESULT" ]; then
	COMMAND="CREATE"
fi
su - postgres -c "psql postgres -c \"$COMMAND USER $POSTGRES_USER WITH SUPERUSER CREATEDB CREATEROLE ENCRYPTED PASSWORD '$POSTGRES_PASS';\""

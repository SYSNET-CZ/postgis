#!/bin/bash
# Commit and redeploy the user map container
#
if [ $# -ne 1 ]; then
    echo "Commit and then redeploy the sysnetcz/postgis container."
    echo "Usage:"
    echo "$0 <version>"
    echo "e.g.:"
    echo "$0 1.6"
    echo "Will commit the current state of the container as version 1.6"
    echo "and then redeploy it."
    exit 1
fi
VERSION=$1
HOST_DATA_DIR=/local/data/postgres
PGUSER=docker
PGPASS=docker

IDFILE=${pwd}/data/postgis-current-container.id
ID=docker inspect --format="{{.Id}}" sysnetcz/postgis:latest

if [ -f "$IDFILE" ]; then
    ID=`cat $IDFILE`
else 
    echo $ID > $IDFILE
fi
docker commit $ID sysnetcz/postgis:$VERSION --run='{"Cmd": ["/start.sh"], "PortSpecs": ["5432"], "Hostname": "postgis"}' --author="Radim Jaeger <rjaeger@sysnet.cz>"
docker kill $ID
docker rm $ID
rm $IDFILE
if [ ! -d $HOST_DATA_DIR ]
then
    mkdir $HOST_DATA_DIR
fi
CMD="docker run --cidfile="$IDFILE" --name="postgis" -e POSTGRES_USER=$PGUSER -e POSTGRES_PASS=$PGPASS -d -v $HOST_DATA_DIR:/var/lib/postgresql -t sysnetcz/postgis:$VERSION /start.sh"
echo 'Running:'
echo $CMD
eval $CMD
NEWID=`cat $IDFILE`
echo "Postgis has been committed as $1 and redeployed as $NEWID"
docker ps -a | grep $NEWID
echo "If thhere was no pre-existing database, you can access this using"
IPADDRESS=`docker inspect postgis | grep IPAddress | grep -o '[0-9\.]*'`
echo "psql -l -p 5432 -h $IPADDRESS -U $PGUSER"
echo "and password $PGPASS"

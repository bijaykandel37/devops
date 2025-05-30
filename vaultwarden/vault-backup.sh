#!/bin/sh
set -e
# Creates backup names like 2020-04-23
BACKUP_NAME=`date +%F`
NOW_MONTH=$(date +"%Y-%m")
#==========================Things-to-setup====================================#
# Do not keep backups older than 05 days.
BACKUP_TTL_DAYS=03
ENV_FILE=/home/bitwarden/vault.env
HOST_BACKUPS_DIR=/home/backups/vault
HOST_BACKUP_DEST=$HOST_BACKUPS_DIR/$BACKUP_NAME
#Swarm setup
DOCKER_SWARM_SERVICE_NAME=vaultwarden_postgres
DOCKER_CONT_NAME=vaultwarden_postgres.1
POSTGRES_CONTAINER_ID=$(docker service ps $DOCKER_SWARM_SERVICE_NAME -q --no-trunc | head -n1)
#Backing up from docker 1 or from host 0
DOCKER=1
DATABASE=vault
USER=vault
#AWS Credentials
AMAZON_S3_BUCKET="s3://backup-storage/bitwarden-vault/$NOW_MONTH/"
AMAZON_S3_BIN="/usr/local/bin/aws"
#==============================================================#
echo `date` Backing up..
if [ $DOCKER -eq 1 ]
then
        #pg_dump -U username -h 127.0.0.1 -p 3031 database > outputfile
        docker exec -t $DOCKER_CONT_NAME.$POSTGRES_CONTAINER_ID pg_dump -U $USER $DATABASE > $HOST_BACKUP_DEST
else
        #--host=mongodb1.example.net --port=3017 --username=user --password="pass" --collection=myCollection --db=test --out=/data/backup/
        pg_dump -U $USER $DATABASE > $HOST_BACKUP_DEST
fi

echo Compressing backup directory to $BACKUP_NAME.tar.gz
cd $HOST_BACKUPS_DIR
tar -zcvf $BACKUP_NAME.tar.gz $BACKUP_NAME $ENV_FILE

echo Removing backup directory $HOST_BACKUP_DEST
rm -rf $HOST_BACKUP_DEST

${AMAZON_S3_BIN} s3 cp ${HOST_BACKUP_DEST}.tar.gz ${AMAZON_S3_BUCKET}
${AMAZON_S3_BIN} s3 ls ${AMAZON_S3_BUCKET}

echo Deleting backup tarballs older than $BACKUP_TTL_DAYS days in $HOST_BACKUPS_DIR
find $HOST_BACKUPS_DIR -type f -mtime +$BACKUP_TTL_DAYS -exec rm '{}' +

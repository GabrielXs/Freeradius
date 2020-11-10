#!/bin/bash

CONTAINER_NAME=$1


usage(){
    echo "uso: $0 [nome container]. "
    exit 1
}

if [ -z $CONTAINER_NAME ]; then
        echo "Error: falta o parâmetro do nome do container."
        usage
fi

DATE=$(date +%d_%m_%y_%H_%M)

docker exec $CONTAINER_NAME /usr/bin/mysqldump -u root -ps1n4ps#@2 AnielRadius > /backup-mysql/backup_$DATE.sql


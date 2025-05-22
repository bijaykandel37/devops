#!/bin/bash

rcpts="someone@email.com"

backupfile=/backup/filebackup/nfd_$(date '+%d-%m-%Y').tar.gz
tar -czvf $backupfile /app/data

if [ $? -eq 0 ]; then
	echo -e "Subject:Finance File Backup\nBackup is Successful.\nPath for backup is ${backupfile}" | sendmail -F "Devops Admin" -f "noreply-devops@email.com" ${rcpts}
else
	echo -e "Subject:Finance File Backup\nError Encountered while performing backup operation." | sendmail -F "Devops Admin" -f "noreply-devops@email.com" ${rcpts}
fi


find /backup/filebackup -type f -iname "*.tar.gz" -mtime +27 -delete


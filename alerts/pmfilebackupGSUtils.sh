#!/bin/bash

GCP_BIN=/bin/gsutil

rcpts="someone@email.com"
echo -e "\n\n" >> /root/pm_output.log
echo `date` >> /root/pm_output.log
backupfile=/app/processmaker/filebackup/processmaker_$(date '+%d-%m-%Y').tar.gz
tar -czvf $backupfile /app/processmaker/data

${GCP_BIN} cp ${backupfile} gs://bkp-bkt/processmaker/filebackup && rm -rf ${backupfile}

if [ $? -eq 0 ]; then
	echo -e "Subject:Processmaker File Backup\nBackup is Successful.\nPath for backup is gs://bkp-bkt/processmaker/filebackup/processmaker_$(date '+%d-%m-%Y').tar.gz " | /sbin/sendmail -v -F "Devops Admin" -f "noreply-devops@email.com" ${rcpts} >> /root/pm_output.log
else
	echo -e "Subject:Processmaker File Backup\nError Encountered while performing backup operation." | /sbin/sendmail -v -F "Devops Admin" -f "noreply-devops@email.com" ${rcpts} >> /root/pm_output.log
fi

#find /app/processmaker/filebackup -type f -iname "*.tar.gz" -mtime +7 -delete

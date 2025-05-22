The alert.sh and cronnotify.sh work together. cronnotify.sh has some scripts that needs to be run as cron and logs are generated in three files. emailnotifyrequestor.log, removemembers.log and combined. One file position.txt stores the position of the combinedlog.log and alerts if new "curl" text is appended to combinedlog.log file. it is assumed that whenever text "cron" appears in log file, there is some kind of error.

In crontab.py file, a python script is generated which sends alert if backup scripts are not executed properly.
Usage: python3 crontab.py wiki_backup


filebackup.sh file is for backing up some files mounted and send mail if the backup was not successful and pmgsutils is for storing the backup file in GCP.

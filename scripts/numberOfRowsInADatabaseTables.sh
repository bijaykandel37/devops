#!/bin/bash

USER="root"
PASSWORD="Nirvana3"
DATABASE="sys"
TABLE=$(mysql -u $USER -p$PASSWORD -e "show tables" $DATABASE 2>/dev/null | awk {'print $1'} )
HOST="localhost" # or your MySQL server IP

echo "TABLE=$(mysql -u $USER -p$PASSWORD -e "show tables" $DATABASE | awk {'print $1'} )" >> tables.txt

while read table
 do
   QUERY="SELECT COUNT(*) FROM $table;"
ROW_COUNT=$(mysql -h $HOST -u $USER -p$PASSWORD $DATABASE -Bse "$QUERY" 2>/dev/null)
echo "Number of rows in $table: $ROW_COUNT"
 done < tables.txt

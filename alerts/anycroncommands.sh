#!bin/bash

authToken="your_token"
url="https://processmaker.com/workflow/oauth2/token"

value=$(curl -X POST  $url -H 'Authorization: Basic '$authToken -d 'grant_type=client_credentials')

echo $value;

token=$(echo "$value" | jq -r '.access_token')
#echo $token;

curl -X GET $url/apipath  -H 'Authorization: Bearer '$token 2>> emailnotifyrequestor.log  2>> combinedlog.log


/bin/sh /root/notifyAndRemoveMembersFromLDAP/alert.sh


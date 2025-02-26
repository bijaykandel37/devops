#!/bin/sh

curl -u "elastic:elasticpassword" -X POST "localhost:9200/_security/user/another_user" -H 'Content-Type: application/json' -d '{ "password": "changeme1", "roles": ["kibana_system"] }'

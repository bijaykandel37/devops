#!/bin/bash

docker pull docker.elastic.co/logstash/logstash:8.11.2
docker pull docker.elastic.co/kibana/kibana:8.11.2
docker pull docker.elastic.co/elasticsearch/elasticsearch:8.11.2
docker pull docker.elastic.co/beats/elastic-agent:8.11.2


#volume mount directories and permissions
mkdir -p ./data/elasticsearchdata && mkdir ./data/logstashdata && chown -R 1000 ./data 

#initialize docker swarm in localhost. Change ip to private IP for prod deployments
docker swarm init --advertise-addr 127.0.0.1


docker stack deploy -c docker-compose-elk.yml ELK

#to add user `another_user` which is used by kibana with password changeme1. This is required because there need to be a user in elasticsearch which should not be root user `elastic`.
curl -u "elastic:elasticpassword" -X POST "localhost:9200/_security/user/another_user" -H 'Content-Type: application/json' -d '{ "password": "changeme1", "roles": ["kibana_system"] }'

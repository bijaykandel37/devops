Create domains in Route53 and point to loadbalancer in the region.

First Need to create a ssl and import to the ACM

Use these commands ::

> openssl genpkey -algorithm RSA_2048 -out agent.dev.avid.health.rsa -aes256

> openssl rsa -in agent.dev.avid.health.rsa -out agent.dev.avid.health.key

> openssl req -x509 -newkey rsa:2048 -key agent.dev.avid.health.key -out agent.dev.avid.health.crt

Upload this crt file and key file to aws and grab the ARN of the Certificate file.
[Note: The Certificate must be in same region where you are deploying the stack]



Then generate kibana user with curl command and edit the fleet settings to use elastic url
which is set as localhost to proper url

```
curl -u "elastic:elasticpassword" -X POST "http://elasticsearch.dev.avid.health/_security/user/another_user" -H 'Content-Type: application/json' -d '{ "password": "changeme1", "roles": ["kibana_system"] }'
```


(If domain is not found, you can use nslookup to lookup the ip and use IP address)

Then login to kibana and add fleet which generates the service token
Append the token in env variable of our AgentService task definition


And update the Agent service with the token provided in kibana.
Then monitor the 4 services if all of them are healthy or not. 
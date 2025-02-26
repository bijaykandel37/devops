Cloudwatch logs are shipped into self hosted ELK stack:
>Get Started

Set ENV variables ELASTICSEARCH_ENDPOINT ELASTICSEARCH_USERNAME ELASTICSEARCH_PASSWORD
Go to Cloudwatch log groups and create a subscription filter for Lambda and select nodejs 20 env.
Lambda must have basic Execution role for lambda


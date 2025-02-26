version: '3.7'

services:
  database:
    image: postgres:14.3-alpine3.16
    environment:
      PGDATA: /data/postgres
    ports:
      - "54329:5432"
    volumes:
      - /dockervolume/drop-wms/data/postgres:/data/postgres
      - /etc/localtime:/etc/localtime:ro
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: pwds
    deploy:
      labels:
        feature.description: 'POSTGRES'
      placement:
        constraints: [node.role == manager]
    networks:
      - drop-portal

  redis:
    image: redis:5.0.7
    networks:
      - drop-portal

  rabbitmq:
    image: rabbitmq:3.7-management
    environment:
      RABBITMQ_DEFAULT_USER: mqadmin
      RABBITMQ_DEFAULT_PASS: mqpds
    volumes:
      - ./rabbitmq:/var/lib/rabbitmq
    networks:
      - drop-portal

networks:
  drop-portal:

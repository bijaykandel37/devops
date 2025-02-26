#!/bin/bash

yum install wget tar -y
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz
sudo cp node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin
#sudo chown node:prometheus /usr/local/bin/node_exporter
sudo useradd -M -s /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter


echo ' [Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target ' > /etc/systemd/system/node_exporter.service


sudo systemctl daemon-reload
sudo systemctl enable node_exporter 
sudo systemctl start node_exporter

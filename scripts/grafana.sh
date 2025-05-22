#!/bin/bash

echo "Installing Nginx" 
yum install nginx -y 
systemctl start nginx 
systemctl enable nginx


echo "Installing Grafana" 
sudo dnf install -y https://dl.grafana.com/oss/release/grafana-8.3.3-1.x86_64.rpm
sudo dnf install grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server


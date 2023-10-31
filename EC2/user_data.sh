#!/bin/bash

# this script will install nginx and some other config

#update system
sudo apt update
sudo apt upgrade 

#install nginx
sudo apt install nginx -y

echo "<html><body><h1>JOMACS TERRAFORM PROJECT</h1></body></html>" > /var/www/html/index.html

#Switching ssh port from 22 to 212
sudo apt update -y
sudo su 
sed -i "s/#Port 22/Port 212/" /etc/ssh/sshd_config

#start nginx
sudo systemctl enable nginx
sudo systemctl start nginx

#create proxy server to listen on port 80
sudo tee /etc/nginx/sites-available/practice.conf <<-EOF
server {
  listen 80;

  location / {
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_cache_bypass http_upgrade;
    ProxyPass http://localhost:80/;
  }
}

ln -s /etc/nginx/sites-available/practice.conf /etc/nginx/sites-enabled/






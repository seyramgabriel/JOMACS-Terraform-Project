#!/bin/bash

#update system
sudo apt update -y
sudo apt upgrade 

#Switching ssh port from 22 to 212
sudo su 
sed -i "s/#Port 22/Port 212/" /etc/ssh/sshd_config




#!/bin/bash

sudo dnf install -y wget
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-03/quick-oil-part3.zip
mkdir /tmp/lab-app
sudo rm -rf /var/www/html/*
unzip quick-oil-part3.zip -d /tmp/lab-app
mv /tmp/lab-app/quick-oil-part3/* /var/www/html
rm -rf /tmp/lab-app/
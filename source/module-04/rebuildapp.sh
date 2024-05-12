#!/bin/bash

sudo dnf install -y wget
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-04/quick-oil-part4.zip
mkdir /tmp/lab-app
unzip quick-oil-part4.zip -d /tmp/lab-app
mv /tmp/lab-app/quick-oil-part4/* /var/www/html
rm -rf /tmp/lab-app/
rm quick-oil-part4.zip


rm $0
#!/bin/bash

sudo dnf install -y wget
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-07/quick-oil-part6.zip
mkdir /tmp/lab-app
unzip quick-oil-part6.zip -d /tmp/lab-app
rm /tmp/lab-app/quick-oil-part6/scripts/settings.js

# Remove so that we don't overwrite variables they have stored
mkdir -p /var/www/html
cp -rf /tmp/lab-app/quick-oil-part6/* /var/www/html/
cp -rf /tmp/lab-app/quick-oil-part6/scripts/* /var/www/html/scripts/
cp -rf /tmp/lab-app/quick-oil-part6/images/* /var/www/html/images/
rm -rf /tmp/lab-app/
rm quick-oil-part6.zip

rm $0
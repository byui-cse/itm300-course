#!/bin/bash

sudo dnf install -y wget
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-09/quick-oil-part7.zip
mkdir /tmp/lab-app
unzip quick-oil-part7.zip -d /tmp/lab-app
# Remove so that we don't overwrite variables they have stored
rm /tmp/lab-app/quick-oil-part7/scripts/settings.js
mkdir -p /var/www/html
cp -ru /tmp/lab-app/quick-oil-part7/* /var/www/html/
cp -ru /tmp/lab-app/quick-oil-part7/scripts/* /var/www/html/scripts/
cp -ru /tmp/lab-app/quick-oil-part7/images/* /var/www/html/images/
rm -rf /tmp/lab-app/
rm quick-oil-part7.zip

rm $0
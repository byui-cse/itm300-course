#!/bin/bash

sudo dnf install -y wget
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-06/quick-oil-part5.zip
mkdir /tmp/lab-app
unzip quick-oil-part5.zip -d /tmp/lab-app
# Remove so that we don't overwrite variables they have stored
rm /tmp/lab-app/quick-oil-part5/scripts/settings.js

cp -rf /tmp/lab-app/quick-oil-part5/* /var/www/html/
cp -rf /tmp/lab-app/quick-oil-part5/scripts/* /var/www/html/scripts/

rm -rf /tmp/lab-app/
rm quick-oil-part5.zip

rm $0
#!/bin/bash

sudo dnf install -y wget
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-04/quick-oil-part4.zip
mkdir /tmp/lab-app
unzip quick-oil-part4.zip -d /tmp/lab-app
mv /tmp/lab-app/quick-oil-part4/* /var/www/html
mv /tmp/lab-app/quick-oil-part4/scripts/* /var/www/html/scripts
rm -rf /tmp/lab-app/
rm quick-oil-part4.zip

######################################################

echo "Please enter your API Gateway Invoke URL:"
read invoke_url

# Define the file path of login.js
file_path="/var/www/html/scripts/requestServiceHelper.js"

# Use sed to replace the line containing 'UserPoolId: REPLACE-WITH-YOUR-USER-POOL-ID'
sed -i "s/REPLACE-WITH-INVOKE-URL/$invoke_url/g" "$file_path"

echo "Invoke URL updated in $file_path"


rm $0
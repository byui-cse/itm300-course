#!/bin/bash

sudo dnf install -y wget
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-06/quick-oil-part5.zip
mkdir /tmp/lab-app
unzip quick-oil-part5.zip -d /tmp/lab-app
# Remove so that we don't overwrite variables they have stored
rm /tmp/lab-app/quick-oil-part5/scripts/login.js
rm /tmp/lab-app/quick-oil-part5/scripts/getMessage.js

mv /tmp/lab-app/quick-oil-part5/* /var/www/html
mv /tmp/lab-app/quick-oil-part5/scripts/* /var/www/html/scripts
rm -rf /tmp/lab-app/
rm quick-oil-part5.zip

######################################################

echo "Please enter your API Gateway Invoke URL:"
read -r invoke_url  # Use -r option to prevent backslashes from being interpreted

# Define the file path of requestServiceHelper.js
file_path="/var/www/html/scripts/requestServiceHelper.js"

# Escape special characters in the URL for use in sed
escaped_url=$(sed 's/[&/\]/\\&/g' <<< "$invoke_url")

# Use sed to replace the placeholder in the JavaScript file
sed -i "s|REPLACE-WITH-INVOKE-URL|${escaped_url}|g" "$file_path"

echo "Invoke URL updated in $file_path"


rm $0
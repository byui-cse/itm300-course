#!/bin/bash

sudo dnf install -y wget
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-10/rebuildsettings.zip
mkdir /tmp/lab-app
# sudo rm -rf /var/www/html/*
unzip rebuildsettings.zip -d /tmp/lab-app
cp -rf /tmp/lab-app/rebuildsettings/* /var/www/html
rm -rf /tmp/lab-app/
rm rebuildsettings.zip

echo "Please enter your Cognito User Pool ID:"
read user_pool_id

file_path="/var/www/html/scripts/settings.js"

# Use sed to replace the line containing 'UserPoolId: REPLACE-WITH-YOUR-USER-POOL-ID'
sed -i "s/UserPoolId: 'REPLACE-WITH-YOUR-USER-POOL-ID',/UserPoolId: '$user_pool_id',/" "$file_path"

echo "User Pool ID updated in $file_path"

######################################################33

echo "Please enter your App Client ID:"
read user_client_id

file_path="/var/www/html/scripts/settings.js"

# Use sed to replace the line containing 'UserPoolId: REPLACE-WITH-YOUR-USER-POOL-ID'
sed -i "s/ClientId: 'REPLACE-WITH-YOUR-CLIENT-ID'/ClientId: '$user_client_id'/" "$file_path"

echo "App Client ID updated in $file_path"

######################################################33

# Prompt the user for the Cognito Domain
echo "Please enter your Cognito Domain:"
read cognito_domain

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Get the Public IPv4 DNS using the session token
ec2_domain=$(curl -s "http://169.254.169.254/latest/meta-data/public-hostname" -H "X-aws-ec2-metadata-token: $TOKEN")

# Prompt the user for the EC2 IPv4 URL
# echo "Please enter your EC2 IPv4 URL: (e.g. ec2-44-223-155-81.compute-1.amazonaws.com)"
# read ec2_domain

# Define the file path of getMessage.js
file_path_message="/var/www/html/scripts/settings.js"

sed -i "s|REPLACE-WITH-COGNITO-URL|${cognito_domain}|g; \
        s|REPLACE-WITH-CLIENT-ID|${user_client_id}|g; \
        s|REPLACE-WITH-EC2-URL|https%3A%2F%2F${ec2_domain}|g" "$file_path_message"


######################################################

echo "Please enter your API Gateway Invoke URL:"
read -r invoke_url  # Use -r option to prevent backslashes from being interpreted

# Define the file path of requestServiceHelper.js
file_path="/var/www/html/scripts/settings.js"

# Escape special characters in the URL for use in sed
escaped_url=$(sed 's/[&/\]/\\&/g' <<< "$invoke_url")

# Use sed to replace the placeholder in the JavaScript file
sed -i "s|REPLACE-WITH-INVOKE-URL|${escaped_url}|g" "$file_path"

echo "Invoke URL updated in $file_path"

echo "Settings updated in $file_path_message"

rm $0
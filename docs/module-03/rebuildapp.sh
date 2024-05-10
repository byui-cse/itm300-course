#!/bin/bash

sudo dnf install -y wget
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-03/quick-oil-part3.zip
mkdir /tmp/lab-app
sudo rm -rf /var/www/html/*
unzip quick-oil-part3.zip -d /tmp/lab-app
mv /tmp/lab-app/quick-oil-part3/* /var/www/html
rm -rf /tmp/lab-app/
rm quick-oil-part3.zip

echo "Please enter your User Pool ID:"
read user_pool_id

# Define the file path of login.js
file_path="/var/www/html/scripts/login.js"

# Use sed to replace the line containing 'UserPoolId: REPLACE-WITH-YOUR-USER-POOL-ID'
sed -i "s/UserPoolId: 'REPLACE-WITH-YOUR-USER-POOL-ID',/UserPoolId: '$user_pool_id',/" "$file_path"

echo "User Pool ID updated in $file_path"

######################################################33

echo "Please enter your App Client ID:"
read user_client_id

# Define the file path of login.js
file_path="/var/www/html/scripts/login.js"

# Use sed to replace the line containing 'UserPoolId: REPLACE-WITH-YOUR-USER-POOL-ID'
sed -i "s/ClientId: 'REPLACE-WITH-YOUR-CLIENT-ID'/ClientId: '$user_client_id'/" "$file_path"

echo "App Client ID updated in $file_path"

######################################################33

echo "Please enter your Cognito Domain:"
read cognito_domain


echo "Please enter your EC2 IPv4 URL:"
read ec2_domain

# Define the file path of login.js
file_path_message="/var/www/html/scripts/getMessage.js"

other_separator="/oauth2/authorize?response_type=token&scope=email+openid+phone&client_id=${user_client_id}&redirect_uri="

combined_domain="${cognito_domain}${other_separator}${ec2_domain}"

# Use sed to replace the line containing 'UserPoolId: REPLACE-WITH-YOUR-USER-POOL-ID'
sed -i "s/const hostedUI = "REPLACE-WITH-YOUR-HOSTED-ID";/const hostedUI: '$combined_domain'/" "$file_path_message"

echo "getMessage Hosted UI updated in $file_path_message"


rm $0
#!/bin/bash

sudo dnf install -y wget
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-07/quick-oil-part6.zip
mkdir /tmp/lab-app
unzip quick-oil-part6.zip -d /tmp/lab-app
# Remove so that we don't overwrite variables they have stored

mv /tmp/lab-app/quick-oil-part6/* /var/www/html
mv /tmp/lab-app/quick-oil-part6/scripts/* /var/www/html/scripts
rm -rf /tmp/lab-app/
rm quick-oil-part6.zip

######################################################

echo "Please enter your API Gateway Invoke URL:"
read -r invoke_url  # Use -r option to prevent backslashes from being interpreted

file_path="/var/www/html/scripts/settings.js"

# Escape special characters in the URL for use in sed
escaped_url=$(sed 's/[&/\]/\\&/g' <<< "$invoke_url")

# Use sed to replace the placeholder in the JavaScript file
sed -i "s|REPLACE-WITH-INVOKE-URL|${escaped_url}|g" "$file_path"

echo "Invoke URL updated in $file_path"

#########################################

echo "Please enter your User Pool ID:"
read user_pool_id

# Use sed to replace the line containing 'UserPoolId: REPLACE-WITH-YOUR-USER-POOL-ID'
sed -i "s|REPLACE-WITH-YOUR-USER-POOL-ID|${$user_pool_id}|g" "$file_path"

echo "User Pool ID updated in $file_path"

######################################################33

echo "Please enter your App Client ID:"
read user_client_id


# Use sed to replace the line containing 'UserPoolId: REPLACE-WITH-YOUR-USER-POOL-ID'
sed -i "s/REPLACE-WITH-YOUR-CLIENT-ID/${$user_client_id}/g" "$file_path"

echo "App Client ID updated in $file_path"

######################################################33

# Prompt the user for the Cognito Domain
echo "Please enter your Cognito Domain:"
read cognito_domain

# Prompt the user for the EC2 IPv4 URL
echo "Please enter your EC2 IPv4 URL: (e.g. ec2-44-223-155-81.compute-1.amazonaws.com)"
read ec2_domain

# Define the file path of getMessage.js
file_path_message="/var/www/html/scripts/settings.js"

sed -i "s|REPLACE-WITH-COGNITO-URL|${cognito_domain}|g; \
        s|REPLACE-WITH-EC2-URL|https%3A%2F%2F${ec2_domain}|g" "$file_path_message"

echo "Hosted UI updated in $file_path_message"


rm $0
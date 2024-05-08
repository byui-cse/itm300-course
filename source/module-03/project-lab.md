---
title: Module 03: Project 3 Lab - Connect with Cognito
body-class: index-page
---

![Quick Oil Change and Repair]({{URLROOT}}/shared/img/quick-logo.jpg)
*[Photo by Dall-E-3](https://openai.com/dall-e-3)*

## Product Objective

You will be connecting your website with AWS Cognito. Cognito will allow you to register users, store usernames and passwords, and login and logout. For this lab we'll be creating cognito user pool, create users, learn about the hosted UI, and connect the website to cognito to allow us to get a JWT token after authenticating with cognito.


## Open up the lab evironment

Go to AWS Academy and get into the "Learner Lab" course. Start up the Learner Lab and go to the AWS console by clicking on the green dot when it appears.


## Create a User Pool

We'll first create a user pool which will store all of our users.

Search for Cognito in AWS.
Click on Create User Pool
Don't click Federated identity providers
Choose User Name under Cognito user pool sign-in options
    You could store more user details, but for our example we'll simply be storing usernames and passwords.

User the cognito defaults
No MFA
    Using Multifactor Authentication is more secure and would normally be enabled in a production environment
Uncheck Cognito user pool sign-in options

Uncheck Enable self-registration
    We are going to manually add users, which are just the administrators of the application.
Leave all other defaults

Choose Send email with Cognito

Give the User Pool a name of VehicleAppUserPool
Check Use the Cognito Hosted UI
Choose a unique hosted URL name ()
Choose Other for App type
Choose a unique name for your app (e.g. Vehicle App - Quick)
Add the following to the allowed callback urls: http://localhost:5500, http://localhost:3000, and your website's NIP.IO address.

!!! info "Your nip.io address"

    To get your nip.io address, open a tab with your EC2 instance that you created last week. Find the IPv4 address that has been assigned to your instance. You'll use this address to create your nip.io address:

    If my IPv4 address was 1.2.3.4, you would replace all periods with dashes and add .nip.io to the end of the address like this: 1-2-3-4.nip.io.

    You'll then use this address in the Allowed Callback URLs: https://1-2-3-4.nip.io
    (Make sure you update this to your address)

## Create a User

Once your user pool is created, scroll down to where you see users and click Create User

Don't send an invite
Create a user named janedoe
Password: ILove2SeeTheTemple!

You'll notice that the user has a confirmation status of Force change password. We will go update their status by logging in to the hosted UI.

## Explore the Hosted UI

Click on the tab App Integration
Scroll to the bottom of the screen and click on VehicleApp

Scroll down until you see View Hosted UI and click on it.

The Hosted UI will open in a new tab. We could use this interface for our user login page. However, we will be using an API call to authenticate with Cognito to give the user a more unified experience with the website.

## Update Password for User

Log in as janedoe
You'll see that you are promped with a Change Password prompt.
Update your password to Ilove2SeeTheTemple!!

You'll notice that it will try to send you back to localhost:5500. This was the first allowed callback URL.

## Connect with our APP




## Update the App logic

Download the newest website app:

```
sudo dnf install -y wget
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-03/quick-oil-part3.zip
mkdir /tmp/lab-app
sudo rm -rf /var/www/html/
unzip quick-oil-part3.zip -d /tmp/lab-app
mv /tmp/lab-app/quick-oil-part3/* /var/www/html
rm -rf /tmp/lab-app/
```
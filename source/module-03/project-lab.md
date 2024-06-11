---
title: Module 03: Project 3 Lab - Connect with Cognito
body-class: index-page
---

![Quick Oil Change and Repair]({{URLROOT}}/shared/img/quick-logo-login.jpg)
*[Photo by Dall-E-3](https://openai.com/dall-e-3)*

## Product Objective

You will be connecting your website with AWS Cognito. Cognito will allow you to register users, store usernames and passwords, and login and logout. For this lab we'll be creating Cognito user pool, create users, learn about the hosted UI, and connect the website to Cognito to allow us to get a JWT token after authenticating with Cognito.


## Open up the lab evironment

Go to AWS Academy and get into the "Learner Lab" course. Start up the Learner Lab and go to the AWS console by clicking on the green dot when it appears.


## Create a User Pool

We'll first create a user pool which will store all of our users.

!!! key "Security Concerns"

    We will be creating a very simple setup. There are many more options that can be enabled to enhance the security of the app. This tutorial will cover basics to get you exposure to the concepts. In a production app, you'd want to enable more of the security features.

    It is recommended that you play around with different options after you get the tutorial completed to expand your knowledge and understanding of the options available.

* Search for Cognito in AWS.
* Click on <span class="amz-orange-button">Create User Pool</span>
* Don't check Federated identity providers
* Choose User Name under Cognito user pool sign-in options
    * You could store more user details, but for our example we'll simply be storing usernames and passwords.
* Click <span class='amz-orange-button'>Next</span>
* Use the cognito password defaults
* Select No MFA
    * Using Multifactor Authentication is more secure and would normally be enabled in a production environment
* Uncheck Allow User Self-Recovery
* Click <span class='amz-orange-button'>Next</span>

* Uncheck Enable self-registration
    * We are going to manually add users, which are just the administrators of the application.
* Leave all other defaults
* Click <span class='amz-orange-button'>Next</span>

* Choose Send email with Cognito
* Click <span class='amz-orange-button'>Next</span>

* Give the User Pool a name of VehicleAppUserPool
* Check Use the Cognito Hosted UI
* Choose a unique hosted URL name under **Cognito domain**
* Choose Other for App type
* Choose a unique name for your app (e.g. Vehicle App - Quick)
* Add the following to the allowed callback urls: your website's Public IPv4 DNS address. (Get this from your EC2 instance details page)
* <span class='amz-white-button'>Advanced App client Settings<span class="material-symbols-outlined">arrow_drop_down</span></span>: Make sure that Allow_User_SRP_Auth is Checked
* From OAuth 2.0 grant types Remove Authorization Code Grant and add Implicit Grant
* Click <span class='amz-orange-button'>Next</span>
* Click <span class='amz-orange-button'>Create user pool</span>

## Create a User

Once your user pool is created, scroll down to where you see users and click <span class="amz-white-button">Create user</span>

* Don't send an invite
* Create a user named janedoe
* Password: ILove2SeeTheTemple!

You'll notice that the user has a confirmation status of Force change password. We will go update their status by logging in to the hosted UI.

## Explore the Hosted UI

* Click on the tab <span class="amz-tab">App Integration</span>
* Scroll to the bottom of the screen and click on <span class="amz-link">VehicleApp</span>

* Scroll down until you see <span class="amz-white-button">View Hosted UI</span> and click on it.

The Hosted UI will open in a new tab. We could use this interface for our user login page. However, we will be using an API call to authenticate with Cognito to give the user a more unified experience with the website.

## Update Password for User

Log in as janedoe.

You'll see that you are promped with a Change Password prompt.

Update your password to Ilove2SeeTheTemple!!

You'll notice that it will open up your app since this was the first allowed callback URL.


## Update the App logic

<span class="amz-white-button">Connect</span> to your Vehicle App EC2 Instance

Download the newest website app:

```
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-03/rebuildapp.sh
```

```
chmod +x ./rebuildapp.sh
```

Next run the script which will download the newest files. It will also ask you to enter the user pool id as well as the client id for the app. You'll need to paste these into the terminal when prompted.


```
sudo bash ./rebuildapp.sh
```


<!-- ```
sudo dnf install -y wget
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-03/quick-oil-part3.zip
mkdir /tmp/lab-app
sudo rm -rf /var/www/html/*
unzip quick-oil-part3.zip -d /tmp/lab-app
mv /tmp/lab-app/quick-oil-part3/* /var/www/html
rm -rf /tmp/lab-app/
``` -->

Visit your Public IPv4 DNS address in a new tab to make sure the website is running

<!-- ## Connect with our APP

You'll need to make a few changes to the code to connect your app to the cognito user pool you just created. -->

<!-- Using whatever text editor you like, or optionally after installing cloud9, go out and update the following files:

In /var/www/html/scripts/login.js update line 23 and 24 **UserPoolId** and **ClientId**. These values can be found from the Cognito user pool information. -->
<!-- 
In /var/www/html/scripts/getMessage.js update line 10 **hostedUI**. For this value, you'll need to copy the Hosted UI link and then make a few modifications to it.

Here is an example link: 

```
https://vehicleappname.auth.us-east-1.amazoncognito.com/oauth2/authorize?client_id=3dhpqb95cm2nmutoh3vmpbqsva&response_type=code&scope=email+openid+phone&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2F
```

You'll update it so that it has the following:

* Your Cognito Domain (Found under app integration tab): https://vehicleappname.auth.us-east-1.amazoncognito.com/
* oauth2/authorize? (this stays the same for everyone)
* client_id=YOUR-CLIENT-ID-GOES-HERE
* &response_type=token
* &scope=email+openid+phone
* &redirect_uri=https://ec2-14-223-155-86.compute-1.amazonaws.com (This is your IPv4 domain name)

I would end up with something like this:

```
https://vehicleappname.auth.us-east-1.amazoncognito.com/oauth2/authorize?client_id=3dhpqb95cm2nmumoh7smpbqsva&response_type=token&scope=email+openid+phone&redirect_uri=https://ec2-14-223-155-86.compute-1.amazonaws.com
``` -->

## Log in

Once you've connected everything, you can log in.

* Go to the login page of your website. 
* Enter the username and password.

If you are successful, it will bring you to the private.html page and say "thank you for Logging in". If you have a username or password error, it will take you back to the login page and ask you to login. If you haven't updated your password, it will give you a message that says you need to go to the hosted ui and update your password.

The error console should also give you further ideas if something isn't working correctly.


## Lab Summary:

In this lab, the objective was to integrate with AWS Cognito to handle user authentication and authorization. The lab covered the creation of a Cognito user pool, manual user creation, exploration of the Cognito hosted UI, updating user passwords, and integrating the website with Cognito for user authentication using JWT tokens.

### Key Concepts Explained:

1. **AWS Cognito:** AWS Cognito is a fully managed authentication service provided by Amazon Web Services. It allows developers to add user sign-up, sign-in, and access control to web and mobile apps quickly and securely. In this lab, a Cognito user pool named *VehicleAppUserPool* was created to store user credentials and manage user authentication.
1. **Cognito User Pool:** A Cognito user pool is a user directory used to manage user identities and authentication workflows for applications. In this lab, the user pool was configured to allow user registration and sign-in using usernames and passwords. Additional security features like MFA (Multi-Factor Authentication) and self-registration were disabled for simplicity.
1. **Hosted UI:** The Cognito hosted UI provides a customizable authentication interface for user login and registration. Users can interact with the hosted UI to sign in and perform password-related actions, such as changing passwords. In this lab, the hosted UI was used to update a user's password interactively.
1. **JWT Token Authentication:** After successful authentication with Cognito, users receive a JWT (JSON Web Token) that can be used to authenticate subsequent API requests to protected resources. This token-based authentication mechanism ensures secure access control to application features based on user identity.

### Reflection Questions:

* Discuss the role of AWS Cognito in modern application development. How does Cognito simplify user authentication and authorization workflows for developers?
* Explain the purpose of a Cognito user pool. What types of user-related data can be stored in a user pool, and how does Cognito handle user authentication and identity management?
* Describe the benefits of using a hosted UI provided by Cognito for user authentication. How can developers customize the hosted UI to match the look and feel of their applications?
* Reflect on the importance of JWT tokens in securing web applications. How does token-based authentication work, and why is it preferred over traditional session-based authentication in distributed systems?
* Explore the security considerations when implementing user authentication with AWS Cognito. What additional security features can be enabled in a production environment to enhance user privacy and data protection?
* Discuss the challenges and best practices for integrating a website with AWS Cognito. What are some common troubleshooting steps when encountering authentication-related issues during development and deployment?
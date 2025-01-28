---
title: Module 03: Product 3 Lab - Connect with Cognito
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

* <span class="material-symbols-outlined">search</span> Search for Cognito in AWS.

* <span class='amz-orange-button'>Get started for free in less than five minutes</span>
* Choose **Single-page application (SPA)**
* Name your application: VechicleApp
* Choose Username under Cognito user pool sign-in options
    * You could store more user details, but for our example we'll simply be storing usernames and passwords.
* Required attributes for sign-up
    * email
* Add a return URL: 
    * Open a new tab with your EC2 instance. 
    * Click the checkmark next to your vehicleapp-1 instance
    * Copy the Public IPv4 DNS found under Details
    * Return back to the URL paste your **Public IPv4 DNS** after the https://
    * example: https://ec2-44-195-176-112.compute-1.amazonaws.com
* <span class='amz-orange-button'>Create</span>

* Go to overview

* Click VehicleApp in **Set up your app** : VehicleApp

* Click edit
* Check "Sign in with username and password: ALLOW_USER_PASSWORD_AUTH
(make sure that ALLOW_USER_AUTH and ALLOW_USER_SRP_AUTH are checked as well)
* <span class='amz-orange-button'>Save changes</span>

* Click on <span class='amz-tab'>Login pages</span>
* <span class='amz-blue-outline-button'>Edit</span>

* OAuth 2.0 grant Types: 
    * Remove Authorization Code Grant
    * Add Implicit Grant
<span class='amz-orange-button'>Save Changes</span>


## Create a User
<span class='amz-tab'>Users</span> on left hand side

Once your user pool is created, scroll down to where you see users and click <span class="amz-blue-outline-button">Create user</span>

* Don't send an invite
* Create a user named janedoe
* Password: **ILove2SeeTheTemple!**

You'll notice that the user has a confirmation status of Force change password. We will go update their status by logging in to the hosted UI.

Click on <span class='amz-white-button'>App Clients</span> on the left hand menu

Click on <span class='amz-link'>VehicleApp</span>

<span class='amz-white-button'>View login page</span>

## Explore the Hosted UI

The Hosted UI will open in a new tab. We could use this interface for our user login page. However, we will be using an API call to authenticate with Cognito to give the user a more unified experience with the website.

## Update Password for User

Log in as janedoe.

You'll see that you are promped with a Change Password prompt.

youremail@byui.edu

Update your password to **Ilove2SeeTheTemple!!**

You'll notice that it will open up your app since this was the first allowed callback URL.

<span class='amz-tab'>Sign-in</span> on the left hand side 

* Click <span class='amz-blue-outline-button'>edit</span> under User account recovery
* Disable self-service account recovery
* <span class='amz-orange-button'>Save changes</span>

Click <span class='amz-tab'>Sign-up</span> on the left hand side

Click <span class='amz-blue-outline-button'>edit</span> under Self-service sign-up

* Disable self-registration

<span class='amz-orange-button'>Save changes</span>



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

User pool ID is found in your cognito user pool <span class='amz-tab'>overview</span>.

Client ID is found in cognito under <span class="amz-tab">App clients</span> in the App client information.

Cognito domain is found in cognito under <span class="amz-tab">Authentication methods</span> in the passkey section in Cognito prefix domain. 


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

The [website error console](https://documentation.concretecms.org/tutorials/how-open-browser-console-view-errors){:target="_blank"} should also give you further ideas if something isn't working correctly.


## CloudTrail

We'll now go activate CloudTrail that will keep track of all API calls that happen on our account. We can use this to see successful and failed login attempts.

!!! def "CloudTrail and Auditing"

    Using AWS CloudTrail to audit login attempts is essential for maintaining the security and compliance of your cloud environment. By tracking and analyzing both successful and failed login attempts through Amazon Cognito, organizations can detect unauthorized access, identify potential security threats, and ensure that only authorized users are accessing sensitive resources. This continuous monitoring helps in complying with regulatory requirements, enables forensic investigations in case of security incidents, and provides valuable insights into user behavior, thereby enhancing the overall security posture and operational integrity of the cloud infrastructure.

* <span class="material-symbols-outlined">search</span>Search for Cloudtrail
* <span class='amz-orange-button'>Create a trail</span>
* Trail name: **VehicleApp-Trail**
* Create a new S3 bucket

Once you've created your CloudTrail, click on <span class='amz-white-button'>Event history</span> on the left hand panel.

* Change Lookup attributes to **Event source**
* In the *Enter an event source* type in **cognito-idp.amazonaws.com**
* You should see a <span class='amz-link'>Initiate Auth</span> and a <span class='amz-link'>ResponseToAuthChallenge</span> in the list. You can click on the response to see if a login was successful or not.

Failed Login Attempt includes an errorCode and errorMessage

<div class="results">
"userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:127.0) Gecko/20100101 Firefox/127.0",
"errorCode": "NotAuthorizedException",
"errorMessage": "Incorrect username or password.",
</div>

Successful Login Attempt includes a accessToken

<div class="results">
"responseElements": {
    "challengeParameters": "HIDDEN_DUE_TO_SECURITY_REASONS",
    "authenticationResult": {
        "accessToken": "HIDDEN_DUE_TO_SECURITY_REASONS",
        "expiresIn": 3600,
        "tokenType": "Bearer",
        "refreshToken": "HIDDEN_DUE_TO_SECURITY_REASONS",
        "idToken": "HIDDEN_DUE_TO_SECURITY_REASONS"
    }
},
</div>

When you are completed, submit a screenshot of you logged in to your app.


## Lab Summary:

In this lab, the objective was to integrate with AWS Cognito to handle user authentication and authorization. The lab covered the creation of a Cognito user pool, manual user creation, exploration of the Cognito hosted UI, updating user passwords, and integrating the website with Cognito for user authentication using JWT tokens.

### Key Concepts Explained:

1. **AWS Cognito:** AWS Cognito is a fully managed authentication service provided by Amazon Web Services. It allows developers to add user sign-up, sign-in, and access control to web and mobile apps quickly and securely. In this lab, a Cognito user pool named *VehicleAppUserPool* was created to store user credentials and manage user authentication.
1. **Cognito User Pool:** A Cognito user pool is a user directory used to manage user identities and authentication workflows for applications. In this lab, the user pool was configured to allow user registration and sign-in using usernames and passwords. Additional security features like MFA (Multi-Factor Authentication) and self-registration were disabled for simplicity.
1. **Hosted UI:** The Cognito hosted UI provides a customizable authentication interface for user login and registration. Users can interact with the hosted UI to sign in and perform password-related actions, such as changing passwords. In this lab, the hosted UI was used to update a user's password interactively.
1. **JWT Token Authentication:** After successful authentication with Cognito, users receive a JWT (JSON Web Token) that can be used to authenticate subsequent API requests to protected resources. This token-based authentication mechanism ensures secure access control to application features based on user identity.
1. **AWS CloudTrail** is a service that enables governance, compliance, and operational and risk auditing of your AWS account. It records AWS API calls and related events made by or on behalf of your AWS account and delivers the log files to an Amazon S3 bucket. These logs provide a detailed history of AWS API calls, including the identity of the caller, the time of the call, the source IP address, the request parameters, and the response elements. This detailed event history is crucial for tracking changes, conducting security analysis, troubleshooting operational issues, and ensuring regulatory compliance.

### Reflection Questions:

* Discuss the role of AWS Cognito in modern application development. How does Cognito simplify user authentication and authorization workflows for developers?
* Explain the purpose of a Cognito user pool. What types of user-related data can be stored in a user pool, and how does Cognito handle user authentication and identity management?
* Describe the benefits of using a hosted UI provided by Cognito for user authentication. How can developers customize the hosted UI to match the look and feel of their applications?
* Reflect on the importance of JWT tokens in securing web applications. How does token-based authentication work, and why is it preferred over traditional session-based authentication in distributed systems?
* Explore the security considerations when implementing user authentication with AWS Cognito. What additional security features can be enabled in a production environment to enhance user privacy and data protection?
* Discuss the challenges and best practices for integrating a website with AWS Cognito. What are some common troubleshooting steps when encountering authentication-related issues during development and deployment?
# Cognito Example

## Create a new react app

    npx create-react-app my-app
    cd my-app

First, install the required dependencies:

    npm install amazon-cognito-identity-js

Next, update the file called App.js with the following code:

    import React, { useState } from 'react';
    import { CognitoUserPool, AuthenticationDetails, CognitoUser } from 'amazon-cognito-identity-js';

    const poolData = {
    UserPoolId: 'YOUR_USER_POOL_ID',
    ClientId: 'YOUR_CLIENT_ID',
    };

    const userPool = new CognitoUserPool(poolData);

    function App() {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [loggedIn, setLoggedIn] = useState(false);

    const handleLogin = async () => {
        const authDetails = new AuthenticationDetails({
        Username: username,
        Password: password,
        });

        const userData = {
        Username: username,
        Pool: userPool,
        };

        const cognitoUser = new CognitoUser(userData);

        cognitoUser.authenticateUser(authDetails, {
        onSuccess: () => {
            setLoggedIn(true);
        },
        onFailure: (err) => {
            console.error('Login failed:', err);
        },
        });
    };

    return (
        <div>
        <h1>AWS Cognito Login</h1>
        {loggedIn ? (
            <div>You are logged in!</div>
        ) : (
            <div>
            <input
                type="text"
                placeholder="Username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
            />
            <input
                type="password"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
            />
            <button onClick={handleLogin}>Login</button>
            </div>
        )}
        </div>
    );
    }

    export default App;


In this example, we import the required components from amazon-cognito-identity-js. We then set up the poolData object with our Cognito User Pool ID and Client ID.

Inside the App component, we have state variables for username, password, and loggedIn. The handleLogin function is responsible for authenticating the user with Cognito. It creates an AuthenticationDetails object with the provided username and password, and then creates a CognitoUser object with the user data and the user pool.

We call the authenticateUser method on the CognitoUser object, passing in the AuthenticationDetails and callback functions for success and failure cases. If the authentication is successful, we set the loggedIn state to true.

In the JSX, we conditionally render the login form or a success message based on the loggedIn state.

Make sure to replace 'YOUR_USER_POOL_ID' and 'YOUR_CLIENT_ID' with your actual Cognito User Pool ID and Client ID.

Please note that this is a basic example, and you may need to handle additional scenarios like user signup, password reset, and refresh tokens depending on your requirements.

    npm start


### Go to AWS Cognito

1) Create User Pool

Cognito User Pool Options
1) User Name select
Next

Password Policy mode
Cognito Defaults

No MFA

Self-service account recovery
Uncheck

Self-service Signup
Uncheck

Look at additional required attributes, but don't check any

Email
Send email with cognito

User Pool Name
VehicleApp

Hosted Authentication pages
Check

Cognito Domain
VehicleAppYourName

App Client Name
Vehicle App

URL
http://localhost:3000/

Next
Create User Pool

Copy User Pool ID onto line 5 of App.js

Click the User Pool Name
Click App Integration
Scroll to the bottom of the page and copy the client id
Paste it into line 6.

Click VehicleApp
Click View Hosted UI (This will open a new tab, go back to the first tab)

Click Vehicle App at the top of the page
Click Users

Create User
Username

JaneDoe
JaneDoe1!
Create User

Click on janedoe
Notice it requires a new password.

Click on the Cognito UI
Log in
It should give you a change password. Change the password to JaneDoe2!

It should redirect you to the app

Log in with the new credentials

You should see "You are logged in!"

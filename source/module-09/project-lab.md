---
title: Module 09: Product 9 Lab - Vehicle History Update
body-class: index-page
---

![Quick Oil Change and Repair]({{URLROOT}}/shared/img/quick-logo-vehicle-history.jpg)

## Product Objective

Technicians have quested to be able to see past repair history for the vehicles. We'll be adding this new feature to the app.

## Create new lambda function

Create a new lambda function

* **Function Name:** adminVehicleHistory
* Runtime: Node.js (latest version)
* Open <span class='amz-white-button'><span class="material-symbols-outlined">arrow_right</span> Change default execution role</span>
* Use an existing role
* **Existing Role:** LabRole
* <span class='amz-orange-button'>Create Function</span>

Update the *index.mjs* code

```
import { getVehicleHistory } from './adminVehicleHistory.mjs';

const commonHeaders = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Headers': 'Content-Type',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'OPTIONS,POST,GET,PUT'
};

export const handler = async (event) => {
  try {
    
    const httpMethod = event.httpMethod;
    const path = event.path;
    const resource = event.resource;
    const pathParameters = event.pathParameters;
    const queryParameters = event.queryStringParameters;
    const requestBody = event.body ? JSON.parse(event.body) : null;    
    let jsonArray = [];

    switch (httpMethod) {
      case "GET":  
        if(pathParameters && pathParameters.id){
          jsonArray = await getVehicleHistory(pathParameters.id);
          // jsonArray = {message:"Yep"};
        }
        else {
          jsonArray = {message:"No Plate Provided"};
        }
        break;

    }
    
    const response = {
      statusCode: 200,
      body: JSON.stringify(jsonArray),
      headers: commonHeaders
    };
    return response;
  } catch (error) {
    console.error('Error:', error);
    const response = {
      statusCode: 500,
      body: JSON.stringify({ message: 'Internal Server Error' }),
      headers: commonHeaders
    };
    return response;
  }
};
```

Create a new file *adminVehicleHistory.mjs* and update it with this code

```
import { SNSClient, PublishCommand } from "@aws-sdk/client-sns"; // ES Modules import
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  QueryCommand,
  PutCommand,
  GetCommand,
  DeleteCommand,
  UpdateCommand,
} from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});

const mydynamodb = DynamoDBDocumentClient.from(client);

const tableName = "VehicleServices";    

export const getVehicleHistory = async (license_plate) => {
    try {
        const params = {
            TableName: tableName,
            KeyConditionExpression: "#license_plate = :license_plate",
            ExpressionAttributeNames: {
                "#license_plate": "license_plate"
            },
            ExpressionAttributeValues: {
                ":license_plate": license_plate
            }
        };      
        const body = await mydynamodb.send(new QueryCommand(params));
        return body.Items; // Return JSON string of items
    } catch (error) {
        console.error("Error fetching DynamoDB service requests:", error);
        throw error; // Re-throw the error to handle it further up the call stack
    }
}
```

Click <span class='amz-white-button'>Deploy</span>

## Update the API Gateway

<span class="material-symbols-outlined">search</span> Search for API Gateway

We'll create two resources. The first is the main area for vehicle-history

* Click on /admin-service-request
* Click <span class='amz-white-button'>Create resource</span>
* **Resource Name**: vehicle-history
* Turn on CORS
* <span class='amz-orange-button'>Create resource</span>

Now we'll create the second that will respond for specific histories based on license plate number.

* Click on /vehicle-history
* Click <span class='amz-white-button'>Create resource</span>
* **Resource Name**: {id}
* Turn on CORS
* <span class='amz-orange-button'>Create resource</span>

You should have /vehicle-history/{id} selected. We'll now create the GET method.

* Click <span class='amz-white-button'>Create method</span>
* **Method type:** GET
* Lambda Function
* Activate Lambda proxy integration
* **lambda function:** adminVehicleHistory
* Open <span class='amz-white-button'><span class="material-symbols-outlined">arrow_right</span> Method Request Settings</span>
* **Authorization:** AdminServiceRequestAuthorizer
* <span class='amz-orange-button'>Create method</span>

<span class='amz-orange-button'>Deploy API</span> (this may take a couple of minutes)

## Update code

<span class='amz-white-button'>Connect</span> to your Vehicle App EC2 Instance

Download the newest website app:

```
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-09/rebuildapp.sh
```

```
chmod +x ./rebuildapp.sh
```

Next run the script which will download the newest files. 

```
sudo bash ./rebuildapp.sh
```

!!! note "Password"

    You can use the credentials you created earlier for janedoe

    Username: **janedoe**
    
    Password: **Ilove2SeeTheTemple!!**

    If you changed your username or password then use those instead.

Now when you log in to your app you should have an area that will allow you to search for vehicle histories based on license plate number. Also, the license plate numbers in the current service requests will also be linked to quickly go to the vehicle histories.

## Summary

In this lab, students added a new feature to an existing AWS-based application, enabling technicians to view the repair history of vehicles. This involved creating a new AWS Lambda function, setting up appropriate resources in the API Gateway, and updating the application code. The lab walked through creating and configuring the Lambda function, updating the API Gateway to handle new endpoints, and deploying the changes to the application.

## Code Review

Take a minute and review the lambda function code that you added. Identify what is happening with the code. If you don't understand a line of code, use an AI resource like chatGPT to dig into what the code is doing by asking questions until you understand the code.

Review the code found in the /var/www/html folder. Specifically look at the following code:

* vehicle-history.html
* scripts/vehicle-requests.js
* scripts/vehicleHistoryHelper.js

How does this code interact with the lambda functions that were created in the lab? Identify any code that you do not understand and research it using generative AI.

## Reflection Questions

* **Technical Understanding:** What are the advantages of using AWS Lambda for serverless computing? How does the integration of API Gateway with Lambda functions enhance the capabilities of web applications?
* **Application and Deployment:** What challenges might arise when deploying new features to an existing application in a production environment? How do the changes in the API Gateway configuration affect the application's functionality and security?
* **Database Interactions:** Why is DynamoDB a suitable choice for storing vehicle service records? Why might you choose a NoSQL database over a relational database? What considerations should be made when querying a DynamoDB table for performance optimization?
* **Security and Access Management:** Why is it important to specify an authorization method, like AdminServiceRequestAuthorizer, for API Gateway methods?
* **Practical Experience:** What was the most challenging part of setting up and testing the new Lambda function and why? How would you improve the process of updating and deploying new features in a cloud-based application?
* **Rapid Development and Deployment of New Features** How does the use of AWS services like Lambda and API Gateway facilitate the rapid development and deployment of new features, and what strategies can be employed to ensure that these rapid changes do not introduce bugs or security vulnerabilities into the production environment? What should we consider when thinking about the balance between speed and quality in software development, particularly in the context of using serverless and managed services.
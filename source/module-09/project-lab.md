---
title: Module 09: Project 9 Lab - SNS & SQS Workflow
body-class: index-page
---

![Quick Oil Change and Repair]({{URLROOT}}/shared/img/sns_sqs.jpg)

## Product Objective

Technicians have quested to be able to see past repair history for the vehicles. We'll be adding this new feature to the app.

## Create new lambda function

Create a new lambda function

* **Function Name:** adminVehicleHistory
* Open Change Default Execution Role
* Use an existing role
* **Existing Role:** LabRole
* Create Function

Update the index.mjs code

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

Click Deploy

## Update the API Gateway

Search for API Gateway

We'll create two resources. The first is the main area for vehicle-history

* Click on /admin-service-request
* Click Create resource
* **Resource Name**: vehicle-history
* Turn on CORS
* Create resource

Now we'll create the second that will respond for specific histories based on license plate number.

* Click on /vehicle-history
* Click Create resource
* **Resource Name**: {id}
* Turn on CORS
* Create Resource

You should have /vehicle-history/{id} selected. We'll now create the GET method.

* Click Create method
* **Method type:** GET
* Lambda Function
* Lambda proxy integration
* **lambda function:** adminVehicleHistory
* Open Method Request Settings
* **Authorization:** AdminServiceRequestAuthorizer

DEPLOY (this make take a couple of minutes)

## Update code

Connect to your Vehicle App EC2 Instance

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

Now when you log in to your app you should have an area that will allow you to search for vehicle histories based on license plate number. Also, the license plate numbers in the current service requests will also be linked to quickly go to the vehicle histories.



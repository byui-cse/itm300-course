---
title: Module 06: Project 6 Lab - Writing to DynamoDB
body-class: index-page
---

![Quick Oil Change and Repair]({{URLROOT}}/shared/img/quick-logo-service-requests.jpg)
*[Photo by Dall-E-3](https://openai.com/dall-e-3)*

## Product Objective

For this lab we'll handle requests from our app to put service requests into the dynamodb we created last week.


## Instructions

### Add a Post method to the API Gateway

* Create method under the /service-request resource
* Method type: Post
* Lambda proxy integration checked
* Lambda function: getServiceRequests
* Create Method

Deploy the API

### Update lambda code

dynamoService.mjs

```
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  ScanCommand,
  PutCommand,
  GetCommand,
  DeleteCommand,
} from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});

const mydynamodb = DynamoDBDocumentClient.from(client);

const tableName = "VehicleServices";    

export const getDynamoServiceRequests = async () => {
    const statusToExclude = "Completed";
    const statusToExcludeNew = "New Request";
    try {
        const params = {
            TableName: tableName,
            FilterExpression: "attribute_not_exists(service_status) OR (#service_status <> :status AND #service_status <> :statusNew)",
            ExpressionAttributeNames: {
                "#service_status": "service_status"
            },
            ExpressionAttributeValues: {
                ":status": statusToExclude,
                ":statusNew": statusToExcludeNew
            }
        };      
        const body = await mydynamodb.send(new ScanCommand(params));
        return body.Items; // Return JSON string of items
    } catch (error) {
        console.error("Error fetching DynamoDB service requests:", error);
        throw error; // Re-throw the error to handle it further up the call stack
    }
}

export const addDynamoServiceRequest = async (requestBody) => {
  try {
    const serviceId = generateServiceId(); // Generate unique service_id based on current date and time      
    const params = {
      TableName: tableName,
      Item: {
        service_id: serviceId, // Assuming service_id is provided in requestBody
        service_status: "New Request",
        service_description: requestBody.service_description,
        phone_number: requestBody.phone_number,
        license_plate: requestBody.license_plate ?? "Unknown", // Use requestBody.license_number or default to "Unknown"
      },
    };

    await mydynamodb.send(new PutCommand(params));

    return `Successfully added new service request`;
  } catch (error) {
    console.error("Error adding DynamoDB service request:", error);
    throw error; // Re-throw the error to handle it further up the call stack
  }
};



// Helper function to generate a unique service_id based on current date and time
const generateServiceId = () => {
  const now = new Date();
  const formattedDate = now.toISOString().replace(/[-T:.Z]/g, ""); // Format date string
  const milliseconds = now.getMilliseconds().toString().padStart(3, "0"); // Get milliseconds and pad with leading zeros if necessary
  return `${formattedDate}${milliseconds}`; // Concatenate date and milliseconds
};
```

index.mjs code

```

import { getServiceRequests } from './dataService.mjs';
import { getDynamoServiceRequests, addDynamoServiceRequest } from './dynamoService.mjs';

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
        jsonArray = await getDynamoServiceRequests();
        break;
      case "POST":
        console.log("posting");
        jsonArray = await addDynamoServiceRequest(requestBody);
        // jsonArray = "Posted";
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


### Update App Code

Connect to your Vehicle App EC2 Instance

Download the newest website app:

```
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-06/rebuildapp.sh
```

```
chmod +x ./rebuildapp.sh
```

Next run the script which will download the newest files. You'll be prompted to enter the invoke URL. Get the invoke URL from your API Gateway:

* Click Stages on the left bar
* Under stage details find Invoke URL and copy that address
* Paste that as the Invoke URL when prompted


```
sudo bash ./rebuildapp.sh
```



Once you've updated the files, you should visit your app and add a service request. Send a screenshot of your successful addition. The service request won't show up automatically on the website. We will require administrators to approve the service request before it shows up. Your screenshot should just have the success message showing at the top of the request form.
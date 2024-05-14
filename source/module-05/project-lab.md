---
title: Module 05: Project 5 Lab - DynamoDB
body-class: index-page
---

![Quick Oil Change and Repair]({{URLROOT}}/shared/img/quick-logo-service-requests.jpg)
*[Photo by Dall-E-3](https://openai.com/dall-e-3)*

## Product Objective

You will be creating a dynamodb table that will store service requests. We will also update our lambda function to pull from the database.


## Instructions

We will do two main steps in this lab. First we will create a dynamodb table. This is where we will store future service requests and information about vehicles.

Second, we'll update the lambda function to read from the dynamodb table to pull in the information.

## Create a DynamoDB table

Search for DynamoDB in AWS

* Create table

* Table Name: **VehicleServices**

* Partition Key: **license_plate** (String)
* Sort Key: **service_id** (String)

* Customize Settings
* Capacity mode: On-demand

* Secondary Indexes: Create global index
  * Global Secondary Index:
    * Index Name: StatusIndex
      * Partition Key: service_status (String)
      * Sort Key: license_plate (String)
  * Create Index

* Create Table

Wait for the Status to be: Active

* Click on VehicleServices

* Actions -> Create Item
  * license_plate: 8B1111
  * service_id: 1
  * Add new attribute (String): phone_number: 208-444-5555
  * Add new attribute (String): service_description: Oil Change on a 2007 Saturn Outlook
  * Add new attribute (String): service_status: Finishing up
  * Create item

## Update Lambda

Search for Lambda and open your getServiceRequests lambda function

* Under Code -> Right click on getServiceRequests and choose New File
* Name it dynamoService.mjs
* Paste the following code into that file:


```
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  ScanCommand,
  PutCommand,
  GetCommand,
  DeleteCommand,
} from "@aws-sdk/lib-dynamodb";

export const getDynamoServiceRequests = async () => {
    const client = new DynamoDBClient({});
    
    const mydynamodb = DynamoDBDocumentClient.from(client);
    
    const tableName = "VehicleServices";    
    const statusToExclude = "Completed";
    try {
        const params = {
            TableName: tableName,
            FilterExpression: "attribute_not_exists(service_status) OR #service_status <> :status",
            ExpressionAttributeNames: {
                "#service_status": "service_status"
            },
            ExpressionAttributeValues: {
                ":status": statusToExclude
            }
        };      
        const body = await mydynamodb.send(new ScanCommand(params));
        return body.Items; // Return JSON string of items
    } catch (error) {
        console.error("Error fetching DynamoDB service requests:", error);
        throw error; // Re-throw the error to handle it further up the call stack
    }
}
```

We will replace the previous dataService with the new dynamoService.

* Add this line to the top of the index.js file:

```
import { getDynamoServiceRequests } from './dynamoService.mjs';
```

* Change the name of the function being called
* Replace     const jsonArray = await getServiceRequests(); with

```
const jsonArray = await getDynamoServiceRequests();
```

Click Deploy and then Test the deployment. You should only see the single response in the body instead of the three hardcoded items we had before.

Go to the website and verify that you are getting a single ticket back.

## Add information to the database

Go back to the dynamodb table and click "explore table items"
Click run. Down below it should return the 8B1111 item

Click the checkbox next to 8B1111. 
Click Actions->Duplicate Item

Update the values on this page to this:

* license_plate: 1J1957
* service_id: 2
* phone_number: 208-867-5309
* service_description: Brakes for a 08 Mazda 6
* status: New Request

Click create item

Go back to the website and you should see both items under service request.

## Update a vehicle

Go update the value of the service_status of the 8B1111 vehicle to have a service_status of Completed

Go view the website and you should only see one service request.
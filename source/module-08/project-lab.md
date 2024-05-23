---
title: Module 08: Project 8 Lab - Messages
body-class: index-page
---

![Quick Oil Change and Repair]({{URLROOT}}/shared/img/quick-logo-fancy-service-requests.jpg)
*[Photo by Dall-E-3](https://openai.com/dall-e-3)*

## Product Objective

SNS to SQS for fanout messages.

SNS
Create topic: VehicleStatus.fifo
FIFO


SQS
VehicleCompletedQueue.fifo

subscribe to topic

Update Filter
Subscriptions -> Edit
Subscription filter policy
{
  "service_status": [
    "Completed"
  ]
}

SQS
AllStatusUdpatesQueue.fifo


Back to SNS
Publish Message:


lambda adminGetServiceRequest

```
import { SNSClient, PublishCommand } from "@aws-sdk/client-sns"; // ES Modules import
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  ScanCommand,
  PutCommand,
  GetCommand,
  DeleteCommand,
  UpdateCommand,
} from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});

const mydynamodb = DynamoDBDocumentClient.from(client);

const tableName = "VehicleServices";    

export const getDynamoServiceRequests = async () => {
    const statusToExclude = "Completed";
    const statusToExcludeRejected = "Service Rejected";

    try {
        const params = {
            TableName: tableName,
            FilterExpression: "attribute_not_exists(service_status) OR (#service_status <> :status AND #service_status <> :statusRejected)",
            ExpressionAttributeNames: {
                "#service_status": "service_status"
            },
            ExpressionAttributeValues: {
                ":status": statusToExclude,
                ":statusRejected":statusToExcludeRejected
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

export const updateDynamoServiceRequest = async (requestBody, serviceId) => {
  try {

    const licensePlate = requestBody.license_plate ?? "Unknown";

    // Check if the item exists
    const getParams = {
      TableName: tableName,
      Key: {
        service_id: serviceId,
        license_plate: licensePlate,
      },
    };

    const { Item } = await mydynamodb.send(new GetCommand(getParams));

    if (!Item) {
      throw new Error("No record found");
    }    
    
    // Initialize the UpdateExpression components
    let updateExpression = "set";
    const expressionAttributeNames = {};
    const expressionAttributeValues = {};

    // Dynamically build the UpdateExpression, ExpressionAttributeNames, and ExpressionAttributeValues
    if (requestBody.service_description) {
      updateExpression += " #sd = :sd,";
      expressionAttributeNames["#sd"] = "service_description";
      expressionAttributeValues[":sd"] = requestBody.service_description;
    }
    if (requestBody.phone_number) {
      updateExpression += " #pn = :pn,";
      expressionAttributeNames["#pn"] = "phone_number";
      expressionAttributeValues[":pn"] = requestBody.phone_number;
    }
    if (requestBody.service_status) {
      updateExpression += " #ss = :ss,";
      expressionAttributeNames["#ss"] = "service_status";
      expressionAttributeValues[":ss"] = requestBody.service_status;
    }

    // Remove any trailing comma from the update expression
    updateExpression = updateExpression.replace(/,$/, "");

    const params = {
      TableName: tableName,
      Key: {
        service_id: serviceId,
        license_plate: requestBody.license_plate ?? "Unknown", // Assuming license_plate is part of the key
      },
      UpdateExpression: updateExpression,
      ExpressionAttributeNames: expressionAttributeNames,
      ExpressionAttributeValues: expressionAttributeValues,
    };

    await mydynamodb.send(new UpdateCommand(params));
    
    await sendSNSMessage(requestBody,serviceId);

    return `Successfully updated service request`;
  } catch (error) {
    if (error.message === "No record found") {
      return error.message;
    } else {
      console.error("Error updating DynamoDB service request:", error);
      throw error; // Re-throw the error to handle it further up the call stack
    }
  }
};



// Helper function to generate a unique service_id based on current date and time
const generateServiceId = () => {
  const now = new Date();
  const formattedDate = now.toISOString().replace(/[-T:.Z]/g, ""); // Format date string
  const milliseconds = now.getMilliseconds().toString().padStart(3, "0"); // Get milliseconds and pad with leading zeros if necessary
  return `${formattedDate}${milliseconds}`; // Concatenate date and milliseconds
};

async function sendSNSMessage(requestBody, serviceId){
    const client = new SNSClient();
    const input = { // PublishInput
      TopicArn: "arn:aws:sns:us-east-1:101783390245:VehicleStatusSNS",
      Message: `{"service_status":"${requestBody.service_status}"}`,
      Subject: serviceId,
      MessageAttributes: { // MessageAttributeMap
        "service_status": { // MessageAttributeValue
          DataType: "String", // required
          StringValue: `${requestBody.service_status}`,
        },
      },
      // MessageDeduplicationId: `${requestBody.service_id}`,
      // MessageGroupId: `${requestBody.service_id}`,
    };
    const command = new PublishCommand(input);
    const response = await client.send(command);  
}
```
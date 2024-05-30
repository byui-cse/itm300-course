---
title: Module 08: Project 8 Lab - SNS & SQS Workflow
body-class: index-page
---

![Quick Oil Change and Repair]({{URLROOT}}/shared/img/sns_sqs.jpg)

## Product Objective

In this lab, we will leverage AWS Simple Notification Service (SNS) and Simple Queue Service (SQS) to set up a system capable of sending multiple push messages to various services, such as billing, customer notifications, and analytics. By sending a single SNS message upon a service status update, we can trigger multiple downstream services, streamlining communication and ensuring efficient, real-time updates across our application.

## Create the SNS Topic

* Search for SNS which will bring up the Simple Notification Service
* Create topic: **VehicleStatus**
* Standard
* Click Create Topic
* Leave the rest of the defaults

## Create a SQS Queue

* Search for SQS which will bring up the Simple Queue Service
* Create queue: **VehicleCompletedQueue**
* Standard
* Leave the rest of the defaults


## Create a second Queue

* Create queue: **AllStatusUpdatesQueue**
* Standard
* Leave the rest of the defaults

## Subscribe to the topic for both Queues

* Click on the **VehicleCompletedQueue**
* Click on Subscribe to SNS Topic
* Choose **VehicleStatus**
* Click Save

Follow the same steps to subscribe to the VehicleStatus SNS Topic for the AllStatusUpdatesQueue as well.

## Add the filter

* Go to the VehicleStatus SNS Dashboard and click on Subscriptions in the left hand panel.
* Click on the subscriptions and look for the AllVehicleUpdatesQueue under the endpoint. You may need to look at both to find the correct subscription.
* Click Edit
* Open the Subscription filter policy
* Paste the following into the filter policy

```
{
  "service_status": [
    "Completed"
  ]
}
```

* Click Save Changes

## Send a message

* Click Topics in the left hand panel of the SNS dashboard
* Click on VehicleStatus
* Click Publish Message
* Subject: TestMessage
* Message body: Testing a message
* Message attributes:
    * Type: String  
    * Name: service_status
    * Value: Completed
* Click Publish Message

## View the message

* Go to the SQS dashboard
* Click on AllStatusUpdatesQueue
* Click Send and Receive Messages
* Scroll to the bottom and click Poll for messages
* The message should appear under messages.

Do the same for the **VehicleCompletedQueue**. You should see the message in both places.

## Send another message

Send another message, but this time put *Approved* for the service_status. Go back and check the queues. You should see the message in the AllStatusUpdatesQueue, but not the VehicleCompletedQueue because of the filter we added to the subscription.

## Update our lambda to send a SNS message on updates.

* Go to the adminGetServiceRequest Lambda
* update the lambda adminDynamoService.mjs file

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
      if (requestBody.service_status == "Completed"){
        updateExpression += " #cd = :cd,";
        expressionAttributeNames["#cd"] = "completion_date";
        expressionAttributeValues[":cd"] = new Date().toString();     
      }       
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
      TopicArn: "REPLACE-WITH-YOUR-TOPIC-ARN",
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

You'll need to go get the Topic ARN from the SNS Topic **VehicleStatus**. You'll update the code where it says "REPLACE-WITH-YOUR-TOPIC-ARN" with the ARN of your Topic.

Once you've made the update, go to your website and submit a service request. Type in a phone number, license plate number, and the message requesting an oil change for a 2020 Corvette.

Then log into the admin area and then change the status for that service to Approved.

Go look at the queues. You should see the message under one but not the other.

Update the status to Completed from the admin area.

Go look at the queues. You should see the new message under both.

## Add a lambda to run when a message is received

Create a new lambda function named VehicleAnalytics. 

Add this code to the index.mjs file:

```
export const handler = async (event) => {
  // TODO implement
  const response = {
    statusCode: 200,
    body: JSON.stringify('Status Updated!' + event),
  };
      console.log("status updated!"+event);
    for (const record of event.Records) {
        // Log the message details
        console.log('Message ID:', record.messageId);
        console.log('Receipt Handle:', record.receiptHandle);
        console.log('Body:', record.body);
        
        // Process the message (e.g., parse JSON, interact with other AWS services, etc.)
        try {
            const messageBody = JSON.parse(record.body);
            // Example: Log the parsed message body
            console.log('Parsed Message Body:', messageBody);
            // You can add your custom processing logic here
            const fullMessage = JSON.parse(messageBody.Message);
            console.log("Full Message:",fullMessage);
        } catch (error) {
            console.error('Error processing message:', error);
        }

    }    
  console.log(event['Records']);
  return response;
};
```

Go to the SQS queue for the **AllStatusUpdatesQueue**

* Click the lambda trigger tab
* Click Configure Lambda function trigger
* Choose the VehicleAnalysis function
* Click Save

Go look at the queue. You'll notice that the messages are now gone from that queue. Once a message is processed by a lambda with a 200 status, it will automatically be deleted from the queue. 

You can now go to the CloudWatch service and look at the *log groups* for the *VehicleAnalytics*.

![CloudWatch Log Groups]({{URLROOT}}/shared/img/cloudwatch-log-groups.jpg)

There you should see logs that have information about the two updates you did previously. These logs could then be used to create dashboards and visualizations of the services performed over time.

![CloudWatch SNS Log]({{URLROOT}}/shared/img/cloudwatch-sns-message-log.jpg)

Outside of the lab environment, SNS can be utilized to send emails and text messages, which can be very useful for notifying customers about the status of their vehicles or informing them that their car is ready for pickup.

By integrating SNS and SQS, we can effortlessly add new workflows to various activities without requiring the original service to be aware of the additional pipelines that have been established.


## Lab Summary

This lab focuses on utilizing AWS Simple Notification Service (SNS) and Simple Queue Service (SQS) to create a messaging system that can notify various services about changes in vehicle service statuses. The key objectives include setting up SNS topics and SQS queues, configuring subscriptions, filtering messages, sending and receiving messages, and integrating these functionalities into a Lambda function for further processing.

### Key Concepts Explained:

* **Decoupled Architecture:** By using SNS and SQS, the lab demonstrates how to decouple different parts of an application. This architecture allows independent scaling and development of various components without affecting others.
* **Asynchronous Messaging:** SNS and SQS enable asynchronous communication between services. This is crucial for handling tasks that do not require immediate responses, improving the application's overall efficiency and responsiveness.
* **Message Filtering:** SNS message filtering allows targeted messages to be sent to specific queues based on message attributes. This reduces unnecessary processing and ensures that only relevant messages are received by specific services.
* **Event-Driven Processing:** The integration of Lambda functions with SNS and SQS illustrates event-driven processing, where actions are triggered in response to specific events (e.g., updates to vehicle service status).
* **Scalability and Flexibility:** Using SNS and SQS provides a scalable and flexible solution for handling increasing volumes of messages and integrating new services or workflows without significant changes to the existing system.

## Key AWS Services:

* **Simple Notification Service (SNS):** SNS is a fully managed service that enables the delivery of messages to various endpoints such as email, SMS, and other AWS services. It acts as a publisher in the publish-subscribe (pub/sub) model.
* **Simple Queue Service (SQS):** SQS is a fully managed message queuing service that allows you to decouple and scale microservices, distributed systems, and serverless applications. It acts as a subscriber in the pub/sub model, receiving and storing messages until they are processed.
* **CloudWatch:** CloudWatch is a monitoring and observability service that provides data and actionable insights for AWS resources. It is used in this lab to monitor and log the processing of messages in Lambda functions.

### Reflection Questions:

* **Understanding the Workflow:** How does the integration of SNS and SQS enhance the scalability and flexibility of the notification system in this project? What are the advantages of using message filtering in SNS subscriptions?
* **Lambda Function Integration:** How does updating the Lambda function to publish SNS messages streamline the process of service status updates? What other AWS services could you integrate with this system to enhance functionality?
* **Real-World Applications:** How could this messaging system be adapted for use in different industries or applications outside of vehicle service notifications? What are the potential benefits and challenges of using SNS and SQS for customer notifications in a high-traffic environment?
* **Error Handling and Logging:** Why is it important to handle errors and log messages in the Lambda function processing the SQS messages? How would you improve the error handling and logging mechanisms in this lab?
* **Further Improvements:** What additional features or services could be integrated into this system to improve its functionality and reliability? How would you modify the system to handle larger volumes of messages or more complex workflows?
---
title: Module 05: Product 5 Lab - DynamoDB
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

!!! key "Case Matters"

    When you create the table and all of the fields, please be careful to follow the uppercase and lowercase names as provided in the instructions. The app expects specific names of fields and the database to work.

    ALSO, make sure there are no spaces before or after in your field names or values

<span class="material-symbols-outlined">search</span> Search for DynamoDB in AWS

* <span class="amz-orange-button">Create table</span>

* Table Name: **VehicleServices**

* Partition Key: **license_plate** (String)
* Sort Key: **service_id** (String)

* Customize Settings
* Capacity mode: On-demand

* Secondary Indexes: <span class="amz-white-button">Create global index</span>
  * Global Secondary Index:
    * Index Name: StatusIndex
      * Partition Key: service_status (String)
      * Sort Key: license_plate (String)
  * <span class="amz-orange-button">Create index</span>

* <span class="amz-orange-button">Create table</span>

Wait for the Status to be: <span class="material-symbols-outlined">
check_circle
</span> Active

* Click on <span class="amz-link">VehicleServices</span>

* Actions <span class="material-symbols-outlined">
arrow_drop_down
</span> -> <span class="amz-white-button">Create Item</span>
  * **license_plate** 8B1111
  * **service_id** 1
  * <span class="amz-white-button">Add new attribute</span> (String): **phone_number** 208-444-5555
  * <span class="amz-white-button">Add new attribute</span> (String): **service_description** Oil Change on a 2007 Saturn Outlook
  * <span class="amz-white-button">Add new attribute</span> (String): **service_status** Being Serviced
  * <span class="amz-orange-button">Create item</span>

## Update Lambda

<span class="material-symbols-outlined">search</span> Search for Lambda and open your <span class="amz-link">getServiceRequest</span> lambda function

* Under Code -> Right click on getServiceRequest and choose New File
* Name it *dynamoService.mjs*
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
```

We will replace the previous dataService with the new dynamoService.

* Add this line to the top of the *index.mjs* file:

```
import { getDynamoServiceRequests } from './dynamoService.mjs';
```

* In the *index.mjs* file change the name of the function being called by repalacing *const jsonArray = getServiceRequests();* with

```
const jsonArray = await getDynamoServiceRequests();
```

Click <span class="amz-white-button">Deploy</span> and then Test the deployment. You should only see the single response in the body instead of the three hardcoded items we had before.

Go to the website and verify that you are getting a single ticket back. You can get the link from your EC2.

!!! key "Website App Troubleshooting"

    Your website should be running on your EC2 instance. You can find the link to the website by clicking on the checkmark next to the EC2 and at the bottom of the page finding the Public IPv4 DNS.

    If your website isn't running, you'll need to check to see if the httpd service is running and enabled. You can check this by connecting to the EC2 and then running the following commands:

    sudo systemctl enable httpd

    sudo systemctl start httpd

    If the website is up, but not working, then you'll need to dig into the error console (Right click inspect and choose console) to troubleshoot the errors. This and CloudWatch are your best options for tracking down errors.

## Add information to the database

Go back to the dynamodb table and click <span class="amz-orange-button">Explore table items</span>
Click <span class="amz-orange-button">run</span>. Down below it should return the 8B1111 item

* Check the checkbox next to 8B1111. 
* Click Actions <span class="material-symbols-outlined">
arrow_drop_down
</span> ->Duplicate Item

Update the values on this page to this:

* license_plate: 1J1957
* service_id: 2
* phone_number: 208-867-5309
* service_description: Brakes for a 08 Mazda 3
* service_status: Accepted

Click <span class="amz-orange-button">create item</span>

Go back to the website and you should see both items under service request.

## Update a vehicle

Go update the value of the service_status of the 8B1111 vehicle to have a *service_status* of **Completed**

Go view the website and you should only see one service request.

## Lab Summary:

In this lab, the primary objective was to create a DynamoDB table named *VehicleServices* to store service requests related to vehicle maintenance. Additionally, the lab focused on updating a Lambda function to interact with this DynamoDB table for fetching and manipulating service request data.

### Key Concepts Explained:

!!! note "DynamoDB"

    Amazon DynamoDB is a fully managed NoSQL database service provided by Amazon Web Services (AWS). It is designed to provide seamless scalability, low-latency performance, and high availability for applications that require fast and flexible data storage. DynamoDB is suitable for a wide range of use cases, from mobile and web applications to gaming, IoT (Internet of Things), and real-time analytics.

    Key features and concepts of DynamoDB include:

    **Fully Managed Service:** DynamoDB is a serverless database service, which means AWS manages all aspects of database provisioning, scaling, and maintenance, allowing developers to focus on building applications without managing infrastructure.

    **NoSQL Database:** DynamoDB is a NoSQL (non-relational) database that offers flexible schema design, allowing developers to store and retrieve data in a schema-less format. It supports various data types, including scalar types (like string, number, boolean) and complex types (like lists and maps).

    **Scalability and Performance:** DynamoDB automatically scales to accommodate growing workloads by distributing data across multiple servers and partitions. It provides single-digit millisecond latency for read and write operations, making it suitable for applications that require high-performance data access.

    **Data Model:** DynamoDB uses primary keys for data retrieval and storage. Tables can have a partition key (and optionally a sort key), enabling efficient querying and indexing of data. Global and local secondary indexes can be defined to support different access patterns.

    **Consistency and Durability:** DynamoDB offers configurable consistency models (strong consistency or eventual consistency) based on application requirements. It also provides built-in replication and backup capabilities for data durability and disaster recovery.

1. **DynamoDB:** In this lab, a DynamoDB table was created with specific attributes like *license_plate* and *service_id* to store service request details.
1. **DynamoDB Table Configuration:** The lab covered the configuration of a DynamoDB table, including defining a primary partition key (license_plate) and a sort key (service_id). Additionally, a global secondary index (StatusIndex) was created to facilitate efficient querying based on the *service_status* attribute.
1. **Lambda Function Integration with DynamoDB:** The Lambda function (getServiceRequest) was updated to use the AWS SDK for DynamoDB to interact with the VehicleServices table. The function was modified to retrieve service requests based on certain filtering conditions (e.g., excluding completed or new requests) using a ScanCommand.
1. **Data Manipulation in DynamoDB:** The lab demonstrated how to add and update items in the DynamoDB table directly from the AWS Management Console by duplicating an existing item and updating its attributes (e.g., changing service_status to "Accepted" for a new service request).

###Reflection Questions:

* Explain the significance of partition keys and sort keys in DynamoDB. How does the choice of these keys impact the performance and querying capabilities of the database table?
* Discuss the benefits of using a global secondary index (GSI) in DynamoDB. What scenarios would require the creation of GSIs, and how do they enhance query flexibility?
* Reflect on the differences between scanning and querying data in DynamoDB. Why is it important to optimize data access patterns to minimize resource consumption and improve performance?
* Describe the role of Lambda functions in serverless architectures. How does integrating Lambda with DynamoDB enable event-driven data processing and application logic execution?
* Explore the challenges and best practices of managing NoSQL databases like DynamoDB for scalable and responsive applications. How can developers optimize data modeling and indexing strategies to ensure efficient data access and storage?
* Consider the trade-offs between NoSQL and relational databases for cloud-based applications. What factors would influence the choice of database technology based on application requirements and scalability considerations?
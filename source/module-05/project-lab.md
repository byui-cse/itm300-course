---
title: Module 05: Project 5 Lab - DynamoDB
body-class: index-page
---

![Quick Oil Change and Repair]({{URLROOT}}/shared/img/quick-logo-service-requests.jpg)
*[Photo by Dall-E-3](https://openai.com/dall-e-3)*

## Product Objective

You will be connecting your website to an API gateway which will return back service requests. A lambda function will generate the json that will contain the information about the service requests which will be sent back to the app. For now, we'll just hard code the json, but later we'll pull the information dynamically.


## Instructions

We will do three main steps in this lab. First we will create a lambda function which will generate json data containing service request information. This information will be displayed on our app as well as in the shop to let customer's know which vehicles are currently being worked on.

Second, we'll create an API gateway and an **endpoint** that we can connect to. This enpoint will return back the information provided by the lambda function.

Third, we'll update our app code to display the current service requests.

## Create a Lambda Function

Search for Lambda in AWS

* Create function
* Author from scratch
* Function Name: getServiceRequest

* Change default execution role: Use an existing Role: LabRole

Update index.mjs with:

```
import { getServiceRequests } from './dataService.mjs';

const commonHeaders = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Headers': 'Content-Type',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'OPTIONS,POST,GET,PUT'
};

export const handler = async (event) => {
  try {
    const jsonArray = getServiceRequests();
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

!!! note "HTTP Status Codes"

    We return one of two status codes depending on if the function does what it is supposed to do.

    **200** OK: This means everything went well.

    **500** Internal Server Error

    The preparation material for this week has videos that go into what each status code is. We'll use more in the future as well as using different HTTP verbs besides GET.

Create a file named dataService.mjs

```
export const getServiceRequests = () => {
  return [
    { id: 1, phone: '208-555-5555', service: 'Oil Change on a 2007 Saturn Outlook' },
    { id: 2, phone: '208-555-9999', service: 'I need the brakes fixed on my 2010 Buick LeSabre' },
    { id: 3, phone: '208-555-9111', service: 'My radiator exploded. Help!' }
  ];
};
```

Click Test

Give the Test a name and then click Invoke. You should receive a response similar to this:

```
{
  "statusCode": 200,
  "body": "[{\"id\":1,\"phone\":\"208-555-5555\",\"service\":\"Oil Change on a 2007 Saturn Outlook\"},{\"id\":2,\"phone\":\"208-555-9999\",\"service\":\"I need the brakes fixed on my 2010 Buick LeSabre\"},{\"id\":3,\"phone\":\"208-555-9111\",\"service\":\"My radiator exploded. Help!\"}]",
  "headers": {
    "Content-Type": "application/json",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "OPTIONS,POST,GET,PUT"
  }
}
```

Deploy the Lambda function by clicking the Deploy button

!!! key "Don't forget to Deploy"

    If you make any changes to your function, you must click Deploy to deploy the new changes. 

## Create the API Gateway

Search for API Gateway.

Scroll down to REST API and Click **Build**

* New API
* API Name : vehicleapp

* API endpoint type: Regional

* Create API

* Create resource:

    * Resource path: /
    * Resource name: service-request
    * CORS checked

* Click /service-request

    * Create method

    * Method type: GET
    * Integration type: Lambda Function
    * TURN ON LAMBDA PROXY INTEGRATION
    * Lambda Function (make sure your region is correct): getServiceRequest

Before we deploy the API you should test the API to make sure it is returning the correct data.

Click the **Test** tab and then click the Test button. You should get a response like this:

```
Response body

[{"id":1,"phone":"208-555-5555","service":"Oil Change on a 2007 Saturn Outlook"},{"id":2,"phone":"208-555-9999","service":"I need the brakes fixed on my 2010 Buick LeSabre"},{"id":3,"phone":"208-555-9111","service":"My radiator exploded. Help!"}]

Response headers

{
  "Access-Control-Allow-Headers": "Content-Type",
  "Access-Control-Allow-Methods": "OPTIONS,POST,GET,PUT",
  "Access-Control-Allow-Origin": "*",
  "Content-Type": "application/json",...
```


* Click Deploy API

    * State: New Stage
    * Stage Name: prod

## Update the App logic

Connect to your Vehicle App EC2 Instance

Download the newest website app:

```
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-04/rebuildapp.sh
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



Once you've updated the files, you should visit your app and make sure it displays the three current service requests at the bottom of the request service page.
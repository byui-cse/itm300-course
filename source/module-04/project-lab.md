---
title: Module 04: Product 4 Lab - REST API Gateway
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

<span class="material-symbols-outlined">search</span> Search for Lambda in AWS

* <span class="amz-orange-button">Create function</span>
* Author from scratch
* Function Name: getServiceRequest

* <span class="material-symbols-outlined">
arrow_right
</span> Change default execution role: Use an existing Role: LabRole

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

Right click on getServiceRequests and choose New file. Create a file named dataService.mjs

```
export const getServiceRequests = () => {
  return [{"service_status":"Waiting for Parts","service_id":"20240627190936516516","phone_number":"2020"},{"service_status":"Complete. Pick up Vehicle","service_id":"20240625211634028028","phone_number":"3839"},{"service_status":"Approved - Bring Vehicle In","service_id":"20240625210133994994","phone_number":"3030"}];
};
```

Deploy the Lambda function by clicking the <span class="amz-white-button">Deploy</span> button

!!! key "Don't forget to Deploy"

    If you make any changes to your function, you must click <span class="amz-white-button">Deploy</span> to deploy the new changes.

Click the dropdown arrow <span class="material-symbols-outlined">
arrow_drop_down
</span>next to the blue Test button and choose Configure test event. 


Give the Test a name and then click <span class="amz-white-button">Invoke</span>. You should receive a response similar to this:

<div class="results">
{"statusCode":200,"body":"[{\"service_status\":\"Waiting for Parts\",\"service_id\":\"20240627190936516516\",\"phone_number\":\"2020\"},{\"service_status\":\"Complete. Pick up Vehicle\",\"service_id\":\"20240625211634028028\",\"phone_number\":\"3839\"},{\"service_status\":\"Approved - Bring Vehicle In\",\"service_id\":\"20240625210133994994\",\"phone_number\":\"3030\"}]","headers":{"Content-Type":"application/json","Access-Control-Allow-Headers":"Content-Type","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"OPTIONS,POST,GET,PUT"}}
</div>
 

## Create the API Gateway

<span class="material-symbols-outlined">search</span> Search for API Gateway.

Scroll down to REST API and Click <span class="amz-orange-button">Build</span>

* New API
* API Name : vehicleapp

* API endpoint type: Regional

* <span class="amz-orange-button">Create API</span>

* <span class="amz-white-button">Create resource</span>:

    * Resource path: /
    * Resource name: service-request
    * CORS checked
    * <span class="amz-orange-button">Create resource</span>

* Click /service-request

    * <span class="amz-white-button">Create method</span>

    * Method type: GET
    * Integration type: Lambda Function
    * TURN ON LAMBDA PROXY INTEGRATION
    * Lambda Function (make sure your region is correct): getServiceRequest

Before we deploy the API you should test the API to make sure it is returning the correct data.

Click the <span class="amz-tab">Test</span> tab and then click the <span class="amz-orange-button">Test</span> button. You should get a response like this:

<div class="results">
Response body

[{"service_status":"Waiting for Parts","service_id":"20240627190936516516","phone_number":"2020"},{"service_status":"Complete. Pick up Vehicle","service_id":"20240625211634028028","phone_number":"3839"},{"service_status":"Approved - Bring Vehicle In","service_id":"20240625210133994994","phone_number":"3030"}]

Response headers

{
  "Access-Control-Allow-Headers": "Content-Type",
  "Access-Control-Allow-Methods": "OPTIONS,POST,GET,PUT",
  "Access-Control-Allow-Origin": "*",
  "Content-Type": "application/json",...
</div>


* Click <span class="amz-oranage-button">Deploy API</span>

    * Stage: New Stage
    * Stage Name: prod

## Update the App logic

<span class="amz-white-button">Connect</span> to your Vehicle App EC2 Instance

Download the newest website app:

```
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-04/rebuildapp.sh
```

```
chmod +x ./rebuildapp.sh
```

Next run the script which will install the newest files.

```
sudo bash ./rebuildapp.sh
```

 You'll be prompted to enter the invoke URL. Get the invoke URL from your API Gateway:

* Click Stages on the left bar
* Under stage details find <span class="material-symbols-outlined">
content_copy
</span> Invoke URL and copy that address
* Paste that as the Invoke URL when prompted

Once you've updated the files, verify the app is working. Click the Request Service link at the top of the oil website and make sure it displays the three current service requests at the bottom of the request service page.

## Lab Summary:

In this lab, the objective was to integrate with an API Gateway connected to an AWS Lambda function. The Lambda function generates JSON data containing service request information, which is then displayed on the website.

### Key Concepts Explained:

!!! note "APIs"

    An API is like a bridge that allows different software programs to talk to each other and work together. It defines a set of rules and protocols that determine how different parts of software can interact. Think of it as a waiter at a restaurant taking your order (request) and bringing you the food (response) from the kitchen.

    Here's a breakdown:

    **What is an API?**
        An API is a set of rules and protocols that lets software applications communicate with each other. It defines how one piece of software can request information or perform actions from another piece of software.

    **How does it work?**
        Imagine you have an app on your phone that needs weather information. Instead of creating its own weather service, the app can use an API provided by a weather website. The app sends a request (like "give me the weather forecast for today") to the weather website's API. The API then processes this request and sends back the weather data (response) that the app can use to display the forecast.

    **Why are APIs important?**
        APIs allow developers to leverage existing functionality without reinventing the wheel. They enable software to be modular and interconnected, which promotes code reuse, collaboration, and faster development of new applications.

    **Real-world analogy:**
        Think of APIs like a menu at a restaurant. The menu lists all the dishes (services) available, along with descriptions (API documentation) of what each dish contains and how to order it. When you order from the menu (send a request), the kitchen (API server) prepares your food (response) according to the instructions provided.

1. **AWS Lambda:** AWS Lambda is a serverless compute service provided by Amazon Web Services (AWS). It allows you to run code in response to events without provisioning or managing servers. In this lab, a Lambda function (getServiceRequest) was created to dynamically generate service request data.
2. **API Gateway:** API Gateway is a fully managed service that enables developers to create, publish, maintain, monitor, and secure APIs at any scale. It acts as a front door for applications to access data, business logic, or functionality from back-end services, like Lambda functions. Here, an API Gateway with an endpoint (/service-request) was set up to trigger the Lambda function and return its response to the website.

3. **HTTP Status Codes:** HTTP status codes are standard response codes given by web servers on the internet. In this lab:

      - 200 OK indicates that the request was successful, and the Lambda function executed as expected, returning the desired data.
      - 500 Internal Server Error indicates a failure on the server side, typically due to an issue with the Lambda function's execution. These codes are essential for communicating the outcome of API requests back to the client.

4. **Integration and Deployment:** Integration between Lambda and API Gateway was achieved using a Lambda proxy integration. This integration simplifies the communication between the API Gateway and Lambda function, allowing the Lambda function to directly handle incoming HTTP requests and respond with the appropriate data. After setting up the integration, the API was deployed to a specific stage (prod) to make it accessible to the website. Typically, you'd have a dev (development) and prod (production) stage. Using a prod stage ensures that only stable and verified versions of the API are exposed to customers or clients, minimizing the risk of introducing bugs or disruptions to service.

5. **App Logic Update:** The website's app logic was updated to consume the data provided by the API Gateway. This involved modifying the app code to make HTTP requests to the API endpoint (/service-request) and then displaying the retrieved service request information on the website's interface.

### Reflection Questions:

* What role does AWS Lambda play in modern cloud architectures? How does its serverless nature benefit application development?

* Explain the importance of API Gateway in the context of microservices and serverless applications. How does API Gateway simplify the process of exposing AWS Lambda functions as HTTP endpoints?

* Describe the significance of HTTP status codes like 200 OK and 500 Internal Server Error when building and consuming APIs. How can understanding these codes help in troubleshooting and improving the reliability of applications?

* Discuss the advantages of using a Lambda proxy integration with API Gateway. How does this integration model differ from other integration types, and what are its benefits for developers?

* Reflect on the deployment process of both the Lambda function and the API Gateway. Why is it important to version and deploy APIs when making changes to the underlying services?

* After updating the app logic to consume the API data, what considerations should be made regarding error handling and data parsing within the application code? How can these practices enhance the overall user experience?

---
title: Module 10: Project 10 Lab - Containers
body-class: index-page
---

![Quick Oil Change and Repair]({{URLROOT}}/shared/img/quick-logo-vehicle-history.jpg)

## Product Objective

Instead of using a single EC2 instance, we are going to place our app in a container and allow it to auto-scale and use a load balancer.


## Add / Verify IAM Role

* Go to the EC2 dashboard
* Go to Instances
* Place a checkmark next to the instance that is running your app
* Choose <span class="amz-white-button">Actions <span class="material-symbols-outlined">
arrow_drop_down
</span></span> <span class="amz-white-button">Security <span class="material-symbols-outlined">
arrow_right
</span></span> <span class="amz-white-button">Modify IAM role</span>
* IAM role choose <span class="amz-white-button">LabInstanceProfile</span>
* <span class="amz-orange-button">Update IAM role</span>

* <span class="amz-white-button">Connect</span> to the EC2

## Install and Configure Docker to work with AWS

Install Docker

```
sudo dnf install -y docker
```

Add your AWS Credentials:

```
mkdir ~/.aws
```

```
cd ~/.aws
```

```
touch credentials
```

* Click on the tab where you opened the AWS Lab
* Click on **i** AWS Details
* Click on Show next to **AWS CLI:**
* Copy the contents of that box. It should have the access key id, the secret access key and the token

![Example of AWS Token Box]({{URLROOT}}/shared/img/aws-cli-example.jpg)

* Go back to your EC2 connect tab
* Use Nano or Vim to paste the information into the file named credentials

!!! note "Credentials"

    Please note that this file doesn't have an extension. It is just called *credentials*

```
aws configure
```

When you run this command it should read from the credentials file you just created. You can accept the access key id and the secret access key by clicking enter twice. You'll need to enter **us-east-1** for the default region name and **json** for the Default output format.


```
cd /var/www/html
```

We've created a basic Dockerfile for you. This file is called Dockerfile with no extension. Let's look at what is in the file:

```
cat Dockerfile
```

This will show you that we are using the latest version of nginx and that we'll copy all of the files from this folder into the /usr/shar/nginx/html folder in the container. This will all happen when we create the container.

Start up docker:

```
sudo systemctl start docker
```

Add a docker group (this might fail, if it does just continue on to the next step)

```
sudo groupadd docker
```

Add your user to the docker group

```
sudo usermod -aG docker $USER
```

Apply the group membership

```
newgrp docker
```

Make sure docker is listed in the groups the user is assigned

```
groups $USER
```

Verify your AWS CLI Authentication

```
aws sts get-caller-identity
```

You should get something like this in return:

{
    "UserId": "AROAIEXAMPLEID",
    "Account": "123456789012",
    "Arn": "arn:aws:sts::123456789012:assumed-role/RoleName/RoleSessionName"
}

## Create the container registry

Search for ECR which will bring up Elastic Container Registry. Open this in a new tab.

* <span class="amz-orange-button">Create repository</span>
* Repository name: vehicle-app
* <span class="amz-orange-button">Create repository</span>
* Click on <span class="amz-link">vehicle-app</span>
* <span class="amz-white-button">View push commands</span>
* Copy the 4 commands and run them in your EC2 terminal. *You'll need to add **sudo** to the front of each of the commands.*

    * sudo aws ecr get-login-passwo...
    * docker build -t vehicle-app .
    * docker tag vehi...
    * docker push...

You should receive a response that shows the docker container was pushed to the ECR.

Go back to the ECR tab and click <span class="amz-white-button">Close</span>

* Click the <span class="amz-white-button"><span class="material-symbols-outlined">
refresh
</span></span> button.

You should see 1 image with a tag of latest in the list.

## Create an ECS

* Search for ECS and open the Elastic Container Service in a new tab


### Create a cluster

* <span class="amz-orange-button">Create cluster</span>
* Cluster name: **VehicleCluster**
* <span class="amz-orange-button">Create</span>
* Use fargate
* Wait for the cluster to create

### Create a task definition

* Click <span class='amz-white-button'>Task definitions</span> on the left-hand column
* Click <span class="amz-orange-button">Create new task definition <span class="material-symbols-outlined">
arrow_drop_down
</span></span> <span class="amz-white-button">Create new task definition</span>
* Task definition family: **VehicleAppTask**
* Launch Type: Fargate
* CPU: .25 vCPU
* Memory: 1 GB
* Task role: LabRole
* Task execution rold: LabRole

Under Container-1

* Name: vehicle-container
* Image URI: paste in the URI from the ECR Image URI
* <span class="amz-oranage-button">Create</span>

## Deploy the containers

* <span class="amz-white-button">Deploy <span class="material-symbols-outlined">
arrow_drop_down
</span></span> <span class="amz-white-button">Create service</span>
* Exisiting cluster: VehicleCluster
* Under Deployment configuration
    * Service Name: VehicleAppService
* Under Networking
    * VPC: vehicleapp-vpc
    * remove the private subnets
    * Exisiting Security Group: Add vehicle-sg and remove the default one
* Under Load balancing
    * Load balancer type: Application Load Balancer
    * Load balancer name: **VehicleLoadBalancer**
* Under Service auto scaling
    * Check Use service auto scaling
    * Minimum number of tasks: 1
    * Maximum number of tasks: 3
    * Policy Name: Vehicle CPU usage
    * ECS service metric: ECSServiceAverageCPUUtilization
    * Target value 70 (these look like they already have values, you need to TYPE them in)
    * Scale-out: 300
    * Scale-in: 300
* <span class="amz-orange-button">Create</span>
* Wait for the deployment to start
* Click the <span class="amz-white-button"><span class="material-symbols-outlined">
refresh
</span></span> button under Services.

You will see 1/1 Tasks running 

* Click on <span class="amz-link">VehicleAppService</span>
* Click on <span class="amz-white-button">View load balancer <span class="material-symbols-outlined">
open_in_new
</span></span>

Copy the DNS name for the load balancer and paste it into a new tab.

You will see your app running in a container on your load balancer. If we received enough traffic, the app would auto scale up to 3 containers for us.

Take a screenshot of your app running on the container with the load balancer and submit your screenshot.

## (OPTIONAL) Add SSL to your load balancer

* Click <span class="amz-tab">Listeners and rules</span>
* Click <span class="amz-white-button">Add listner</span>
* Choose HTTPS for protocol
* Target Group: ecs-Vehicle-VehicleAppService
* Import certificate

* Open your EC2 terminal
* Copy the contents of the file found here: /etc/pki/tls/private/apache-selfsigned.key
* Paste it into Certificate private key
* Copy the contents of the file found here: /etc/pki/tls/certs/apache-selfsigned.crt
* Paste it into Certificate body
* <span class="amz-orange-button">Add</span>

You can now go to your load balancer and add https in the front. You'll need to accept the security warning because it is still self-signed.



Once finished, you can destroy the following:

* LoadBalancer
* ECS Cluster
* ECS Tasks
* ECS Services
* ECR vehicle-app repository

These will eat up money if you leave them running. 




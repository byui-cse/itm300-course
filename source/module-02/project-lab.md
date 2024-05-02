---
title: Module 01: Project 2 Lab - Host a Website on EC2
body-class: index-page
---

![Quick Oil Change and Repair]({{URLROOT}}/shared/img/quick-logo.jpg)
*[Photo by Dall-E-3](https://openai.com/dall-e-3)*

## Product Objective

You will be hosting a website for your client on EC2. We'll also install a ssl certificate. The files are provided for you.


## Open up the lab evironment

Go to AWS Academy and get into the "Learner Lab" course. Start up the Learner Lab and go to the AWS console by clicking on the green dot when it appears.


## Create a VPC

Please create a VPC with 2 public subnets and 2 private subnets. Make sure these are in the us-east-1 area (N. Virginia). 

* Under name tag use: vehicleapp
* Number of Availability Zones: 2
* VPC Endpoints: None

## Tutorial Instructions:

Follow the instructions (steps 1-3 only) found on this tutorial with these additional requirements:

* Use the vockey for your keypair
* Use the vehicleapp-vpc VPC
* place the EC2 instance in the vehicleapp-subnet-public1 subnet. 
* Auto assign an IP address
* Create a security Group and name it vehicle-sg
    * Enable ports 80, 443, and 22 all from anywhere

[Hosting Website on EC2 using a LAMP stack](https://docs.aws.amazon.com/linux/al2023/ug/ec2-lamp-amazon-linux-2023.html)

## Download the following files:

Use wget to download the zip containing the website you are going to host on EC2. This will happen after you connect to the EC2 instance via ssh.

!!! info "Quickly Connecting to your Instance"

    If you use the vockey when you set up the server, you can do the following to easily connect without needing to use a ssh client.

    From the EC2 view of all instances do the following:
    
    * Click the checkmark next to your instance name
    * Click Connect at the top of the screen.
    * Click Connect at the bottom of the next screen.

You'll need to unzip the files and place them in the correct location on the server.

Helpful commands

```
sudo dnf install -y wget
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-02/quick-oil-part2.zip
mkdir /tmp/lab-app
unzip quick-oil-part2.zip -d /tmp/lab-app
mv /tmp/lab-app/quick-oil-part2/* /var/www/html
rm -rf /tmp/lab-app/
```

## Enable SSL

We'll use openssl to generate a private key that is self signed. You'd need to get the certificate signed by a certificate authority and that would require a registered domain name. Using nip.io we'll create a pseudo domain name we can use for creating the ssl certificate, but we won't sign it.

Make sure you open port 443 in your security group.

```
sudo dnf install -y openssl mod_ssl
```

```
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/pki/tls/private/apache-selfsigned.key -out /etc/pki/tls/certs/apache-selfsigned.crt
```
Country Name (2 letter code) [XX]:**US**

State or Province Name (full name) []:**Idaho**

Locality Name (eg, city) [Default City]:**Rexburg**

Organization Name (eg, company) [Default Company Ltd]:**MyCo**

Organizational Unit Name (eg, section) []:**Development**

For the common name we'll use a service called nip.io. You need to take your static ip address that you have for the EC2 and replace the periods with dashes like this:
52.91.237.254 becomes 52-91.237-254. Then add .nip.io to the end to get the common name.

Common Name (eg, your name or your server's hostname) []:**52-91-237-254.nip.io**
  
Email Address []:**youremail@byui.edu**

```
sudo systemctl restart httpd
```

## Helpful other links:

[nginx on Amazon Linux 2023](https://medium.com/@eikachiu/install-nginx-on-amazon-linux-2023-d032160bfc20)

[nginx on Amazon Linux 2023 LAMP](https://gist.github.com/atikju/1fb8d3e856e32f3b0a678d393914351b)


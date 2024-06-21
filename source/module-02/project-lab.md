---
title: Module 02: Product 2 Lab - Host a Website on EC2
body-class: index-page
---

![Quick Oil Change and Repair]({{URLROOT}}/shared/img/quick-logo.jpg)
*[Photo by Dall-E-3](https://openai.com/dall-e-3)*

## Product Objective

You will be hosting a website for your client on EC2. We'll also install an ssl certificate. The files for the website are provided for you.


## Open up the lab evironment

Go to AWS Academy and get into the "Learner Lab" course. Start up the Learner Lab and go to the AWS console by clicking on the green dot when it appears.


## Create a VPC

Please create a VPC with 2 public subnets and 2 private subnets. Make sure these are in the us-east-1 area (N. Virginia). 

* <span class="material-symbols-outlined">search</span> Search for VPC
* Click <span class='amz-orange-button'>Create VPC</span>
* Under name tag use: vehicleapp
* Number of Availability Zones: 2
* VPC Endpoints: None

## Create an EC2 instance

* <span class="material-symbols-outlined">search</span> Search for EC2
* Click <span class='amz-orange-button'>Launch Instance</span>
* Name the server vehicleapp-1
* Use the vockey for your keypair
* Use the vehicleapp-vpc VPC
* place the EC2 instance in the vehicleapp-subnet-public1 subnet. 
* Disable auto assign an IP address
* Create a security Group and name it vehicle-sg
    * Add security rules to enable ports 80 (HTTP), 443 (HTTPS), and 22 (SSH) all from anywhere

## Assign an Elastic IP

Allocate an Elastic IP address and then associate that elastic IP address with your instance by doing the following:


* Go to the <span class="amz-white-button">Elastic IPs</span> under <span class="amz-white-button">Network &amp; Security</span> on the left sidebar of the EC2 dashboard.
* Click <span class="amz-orange-button">Allocate Elastic IP address</span> and then click <span class="amz-orange-button">Allocate</span>.
* Click on the ip address (for example <span class="amz-link">44.223.155.86</span>) under Allocated IPv4 address
* Click <span class="amz-orange-button">Associate Elastic IP address</span>
* Choose your Instance from the drop down.
* Click <span class="amz-orange-button">Associate</span>

## Connect to your instance

Click on Instances on the left hand sidebar.

!!! note "Quickly Connecting to your Instance"

    If you use the vockey when you set up the server, you can do the following to easily connect without needing to use a ssh client.

    From the EC2 view of all instances do the following:
    
    * Click the checkmark next to your instance name
    * Click <span class="amz-white-button">Connect</span> at the top of the screen.
    * Click <span class="amz-orange-button">Connect</span> at the bottom of the next screen.
    
## Server Setup:

Once you are connected to the EC2, run the following commands.

```
sudo dnf update -y
```

Install the latest versions of Apache web server.

```
sudo dnf install -y httpd wget
```

Start the Apache web server.

```
sudo systemctl start httpd
```

Use the systemctl command to configure the Apache web server to start at each system boot. 

```
sudo systemctl enable httpd
```

Add your user (in this case, ec2-user) to the apache group.

```
sudo usermod -a -G apache ec2-user
sudo su - ec2-user
```

Change the group ownership of /var/www and its contents to the apache group.
To add group write permissions and to set the group ID on future subdirectories, change the directory permissions of /var/www and its subdirectories.
To add group write permissions, recursively change the file permissions of /var/www and its subdirectories:

```
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
```

## Download the following files:

Use the following commands to download the zip containing the website you are going to host on EC2.

```
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-02/quick-oil-part2.zip
mkdir /tmp/lab-app
unzip quick-oil-part2.zip -d /tmp/lab-app
sudo cp -rf /tmp/lab-app/quick-oil-part2/* /var/www/html
rm -rf /tmp/lab-app/
```



## Enable SSL

We'll use openssl to generate a private key and a certificate that is self signed. For a live website, you'd need to get the certificate signed by a certificate authority and that would require a registered domain name. We'll use amazon's Public IPv4 DNS  for creating the ssl certificate, but we won't get it signed with a CA. So it will still give you a "not secure" warning even though it is serving up files across SSL/HTTPS.

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

<!-- For the common name we'll use a service called nip.io. You need to take your static ip address that you have for the EC2 and replace the periods with dashes like this:
52.91.237.254 becomes 52-91-237-254. Then add .nip.io to the end to get the common name. -->

For the common name we'll use the public dns that amazon provides. We would normally use the domain name for the business. Get this from your EC2 instance

Common Name (eg, your name or your server's hostname) []:**ec2-44-221-155-86.compute-1.amazonaws.com**

Email Address []:**youremail@byui.edu**

Once we have our cert created, we need to go replace the built-in localhost cert.

```
sudo sed -i 's#^SSLCertificateFile /etc/pki/tls/certs/localhost.crt#SSLCertificateFile /etc/pki/tls/certs/apache-selfsigned.crt#' /etc/httpd/conf.d/ssl.conf
```

```
sudo sed -i 's#^SSLCertificateKeyFile /etc/pki/tls/private/localhost.key#SSLCertificateKeyFile /etc/pki/tls/private/apache-selfsigned.key#' /etc/httpd/conf.d/ssl.conf
```

!!! note "Using SED"

    Explanation:

    sudo sed -i 's#old_text#new_text#' /path/to/file: This command replaces old_text with new_text in the specified file (/path/to/file). The # symbol is used as a delimiter instead of the usual / to avoid conflict with the file paths that contain /.

    So we are replacing the localhost key and certificate with the new key we just created.

<!-- Replace SSLCertificateFile /etc/pki/tls/certs/localhost.crt with SSLCertificateFile /etc/pki/tls/certs/apache-selfsigned.crt

Replace SSLCertificateKeyFile /etc/pki/tls/private/localhost.key with SSLCertificateKeyFile /etc/pki/tls/private/apache-selfsigned.key

Ctrl-O
Ctrl-X -->


```
sudo systemctl restart httpd
```

Go to your EC2 Instance and click on the Public IPv4 DNS "open address" link. You'll get a warning. Accept that warning and proceed to the site. Once you are there, you can click on the lock icon to see information about the SSL cert. If you look at the certificate, you'll see the information you provided when you created the certificate.

Submit a screenshot of your website running over https. You'll need to accept the warning and proceed to the website.

## Lab Summary:

In this lab, you learned how to host a website on Amazon EC2 and secure it with SSL/TLS encryption. The lab involved setting up a virtual private cloud (VPC), launching an EC2 instance, configuring a LAMP (Linux, Apache, MySQL, PHP) stack, and enabling SSL using self-signed certificates.

### Key Concepts Explained:

1. **Virtual Private Cloud (VPC):** A VPC is a virtual network dedicated to your AWS account. It allows you to define your own network environment, including IP address ranges, subnets, route tables, and network gateways. In this lab, a custom VPC named vehicleapp was created with public and private subnets.

2. **Amazon EC2 (Elastic Compute Cloud) Instance:** Amazon EC2 provides resizable compute capacity in the cloud. An EC2 instance named vehicleapp-1 was launched within the vehicleapp VPC, configured with a public IP and necessary security group rules to allow HTTP (port 80), HTTPS (port 443), and SSH (port 22) traffic.

3. **Ports:** In computer networking, ports are logical constructs used to identify specific processes or services running on a networked device. Each port is associated with a unique number ranging from 0 to 65535, where lower-numbered ports (0-1023) are reserved for well-known services like HTTP (port 80) and HTTPS (port 443). Ports enable the operating system to direct incoming network packets to the appropriate applications based on their designated port numbers. This allows for efficient and organized communication between different software components and networked devices.

4. **TCP or UDP:** Ports are categorized into two main types: TCP (Transmission Control Protocol) ports and UDP (User Datagram Protocol) ports. TCP ports are used for connection-oriented communication, ensuring reliable and ordered data delivery by establishing a connection between the sender and receiver before transmitting data. UDP ports, on the other hand, facilitate connectionless communication, allowing for faster transmission of data without the overhead of connection setup and error checking. Understanding ports is crucial for network administrators and developers to manage and secure network traffic effectively, ensuring optimal performance and security of networked applications.

5. **TCP/IP:** TCP/IP (Transmission Control Protocol/Internet Protocol) is the fundamental networking protocol suite used to enable communication between devices on the internet. It provides a set of rules and conventions for data transmission and network communication. TCP/IP consists of multiple layers, including the application layer, transport layer, internet layer, and network access layer.

7. **SSL/TLS Encryption:** SSL/TLS encryption secures data transmitted over the web by encrypting the communication between clients and servers. In this lab, a self-signed SSL certificate was generated using openssl, allowing HTTPS access to the hosted website.

8. **Server Configuration and Setup:** Commands were executed on the EC2 instance to update packages (sudo dnf update -y), install necessary software packages (httpd, php, mariadb), configure Apache to start at boot (sudo systemctl enable httpd), and set appropriate permissions on web directories.

9. **SSL Certificate Generation and Configuration:** Self-signed SSL certificates were created using openssl, with details such as organization name, common name (public DNS), and email address. The generated certificate and key were configured in Apache's SSL configuration file (/etc/httpd/conf.d/ssl.conf) to enable HTTPS.

### Reflection Questions:

* Explain the purpose of a Virtual Private Cloud (VPC) in AWS. Why is it important to configure subnets and security groups within a VPC when launching EC2 instances?
* What is SSL/TLS encryption, and why is it important for securing websites? Compare and contrast self-signed certificates with certificates signed by a certificate authority (CA).
* Discuss the steps involved in setting up and configuring Apache web server (httpd) on an EC2 instance. How does Apache handle HTTP and HTTPS requests?
* Explain the significance of server permissions (chmod, chown) in securing web directories. Why is it important to restrict access to certain directories and files on a web server?
* Reflect on the process of generating and configuring SSL certificates using openssl. What information is required when creating a certificate, and how does the certificate ensure secure communication between clients and servers?

## (Optional Reading) Faster Deployment

You can also add "user data" to an EC2 when you create it. This will allow you to run commands automatically after the server starts up. For example, we could add the following user data to automatically install apache and install the web files for us by pasting this code into the user data:

```
#!/bin/bash
sudo su
dnf update -y
dnf install -y httpd wget
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

mkdir -p /tmp/downloads
wget -O /tmp/downloads/quick-oil-part2.zip https://github.com/byui-cse/itm300-course/raw/main/source/module-02/quick-oil-part2.zip
mkdir -p /tmp/lab-app
unzip /tmp/downloads/quick-oil-part2.zip -d /tmp/lab-app
cp -rf /tmp/lab-app/quick-oil-part2/* /var/www/html
rm -rf /tmp/lab-app/
rm -rf /tmp/downloads

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Get the Public IPv4 DNS using the session token
public_dns=$(curl -s "http://169.254.169.254/latest/meta-data/public-hostname" -H "X-aws-ec2-metadata-token: $TOKEN")

sudo dnf install -y openssl mod_ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/pki/tls/private/apache-selfsigned.key -out /etc/pki/tls/certs/apache-selfsigned.crt -subj "/C=US/ST=Idaho/L=Rexburg/O=BYUIStudent/OU=ITM300Class/CN=$public_dns/emailAddress=youremail@byui.edu"

sudo sed -i 's#^SSLCertificateFile /etc/pki/tls/certs/localhost.crt#SSLCertificateFile /etc/pki/tls/certs/apache-selfsigned.crt#' /etc/httpd/conf.d/ssl.conf

sudo sed -i 's#^SSLCertificateKeyFile /etc/pki/tls/private/localhost.key#SSLCertificateKeyFile /etc/pki/tls/private/apache-selfsigned.key#' /etc/httpd/conf.d/ssl.conf
sudo systemctl restart httpd
```

## Helpful other links:

[nginx on Amazon Linux 2023](https://medium.com/@eikachiu/install-nginx-on-amazon-linux-2023-d032160bfc20){:target="_blank"}

[nginx on Amazon Linux 2023 LAMP](https://gist.github.com/atikju/1fb8d3e856e32f3b0a678d393914351b){:target="_blank"}

[OpenSSL Quick Reference Guide](https://www.digicert.com/kb/ssl-support/openssl-quick-reference-guide.htm){:target="_blank"}

[nginx SSL installation guide](https://www.digicert.com/kb/csr-ssl-installation/nginx-openssl.htm){:target="_blank"}

[Hosting Website on EC2 using a LAMP stack](https://docs.aws.amazon.com/linux/al2023/ug/ec2-lamp-amazon-linux-2023.html)

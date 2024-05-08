---
title: Module 02: Project 2 Lab - Host a Website on EC2
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

* Under name tag use: vehicleapp
* Number of Availability Zones: 2
* VPC Endpoints: None

## Create an EC2 instance

* Name the server vehicleapp-1
* Use the vockey for your keypair
* Use the vehicleapp-vpc VPC
* place the EC2 instance in the vehicleapp-subnet-public1 subnet. 
* Enable auto assign an IP address
* Create a security Group and name it vehicle-sg
    * Add security rules to enable ports 80 (HTTP), 443 (HTTPS), and 22 (SSH) all from anywhere

!!! note "Quickly Connecting to your Instance"

    If you use the vockey when you set up the server, you can do the following to easily connect without needing to use a ssh client.

    From the EC2 view of all instances do the following:
    
    * Click the checkmark next to your instance name
    * Click Connect at the top of the screen.
    * Click Connect at the bottom of the next screen.
    
## Server Setup:

Once you are connected to the EC2, run the following commands. Full instructions and explainations are found in the link below.

```
sudo dnf update -y
```

Install the latest versions of Apache web server and PHP packages.

```
sudo dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel
```

Install the MariaDB software packages. Use the dnf install command to install multiple software packages and all related dependencies at the same time.

```
sudo dnf install mariadb105-server
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
exit
```

You'll need to disconnect and reconnect to the EC2 terminal

Change the group ownership of /var/www and its contents to the apache group.
To add group write permissions and to set the group ID on future subdirectories, change the directory permissions of /var/www and its subdirectories.
To add group write permissions, recursively change the file permissions of /var/www and its subdirectories:

```
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
```

Create a PHP file in the Apache document root.

```
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
```

Go to http://{REPLACEWITHYOURINSTANCEIPADDRESS}/phpinfo.php and make sure you get a page that works (**note that it is on http and not https**)

Delete the phpinfo.php file. Although this can be useful information, it should not be broadcast to the internet for security reasons.

```
rm /var/www/html/phpinfo.php
```


Full instructions are found here if you want more details on the code above:

[Hosting Website on EC2 using a LAMP stack](https://docs.aws.amazon.com/linux/al2023/ug/ec2-lamp-amazon-linux-2023.html)

## Download the following files:

Use the following commands to download the zip containing the website you are going to host on EC2. This will happen after you connect to the EC2 instance via ssh.


```
sudo dnf install -y wget
wget https://github.com/byui-cse/itm300-course/raw/main/source/module-02/quick-oil-part2.zip
mkdir /tmp/lab-app
unzip quick-oil-part2.zip -d /tmp/lab-app
mv /tmp/lab-app/quick-oil-part2/* /var/www/html
rm -rf /tmp/lab-app/
```

## Assign an Elastic IP

Go to the Elastic IPs on the sidebar of the EC2 dashboard. Allocate an Elastic IP address and then associate that elastic IP address with your instance.

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

Once we have our cert created, we need to go replace the build-in localhost cert.

```
sudo nano /etc/httpd/conf.d/ssl.conf
```

Replace SSLCertificateFile /etc/pki/tls/certs/localhost.crt with SSLCertificateFile /etc/pki/tls/certs/apache-selfsigned.crt

Replace SSLCertificateKeyFile /etc/pki/tls/private/localhost.key with SSLCertificateKeyFile /etc/pki/tls/private/apache-selfsigned.key

Ctrl-O
Ctrl-X


```
sudo systemctl restart httpd
```

Go to your EC2 Instance and click on the Public IPv4 DNS "open address" link. You'll get a warning. Accept that warning and proceed to the site. Once you are there, you can click on the lock icon to see information about the SSL cert. If you look at the certificate, you'll see the information you provided when you created the certificate.

Submit a screenshot of your website running over https. You'll need to accept the warning and proceed to the website.

## Helpful other links:

[nginx on Amazon Linux 2023](https://medium.com/@eikachiu/install-nginx-on-amazon-linux-2023-d032160bfc20)

[nginx on Amazon Linux 2023 LAMP](https://gist.github.com/atikju/1fb8d3e856e32f3b0a678d393914351b)

[OpenSSL Quick Reference Guide](https://www.digicert.com/kb/ssl-support/openssl-quick-reference-guide.htm)

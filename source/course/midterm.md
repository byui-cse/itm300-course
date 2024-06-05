---
title: Midterm
body-class: index-page
---

## ITM 300 Midterm Instructions

**Do this midterm in your LEARNER LAB enviornment**

!!! note "Important Instructions"

    The instructions for this midterm are not all inclusive. You will be required to figure out what you must install, what additional services you must create, what other ports to enable, and what other configurations are necessary to make the website work as intended.

    Read *ALL* instructions prior to beginning the midterm.

Complete the following:

* Provision an EC2 Linux server in a public subnet with a public IP address.
* Attach a security group with permissions for all IPV4 traffic through on port 80 (HTTP). 
* Enable stop protection in the server's configuration.  
* Assign an Elastic IP Address (static) to the EC2 instance. 
* Install nginx or Apache httpd web server.  
* Configure the web service to start automatically when the EC2 instance starts.

This will be a new server from the server we did in class. 

For the content of the website, you will need to clone the public GitHub repo React [github repo](https://github.com/blaineh-byu/aws-byui-lab-sample-react-site.git){:target="_blank"} into the default website directory being served for index.html. Note, you may need to run the clone command as sudo, ie. sudo git clone https://github.com/blaineh-byu/aws-byui-lab-sample-react-site.git. 

Complete the following:

* Place the repository files found in the **build** folder into the home directory for the web server (/var/www/html for httpd). You may need to install the git package to allow you to clone the repository.
* Edit the index.html file and change the title to include your name
    * change &lt;title&gt;<span style="text-decoration: line-through;">React App</span>&lt;/title&gt;
    * to &lt;title&gt;John Doe&lt;/title&gt;
    * (but use your name instead of John Doe).  
* Submit a video of your website running and with your name in the browser tab. In the video also show the resources you created (ec2, vpc, security groups, etc). 


!!! key "Helpful hints"

    You will need to ssh into your Linux server using the private key that you create while provisioning or just connect via the browser shell (connect option).

    You may look back at other [module labs](https://byui-cse.github.io/itm300-course/modules/) to help you find the commands you need to complete the task, use online resources, or utilize gernative AI (chatGPT) to help you.
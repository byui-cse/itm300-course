---
title: Module 01: Product 1 Lab - Static Site on S3
body-class: index-page
---

![Quick Oil Change and Repair]({{URLROOT}}/shared/img/quick-logo.jpg)
*[Photo by Dall-E-3](https://openai.com/dall-e-3)*

## Product Objective

You will be hosting a static website for your client as a placeholder until the final site is up and ready. You will be hosting the site in an S3 bucket. The files are provided for you.

## Download the following files:

Download the [zip file](./quick-oil-s3-static-site.zip) containing the website you are going to host on S3. You'll need to unzip the files prior to uploading them to your s3 bucket.

## Open up the lab evironment

Go to AWS Academy and get into the "Learner Lab" course. Start up the Learner Lab and go to the AWS console by clicking on the green dot when it appears.


## Tutorial Instructions:

Follow the instructions found on this tutorial:

[Hosting Website on S3 Setup](https://docs.aws.amazon.com/AmazonS3/latest/userguide/HostingWebsiteOnS3Setup.html)

!!! note "Updated instructions"

    When you update the s3 bucket to allow static site hosting you must click the <span class="amz-tab">Properties</span> tab to find <span class="amz-white-button">Edit</span> in the Static website hosting section.

!!! warning "404 Page"

    If you get a 404 page error, one common problem is that the folder was uploaded to the S3 bucket instead of the files from the folder. Inside the S3 bucket you should have an index.html file, a css file, and a folder with images in it.

    ![Directory Structure]({{URLROOT}}/shared/img/directory-structure.jpg)


!!! note "Deleting Resources"

    For this product lab, you can go ahead and delete the S3 bucket as the instructions recommend. For *future* product labs, you will not be deleting those resources because we'll build on the product week by week.


## Helpful other links:

[Website Hosting on Amazon AWS S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)


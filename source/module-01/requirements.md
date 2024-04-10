---
title: Module 01 — Case Study Requirements
---

![Example University]({{URLROOT}}/shared/img/university.jpg)
*[Photo by Darya Tryfanava on Unsplash](https://unsplash.com/@darya_tryfanava)*

## Scenario

Example University is preparing for the new school year. The admissions department has received complaints that their web application for student records is slow or not available during the peak admissions period because of the high number of inquiries.

You are a cloud engineer. Your manager has asked you to create a proof of concept (POC) to host the web application in the AWS Cloud. Your manager would like you to design and implement a new hosting architecture that will improve the experience for users of the web application. You’re responsible for building the infrastructure to host the student records web application in the cloud.

Your challenge is to plan, design, build, and deploy the web application to the AWS Cloud in a way that is consistent with best practices of the AWS Well-Architected Framework. During the peak admissions period, the application must support thousands of users, and be highly available, scalable, load balanced, secure, and high performing.

## Stakeholders

These are the individuals your team will be helping during the case study:

<div class="dialogue">
	<img src="{{URLROOT}}/shared/img/ali.jpg">
	<h5>Dr. Ali Houshman, President of Example University</h5>
	<blockquote><p>I welcome you to this crucial discussion concerning our university's student records system.</p><p>It has become apparent that our current system is plagued by inefficiencies, causing disruptions and eroding student confidence.</p><p>I am optimistic that together, we can develop a proof of concept to transition our system to the cloud, ensuring greater efficiency and reliability.</p>
</blockquote>
</div>

<div class="dialogue">
	<img src="{{URLROOT}}/shared/img/mary.jpg">
	<h5>Mary Cordova, CTO</h5>
	<blockquote><p>Thank you, Dr. Houshman, for your guidance.</p><p>From a technical perspective, our priorities entail scaling the system, implementing load balancing, and minimizing downtime in the event of server failures, and decoupling services.</p><p>These are key to getting the efficiency and reliability we need.</p></blockquote>
</div>

<div class="dialogue">
	<img src="{{URLROOT}}/shared/img/ali.jpg">
	<h5>Dr. Ali Houshman, President of Example University</h5>
	<blockquote><p>Mary, your points are well taken.</p><p>Nonetheless, it's imperative that we adhere to our budget constraints.</p><p>These requirements seem to incur significant costs.</p></blockquote>
</div>

<div class="dialogue">
	<img src="{{URLROOT}}/shared/img/christina.jpg">
	<h5>Christina Stone, CFO</h5>
	<blockquote><p>Dr. Houshman, you raise a valid point.</p><p>Before we begin, I require a thorough estimate of the annual expenses tied to the proposed new system.</p><p>While Mary advocates for cost reduction through migration to "the cloud," I'm still skeptical.</p></blockquote>
</div>

<div class="dialogue">
	<img src="{{URLROOT}}/shared/img/mary.jpg">
	<h5>Mary Cordova, CTO</h5>
	<blockquote><p>Certainly, with the utilization of appropriate services, I am confident we can address these challenges effectively and in a cost efficient manner.</p><p>Before proceeding to the next phase, we will submit an architecture design to ensure adherence to a well-architected framework that is still within budget.</p><p>Additionally, there are some security concerns we must address. I recommend we  migrate our databases to a private network and lock down the database credentials. Given our past experiences with hacking attempts, safeguarding our systems is of utmost importance.</p></blockquote>
</div>

!!!note "Stakeholder Focus Areas"
	The shareholders are particularly interested in the following areas:

	1.	Creating a working proof of concept.
	2.  Finding a way to decouple the services to achieve cost reductions and efficiency.
	3.  Make the new system more fault tolerant.
	4.	Secure all important services.

## Module 01 Requirements

The project must meet the following requirements:

1.	**Functional:** – The solution meets the functional requirements, such as the ability to view, add, delete, or modify the student records, without any perceivable delay.
2.	**Load balanced:** The solution can properly balance user traffic to avoid overloaded or underutilized resources
3.	**Scalable:** The solution is designed to scale to meet the demands that are placed on the application.
4.	**Highly Available:** The solution is designed to have limited downtime when a web server becomes unavailable.
5.	**Secure:** 
	* The database is secured and can't be accessed directly from public networks.
	* The web servers and database can be accessed only over the appropriate ports
	* The web application is accessible over the internet.
	* The database credentials aren't hardcoded into the web application.
6.	**Cost Optimization:** The solution is designed to keep costs low.
7.	**High Performing:** The routine operations (viewing, adding, deleting, or modifying records) are performed without a perceivable delay under normal, variable, and peak loads.

## Assumptions

This project will be built in a controlled lab environment that has restrictions on services, features, and budget. Consider the following assumptions for the project:

* The application is deployed in one AWS Region (the solution does not need to be multi-Regional).
* The website does not need to be available over HTTPS or a custom domain.
* The solution is deployed on Ubuntu machines by using the JavaScript code that is provided.
* Use the JavaScript code as written unless the instructions specifically direct you to change the code.
* The solution uses services and features within the restrictions of the lab environment.
* The database is hosted only in a single Availability Zone.
* The website is publicly accessible without authentication.
* Estimation of cost is approximate.*

Disclaimer: A security best practice is to allow access to the website through the university network and authentication. However, because you are building this application as a POC, those features are beyond the scope of this project. You are encouraged to implement this additional functionality.

!!!note "Wondering Where to Start?"
	Here is an [article](https://docs.aws.amazon.com/prescriptive-guidance/latest/strategy-modernizing-applications/welcome.html) on some basic steps to approach modernizing applications in the AWS Cloud

[^1]: [University photo by Darya Tryfanava on Unsplash](https://unsplash.com/photos/d55fhArDES0)

[^2]: [President photo by Ali Morshedlou on Unsplash](https://unsplash.com/photos/WMD64tMfc4k)

[^3]: [CFO photo by Christina @ wocintechchat.com on Unsplash](https://unsplash.com/photos/0Zx1bDv5BNY)

[^4]: [CTO photo by LinkedIn Sales Solutions ](https://unsplash.com/photos/wS73LE0GnKs)
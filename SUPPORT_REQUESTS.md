# Support Requests

Before going live, there are AWS Support requests to be raised.

## ALB Warm-up

### Pre-requisites
* Business support level
* Application Load Balancer DNS
* Expected go-live date and time
* Tenant application name
* Anticipated requests/sec that will go through the load balancer 

### Request template
Subject: Pre-warm production ALB _ALB URL_ 

Severity: General guidance

Category: Elastic Load Balancing (ELB), Other


```text
1. What is the DNS name for the ELB(s) that require manual scaling: 
_ALB URL_ 

2. Event start date/time (please specify the timezone; UTC is preferred): 
_DATE/TIME_

3. Event end date/time (please specify the timezone; UTC is preferred) ongoing: 
For 1 month after the start date

4. Expected percent of traffic going through the ELB that will be using SSL termination: 
0% TLS is terminated at the APIGateway/Cloudfront which connects to the ALB on 80

5. Anticipated requests/sec that will go through the load balancer: 
_RATE/SEC_

6. The average amount of data in bytes passing through the ELB per request/response pair: 
Payloads are small, average is around 3k but will not expect large payloads

7. Number of Availability Zones enabled: 
3

8. Is the back-end currently scaled to the level it will be during the event: 
No, using ECS Application Auto Scaling.

9. A description of the traffic pattern you are expecting: 
Initial intense usage, potentially with sudden ramp-up. Lower but sustained usage over time.

10. A brief description of your use case: 
This is the back-end API for the _TENANTS APPLICATION NAME_ app. It will have a high-profile launch, with lots of initial traffic as citizens sign up, followed by lower but sustained use over the coming months. Exact numbers are hard to predict but given the high profile and visibility, we need to err on the side of caution.

11. Have you disabled persistent connections (keep-alive) on your backend instances? 
No

12. Rate of traffic increase. How fast do you expect your traffic to change once your event starts (use days/hours/minutes as appropriate): 
Potentially full load in a short space of time (e.g. if launch features on a national news bulletin)
```

## Lambda regional concurrent executions

### Pre-requisites
* Authorizer lambda ARN
* Tenant application name

Subject: Limit Increase: Lambda

Severity: Business impairing question

Category: Service Limit Increase, Lambda

```text
1. Provide the main lambda functions ARNs of this application. What do they do? 
_AUTHORIZER_LAMBDA_ARN_
Lambda authorizer for API Gateway.

2. Will these functions be VPC enabled? 
No.

3. Average transactions per second. 
100 with a significant spikes up to couple of thousands.

4. Average duration. 
Estimated average is 100ms

5. Average memory size. 
512

6. What does the application do? 
Backend for the _TENANTS APPLICATION NAME_ app.

7. What services does your application depend on? Have they been scaled? 
Lambda in question does not have dependencies on other services.

8. What are the event sources? 
API Gateway authorizer.

9. Average TPS for each function with a concurrency reservation. 
100
```

## SNS SMS Spent limit

### Pre-requisites
* Expected spent
* Tenant country
* Expected rate of messages to be send
* Tenant application name

Subject: Limit Increase: SNS

Severity: Business impairing question

Category: Service Limit Increase, SNS

```text
1. The spending limit you are requesting, in US dollars.
_EXPECTED SPENT_ (typically <$1000) (see SNS/SMS pricing for calculations)

2. A list of countries in which the recipients of your messages are located.
_TENANT COUNTRY_

3. Information about the type of messages you will be sending (Transactional, Promotional, One-Time Password, etc.)
OTP

4. The maximum number of messages you expect to send per day.
_EXPECTED RATE_

5. What is the name of the website, application, or other entity that will be sending SMS messages? Please provide a link.
_TENANTS APPLICATION NAME_

6. Explain the opt-in process to receive your messages.
All users that installs the mobile app that decides to notify about infection.

7. Describe the primary function of your site or application and how SMS will be incorporated.
One time password for reporting confirmed COVID-19 infection.

8. Details of the ways in which you will ensure you are only sending to people who have requested your messages.
Robust testing of the app.
```

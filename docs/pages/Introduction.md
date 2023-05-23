# Introduction
## What is it?
It's a minimalistic framework that's meant to centralize performing http requests, provide an easy-to-understand API which at the same time does not limit the developer's flexibility needed to handle more complex scenarios.

## Key Characteristics
- Metadata based request configuration
- Strong focus on readability, testability and extensibility
- Self-contained (no dependencies on any other tool)
- Ability to mock responses at runtime
- Fully unit tested
- Fully documented

## General Flow
This section aims to provide a general idea about the steps that need to be taken in order to integrate with a simple endpoint. For more elaborate examples, see the [Examples](Examples.md) section of the documentation.

1. Create a record of **PT_HttpRequest__mdt** containing request information (such as endpoint, max timeout, http method etc.).
2. Create a class deriving from **PT__HttpRequestBodyBase** class (or implementing the **PT_IHttpRequestBody** interface). This class should contain the fields required by the endpoint. 
3. Inside your business logic, create an instance of **PT_HttpRequest** class using the value of **PT_Identifier__c** field on the metadata record created as part of step 1. 
4. Use the instance of your class created in step 2 to set the body of the **PT_HttpRequest** instance from step 3. 
5. Use the instance of the **PT_Http** class to send the request and receive the _HttpResponse_. 

## Installation
### Using Salesforce CLI
There are multiple ways to bring the framework to your codebase. The simplest one is to clone the repository and use Salesforce CLI to deploy it to the org. 
```bash
#clone the repository
git clone git@github.com:x1r15/PT_HttpRequestFramework.git 
#log into the org where you want to deploy the changes to
sf org login web --instance-url [instanceUrl] --alias [alias] 
#deploy content of force-app folder to that org
sf deploy start --source-dir force-app/ -o [alias]
```
### Using your IDE
Alternatively, you can clone the repository and drop its content into your SFDX project. Once the files are in the right folders, simply use your IDE to deploy them.  

## Want to get in touch?
Contact me via [linkedin](https://www.linkedin.com/in/piotr-wyszynski-781968ab/)

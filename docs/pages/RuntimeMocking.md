# Runtime Mocking
The functionality has been added as Salesforce does not natively support runtime http response
mocking. Lack of the feature makes it hard to:
- Test specific system functionality in complete isolation from external services.
- Simulate different types of responses.
- Provide the SF side ready solution when third party service is not yet ready.

## How to
1. Create a record of custom metadata type **PT_HttpResponseMock__mdt**. Please notice that if
   needed, you can create some generic responses like Status Code: 200 and an empty body.
2. Go to the callout configuration record (**PT_HttpRequest__mdt**) and connect the mock via the
   **PT_ActiveMock__c** field.

From that point, the request will be returning mocked response. If you want it to start performing
the actual request, simply empty the **PT_ActiveMock__c** field.

## PT_HttpResponseMock__mdt
Simple metadata used to configure the response returned. It contains two relevant fields:
- Status Code (Integer, 3, 0) - used to set the Status Code of the HttpResponse
- Body (Long Text, 32768) - used to set the Body of the HttpResponse
- Description (String, 255) - can be used to provide some extra information

The *Developer Name* is not relevant from the framework's code base point of view as the record
is retrieved based on the relationship field (**PT_ActiveMock__c**) on the **PT_HttpRequest__mdt**
record.

## PT_IMockable
The **PT_HttpRequestBase** class implements the **PT_IMockable** interface which allows it
to provide mock (**PT_IHttpResponseMock**) instance. Please bear in mind that in case you have
implemented your own **PT_IHttpRequest** you will also have to implement *this* interface in order
to receive mocks. The **PT_Http** class is able to work with any instance of **PT_IMockable**. So
you will not need a custom implementation of **PT_IHttp**.

## PT_IHttpResponseMock
It's a runtime equivalent of the native *HttpCalloutMock* interface. It's implemented by
**PT_RuntimeHttpResponseMock** which provides the runtime mock based on the **PT_HttpResponseMock__mdt**
record connected with **PT_HttpRequest__mdt** via **PT_ActiveMock__c** field.

## Example use cases
- You are developing code that depends on a very specific circumstances which are very hard to
  simulate or the result (most often error) of the request is non-deterministic.
- Requests to the API are paid, and you want to avoid making unnecessary callouts.
- The API you are trying to call is temporarily unavailable or not yet developed.
- The response time is significant and affects testing.


## Other important information
- As the request is performed within **PT_Http** class this is where mocked response is returned.
  If you decide to go with custom implementation of **PT_IHttp** logic, you will not be able to benefit
  from the runtime mocking unless you implement this logic yourself.
- To facilitate testability, it has been decided that the metadata based mock *will not be returned*
  in unit tests. Doing so would create a test dependency on metadata records, thus whenever you write
  tests, you will have to mock the response using native *HttpCalloutMock*.

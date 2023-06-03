# Examples
This section is meant to facilitate your development using the framework. Provided snippets can be used as a starting point or reference when integrating with external services.

Each example contains not only code but also a description and some tips. If you are not familiar with how the framework works, it is recommended to go through all the examples top to bottom. 

## List of examples
1. Basics
   1. Simple GET request
   2. GET request with URL template
   3. GET request with query params
   4. POST request
   5. Unit testing your requests
2. Misc
   1. Adding pre and post request actions
   2. Using runtime mocks

## Examples

All the examples are based on https://jsonplaceholder.typicode.com/ API.
It's assumed that the Named Credentials "JsonPlaceholder" were created.

### Simple GET request

In this example we'll use the `/todos` endpoint. It returns a list of all available TODOs. 

#### Creating metadata record

The first step is to create the **PT_HttpRequest__mdt** record. 
1. In the setup, navigate to _Custom Metadata Types_. 
2. Click the _Manage Records_ link located next to **PT_HttpRequest** metadata name. 
3. Click on the _New_ button. 
4. Feel the fields:
   - **Label:** JsonPlaceholder_GET_Todos_SB
   - **PT_HttpRequest Name:** JsonPlaceholder_GET_Todos_SB
   - **Identifier:** JsonPlaceholder_GET_Todos
   - **Http Method:** GET
   - **Named Credentials:** JsonPlaceholder
   - **Endpoint:** /todos
   - **Use in Production:** Unchecked
5. Click _Save_. 

> **Tip:** As you see, the Label & the Name are suffixed with "SB" to easily distinguish the Sandbox records from Production ones. The identifier does not have a suffix. The value in that field should be exactly the same for all environments.

> **Tip:** To ensure your solution is always production ready, it's advised to create the production record directly after creating the sandbox one. In case the API is not yet live, you can use the runtime mocking or hide the related functionality behind a feature toggle.

> **Tip:** To avoid mistakes while creating production records, you can simply _clone_ the sandbox record and set the **Use in Production** flag to true. 

#### Creating a request body class

_As the endpoint does not require providing a body, we don't have to create any extra class._

#### Implementing business logic

We'll need a place to keep the Identifier of the metadata (we don't want to use magic strings in our code! More about it in [Good Practices](GoodPractices.md) section). I am creating a dedicated class for that. 

```Apex
public class JsonPlaceholderRequests {
    //As more identifiers related to that service are expected, they can all be placed in a dedicated class.
    public static final String GetTodos = 'JsonPlaceholder_GET_Todos';
}
```

The TODO item looks like this:

```JSON
{
   "userId": 1,
   "id": 1,
   "title": "delectus aut autem",
   "completed": false
}
```

Let's create a model class for it.

```Apex
public class Todo {
    Integer userId;
    Integer id;
    String title;
    Boolean completed;
}
```

>**Tip:** Remember there is nothing wrong with having a little bit of relevant logic within your model classes. It's a perfect place to implement e.g. conversion to sObject (preferably with a common interface for all models that can be mapped to sObjects). 

Then we use the core framework classes to perform the request.

```Apex
public class JsonPlaceholder_SimpleGet {

   public void someMethod() {
      //Create an instance of PT_HttpRequest related to our metadata record
      PT_IHttpRequest request = new PT_HttpRequest(JsonPlaceholderRequests.GetTodos);

      //Create an instance of PT_Http
      PT_IHttp http = new PT_Http();

      //Use the http instance to send the request and receive native HttpResponse
      HttpResponse response = http.send(request);

      //If everything went ok deserialize the body, otherwise process error.
      if (response.getStatusCode() == 200) {
         List<Todo> todos = (List<Todo>)JSON.deserialize(response.getBody(), List<Todo>.class);
         //[...]
      }
      //[...]
   }
}
```

We create a PT Request and send it using PT Http. The general idea is similar to the native SF implementation. The only difference is that populating request specific data is happening behind the scene on the basis of the metadata record.

### GET request with URL template (parametrized url)
In this example, we'll explore how to make a request to a parametrized endpoint. Example of such an endpoint would be `/lightning/r/Account/0012500001fvmbkAAA/view`. Its Id part is dynamic, and will lead us to different records, depending on the value we provide. We can use a String template to describe this type of endpoint. In this case, it would be:

`/lightning/r/Account/{0}/view` - where {0} will be replaced by the record Id.

If your endpoint requires more than one parameter, you can simply use consecutive Integers e.g. `/project/{0}/task/{1}/subtask/{2}`.

We'll continue here using the snippets from the **Simple GET request** example. The Todos API allows us to request data about a specific Todo item, rather than all of them. 

#### Creating metadata record

The first step is to create the **PT_HttpRequest__mdt** record.
1. In the setup, navigate to _Custom Metadata Types_.
2. Click the _Manage Records_ link located next to **PT_HttpRequest** metadata name.
3. Click on the _New_ button.
4. Feel the fields:
   - **Label:** JsonPlaceholder_GET_Todo_SB
   - **PT_HttpRequest Name:** JsonPlaceholder_GET_Todo_SB
   - **Identifier:** JsonPlaceholder_GET_Todo
   - **Http Method:** GET
   - **Named Credentials:** JsonPlaceholder
   - **Endpoint:** /todos/{0}
   - **Use in Production:** Unchecked
5. Click _Save_. 

#### Implementing business logic

We'll utilize model class created in the previous example. However, we'll need to add our _metadata identifier_ to the JsonPlaceholderRequests class. 

```Apex
public class JsonPlaceholderRequests {
    //[...]
    public static final String GetTodo = 'JsonPlaceholder_GET_Todo';
}
```

And then from within our business logic, we perform the request. The only additional step is using the `public PT_IHttpRequest setParams(List<String> values)` method, which allows us to set the endpoint parameters. 

```Apex
public class JsonPlaceholder_ParametrizedGet {

   public void someMethod() {
      //Create an instance of PT_HttpRequest related to our metadata record
      PT_IHttpRequest request = new PT_HttpRequest(JsonPlaceholderRequests.GetTodo);
      //We set the parameters. We want only one Todo item - the one with Id "7"
      request.setParams(new List<String> {'7'});
      //If your endpoint would require more params e.g. /{0}/{1}/{2} 
      //You'd do request.setParams(new List<String> {'a', 'b', 'c'});
      //Where {0} would be replaced with 'a', {1} with 'b', and {2} with 'c'.

      //Create an instance of PT_Http
      PT_IHttp http = new PT_Http();

      //Use the http instance to send the request and receive native HttpResponse
      HttpResponse response = http.send(request);

      //If everything went ok deserialize the body, otherwise process error.
      if (response.getStatusCode() == 200) {
         Todo todo = (Todo)JSON.deserialize(response.getBody(), Todo.class);
         //[...]
      }
      //[...]
   }
}
```

As you see, the idea is similar to sending regular PT_HttpRequest. The only difference providing the parameters using the `setParams` method. 

### GET request with query params
The **jsonplaceholder** API allows us to retrieve data of the entity `comment` two different ways. First we can use parametrized url as we have seen in previous example `/posts/xxx/comments` where **xxx** is the post ID. Alternatively we can use the `/comments` endpoint and provide the `postId` query parameter. 

To specify the query params, we add the `?` character after the endpoint. Then we provide a param in a form `name=value` e.g. `postId=1`. If we have more than one parameter, we simply separate them using `&` character.

Example: `/comments?postId=1&by=Jarek` - here we provide 2 params to the `/comments` endpoint. First one `postId` with a value of `1`, and `by` with a value of `Jarek`. 

_Please notice the `by` param does not exist in the **jsonplaceholder** API, it has been given here only as an example._

Luckily, the framework does all the hard work for you.

#### Creating metadata record

The first step is to create the **PT_HttpRequest__mdt** record.
1. In the setup, navigate to _Custom Metadata Types_.
2. Click the _Manage Records_ link located next to **PT_HttpRequest** metadata name.
3. Click on the _New_ button.
4. Feel the fields:
   - **Label:** JsonPlaceholder_GET_Comments_SB
   - **PT_HttpRequest Name:** JsonPlaceholder_GET_Comments_SB
   - **Identifier:** JsonPlaceholder_GET_Comments
   - **Http Method:** GET
   - **Named Credentials:** JsonPlaceholder
   - **Endpoint:** /comments
   - **Use in Production:** Unchecked
5. Click _Save_.

#### Implementing business logic

First of all, let's add our metadata record to our request list (check Implementing business logic section of the Simple GET request example.):

```Apex
public class JsonPlaceholderRequests {
    //[...]
    public static final String GetComments = 'JsonPlaceholder_GET_Comments';
}
```
Then, we need to create the model class to be able to conveniently deserialize the response.

The example comment looks like this:
```JSON
{
    "postId": 1,
    "id": 1,
    "name": "id labore ex et quam laborum",
    "email": "Eliseo@gardner.biz",
    "body": "laudantium enim quasi est quidem magnam voluptate ipsam eos\ntempora quo necessitatibus\ndolor quam autem quasi\nreiciendis et nam sapiente accusantium"
  }
```

Thus, we'll need a class:

```Apex
public class Comment {
    public Integer postId;
    public Integer id;
    public String name;
    public String email;
    public String body;
}
```

Because we want to provide the query params, we'll need one more class - for the body. This approach allows us to share bodies among multiple requests and also provides type safety. 

```Apex
public class GetCommentsRequestBody extends PT_HttpRequestBodyBase {
    public Integer postId;
}
```

Notice that we are extending the **PT_HttpRequestBodyBase**. The base class provides a convenient serialization methods which are used under the hood by the PT_Http class when performing requests.

Finally, within our business logic, we perform the request. The only difference between this and the previous examples is: this time we have to set the request body using `public PT_IHttpRequest setBody(PT_IHttpRequestBody body)`.

```Apex
public class JsonPlaceholder_QueryParams {
   public void someMethod() {
      //Create a body and set all the body fields
      GetCommentsRequestBody body = new GetCommentsRequestBody();
      body.postId = 1;

      //Create an instance of PT_HttpRequest related to our metadata record
      PT_IHttpRequest request = new PT_HttpRequest(JsonPlaceholderRequests.GetComments);
      //Set body on the request - because of the requests GET http method it will be converted to query params
      request.setBody(body);

      //Create an instance of PT_Http
      PT_IHttp http = new PT_Http();

      //Use the http instance to send the request and receive native HttpResponse
      HttpResponse response = http.send(request);

      //If everything went ok deserialize the body, otherwise process error.
      if (response.getStatusCode() == 200) {
         List<Comment> comments = (List<Comment>)JSON.deserialize(response.getBody(), List<Comment>.class);
         //[...]
      }
      //[...]
   }
}
```

### POST Request
When you are using the framework, the POST requests do not differ much from the GET requests, especially those with **query params**. The only noticeable difference is the **Http Method** setting on the metadata requests. 

In this example we'll utilize the `/posts` endpoint to create a post record. Pun not indented ;).

#### Creating metadata record

The first step is to create the **PT_HttpRequest__mdt** record.
1. In the setup, navigate to _Custom Metadata Types_.
2. Click the _Manage Records_ link located next to **PT_HttpRequest** metadata name.
3. Click on the _New_ button.
4. Feel the fields:
   - **Label:** JsonPlaceholder_POST_Post_SB
   - **PT_HttpRequest Name:** JsonPlaceholder_POST_Post_SB
   - **Identifier:** JsonPlaceholder_POST_Post
   - **Http Method:** POST
   - **Named Credentials:** JsonPlaceholder
   - **Endpoint:** /posts
   - **Use in Production:** Unchecked
5. Click _Save_.

#### Implementing business logic

First of all, let's add our metadata record to our request list (check Implementing business logic section of the Simple GET request example.):

```Apex
public class JsonPlaceholderRequests {
    //[...]
    public static final String PostPost = 'JsonPlaceholder_POST_Post';
}
```
Now this part will be interesting. Because the body of the `/post` POST request requires us to provide data in a form of an actual post. That means, our **model** class and our **request body** will be almost exactly the same. 

> **Tip:** It may seem like an obvious decision to use one class for both of them. This however, even though it helps us keep the code DRY, neglects the single responsibility principle and negatively affects code readability (e.g. how would you name a class which is your model and your request body at the same time?). Ultimately, this is purely a project decision and each instance should be considered within its own context.

We start by creating a model class which will be used to deserialize the response:

```Apex
public class Post {
   public Integer userId;
   public Integer id;
   public String title;
   public String body;
}
```

> **Tip:** Notice that some of our model classes contain `userId` and `id`. This means it may be worth extracting those to a base class.

Now let's create our request body class: 

```Apex
public class PostPostRequestBody extends PT_HttpRequestBodyBase {
   public Integer userId;
   public Integer id;
   public String title;
   public String body;
}
```

As discussed previously, we simply extend the **PT_HttpRequestBodyBase** and provide the relevant fields.

> **Tip:** Remember that within modern SF projects you can create a sub-folders within the _classes_ folder. That allows you to organize you files into logical groups e.g. keeping all models together and all bodies together. 


The last part is to simply perform the request in our business logic.

```Apex
public class JsonPlaceholder_Post {
   public void someMethod() {
      //Create a body and set all the body fields
      PostPostRequestBody body = new PostPostRequestBody();
      body.id = 1;
      body.userId = 1;
      body.title = 'Lorem Ipsum';
      body.body = 'Os iusti meditabitur sapientiam, Et lingua eius loquetur indicium.';

      //Create an instance of PT_HttpRequest related to our metadata record
      PT_IHttpRequest request = new PT_HttpRequest(JsonPlaceholderRequests.PostPost);
      //Set body on the request
      request.setBody(body);

      //Create an instance of PT_Http
      PT_IHttp http = new PT_Http();

      //Use the http instance to send the request and receive native HttpResponse
      HttpResponse response = http.send(request);

      //If everything went ok deserialize the body, otherwise process error.
      if (response.getStatusCode() == 201) {
         Post post = (Post)JSON.deserialize(response.getBody(), Post.class);
         //[...]
      }
      //[...]
   }
}
```

There is a one very subtle difference. If you have a look at the status code, the API responded with **201** (Created) instead of **200** (Success) which is pretty common for requests resulting in some kind of record creation.

_Notice that the API responds with JSON containing only the record id (which also is pretty common for this type of APIs). However, for the sake of this tutorial I preferred to keep it as a whole object as this allowed me to discuss some extra details._

### Unit testing your requests
In this example, we'll be testing our POST request. Before we start, you should be familiar with the **HttpCalloutMock** interface. Please go through these [docs](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_interface_httpcalloutmock.htm) and this [trailhead](https://trailhead.salesforce.com/content/learn/modules/apex_integration_services/apex_integration_rest_callouts). 

Let's slightly adjust our POST request to support testing. 
```Apex
//Our method returns the received Id
public Integer someMethodTestable() {
   //Create a body and set all the body fields
   PostPostRequestBody body = new PostPostRequestBody();
   body.id = 1;
   body.userId = 1;
   body.title = 'Lorem Ipsum';
   body.body = 'Os iusti meditabitur sapientiam, Et lingua eius loquetur indicium.';

   //Create an instance of PT_HttpRequest related to our metadata record
   PT_IHttpRequest request = new PT_HttpRequest(JsonPlaceholderRequests.PostPost);
   //Set body on the request
   request.setBody(body);

   //Create an instance of PT_Http
   PT_IHttp http = new PT_Http();

   //Use the http instance to send the request and receive native HttpResponse
   HttpResponse response = http.send(request);

   //If everything went ok deserialize the body and return the Id otherwise return -1
   Post post;
   if (response.getStatusCode() == 201) {
      post = (Post) JSON.deserialize(response.getBody(), Post.class);
   }
   return post != null ? post.id : -1;
}
```

Now we need to create our test class:

```Apex
//We create a class, annotate it with @IsTest and make it private
@IsTest
private class JsonPlaceholder_Test {
}
```

Then within that class we create a mock class.
> **Tip:** You may want to create a more generic, shared mock class that supports multiple response types. There is a plan to add a shared mock to the framework in the future.  

```Apex
@IsTest
private class JsonPlaceholder_Test {
    //We create an inner class implementing HttpCalloutMock interface.
    public class MockResponse implements HttpCalloutMock {
        private final Post body; // field for an object to respond with
        private final Integer statusCode; // field to store status code to respond with

        //Simple constructor to store the info required for the response
        public MockResponse(Post body, Integer statusCode) {
            this.body = body;
            this.statusCode = statusCode;
        }

        //Method which creates the response for us and returns it
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            //We serialize the object to body...
            res.setBody(JSON.serialize(body));
            //...and set the status code
            res.setStatusCode(statusCode);

            //finally, we return the whole response
            return res;
        }
    }
}
```

And finally, we add our first test.

```Apex
    //[...]
    //We create a method, annotate it with @IsTest, make it static and keep it private by not providing visibility modifier
    @IsTest
    static void createPost_Success_Test() { //The name states clearly the scenario
        //We arrange the data. We mark this section with //Arrange comment

        //Arrange
        Post responsePost = new Post();
        responsePost.id = 1; // We want to receive the id as part of the response
        Integer responseStatusCode = 201; // We want to receive 201 status code
        //We create a response mock instance;
        HttpCalloutMock responseMock = new MockResponse(responsePost, responseStatusCode);
        //And we push it to the native testing framework
        Test.setMock(HttpCalloutMock.class, responseMock);

        //Now we execute the actual business logic. We annotate this section with //Act comment
        //Act
        Test.startTest();
        Integer receivedId = new JsonPlaceholder_Post().someMethodTestable();
        Test.stopTest();

        //And now we verify if the logic worked as expected. We annotate this section with //Assert comment
        //Assert
        System.assertEquals(responsePost.id, receivedId);
    }
//[...]
```

Now let's create another test. This time for a failure scenario. For brevity, I am going to keep it without any extra comments. I believe it will be ok as this test will be even simpler than the previous one.

```Apex
    @IsTest
    static void createPost_Failure_Test() {
        //Arrange
        Integer expectedId = -1;
        Integer responseStatusCode = 400; // Bad request
        HttpCalloutMock responseMock = new MockResponse(null, responseStatusCode);
        Test.setMock(HttpCalloutMock.class, responseMock);

        //Act
        Test.startTest();
        Integer receivedId = new JsonPlaceholder_Post().someMethodTestable();
        Test.stopTest();

        //Assert
        System.assertEquals(expectedId, receivedId);
    }
```

### Adding pre- and post-request actions
There are situations where you may want to do some extra processing while of the request or response. The most common example would be to create log records containing the request and response data. 

Let's assume we have a logger which looks something like this:

```Apex
public class FakeLogger {
    public void debug(HttpRequest request) {
        //Do some debug actions like print System.debug();
    }
    public void createLogs(HttpRequest request, HttpResponse response) {
        //Create some records, insert them
    }
}
```

Now, let's use it. PT_Http has some protected methods which can be used to add pre- and post-request actions. Those are:

`void beforeRequest(HttpRequest request)`  
`void afterRequest(HttpRequest request, HttpResponse response)`

To be able to override them, we need to create a class which extends the **PT_Http** class:

```Apex
//We start by creating a class extending PT_Http
public class LoggedHttp extends PT_Http {

}
```

Now we override the methods and inside them, we add our 'custom' logic:

```Apex
public class LoggedHttp extends PT_Http {
    //We add the instance level logger service
    private FakeLogger logger = new FakeLogger();
    
    // We keep the methods protected, and for both of them we use the override keyword
    protected override void beforeRequest(HttpRequest request) {
        //We use our logger
        logger.debug(request);
    }
    
    protected override void afterRequest(HttpRequest request, HttpResponse response) {
        //We use our logger
        logger.createLogs(request, response);        
    }
}
```

Now, the only thing left for us to do is to use our `LoggedHttp` instead of the PT_Http class inside our code. That means that instead of:

```Apex
PT_IHttp http = new PT_Http();
HttpResponse response = http.send(request);
```

We would simply do:

```Apex
PT_IHttp http = new LoggedHttp();
HttpResponse response = http.send(request);
```

### Using runtime mocks 
This section assumes you have already read the [Runtime Mocking](RuntimeMocking.md) section of the documentation and, you are familiar with the previous examples, especially the POST request one.

In this example, we'll assume that the POST request we have been working with is undergoing some serious maintenance. As a result, we cannot rely on it. We agreed with the business that temporarily we want to respond with **201** to all requests. We want the mock to respond with id **-999**. This way, when we insert SF records with this id, we'll be able to easily query all of those records and undertake the required actions.

#### Creating the mock record

The first step is to create the **PT_HttpRequest__mdt** record.
1. In the setup, navigate to _Custom Metadata Types_.
2. Click the _Manage Records_ link located next to **PT_HttpResponseMock** metadata name.
3. Click on the _New_ button.
4. Feel the fields:
   - **Label:** AlwaysSucceedWithFixedId
   - **PT_HttpResponseMock Name:** AlwaysSucceedWithFixedId
   - **Status Code:** 201
   - **Body:** {"id": -999}
5. Click _Save_.

#### Connect mock to the request

1. In the setup, navigate to _Custom Metadata Types_.
2. Click the _Manage Records_ link located next to **PT_HttpRequest** metadata name.
3. Click on the name of the request you want to mock. In our case **JsonPlaceholder_POST_Post**.
4. Click on the _Edit_ button.
5. Set the **Active Mock** field to our newly created **AlwaysSucceedWithFixedId** mock record.
6. Click _Save_.

From now on, all requests using the **JsonPlaceholder_POST_Post** metadata will respond with the data provided on the mock record. 

_Please bear in mind, the tests are unaffected by mocking, as they are not performing the actual requests. This allows you to safely set mocks in both sandboxes and production without worrying about failing Unit Tests._

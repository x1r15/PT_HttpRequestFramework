# Examples
This section is meant to facilitate your development using the framework. Provided snippets can be used as a starting point or reference when integrating with external services.

Each example contains not only code but also a description and some tips. If you are not familiar with how the framework works, it is recommended to go through all the examples top to bottom. 

## List of examples
1. Basics
   1. Simple GET request
   2. GET request with URL template
   3. GET request with query params
   4. Making a POST request
   5. Unit testing your requests
2. Misc
   1. Adding pre and post request actions
   2. Using runtime mocks 
   3. Utilizing mocks metadata in unit tests

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
      PT_HttpRequest request = new PT_HttpRequest(JsonPlaceholderRequests.GetTodos);

      //Create an instance of PT_Http
      PT_Http http = new PT_Http();

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

### GET request with URL template
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
      PT_HttpRequest request = new PT_HttpRequest(JsonPlaceholderRequests.GetTodo);
      //We set the parameters. We want only one Todo item - the one with Id "7"
      request.setParams(new List<String> {'7'});
      //If your endpoint would require more params e.g. /{0}/{1}/{2} 
      //You'd do request.setParams(new List<String> {'a', 'b', 'c'});
      //Where {0} would be replaced with 'a', {1} with 'b', and {2} with 'c'.

      //Create an instance of PT_Http
      PT_Http http = new PT_Http();

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


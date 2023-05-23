# Tips & Good Practices

## Avoid modifying the framework code
Avoid modifying the framework classes as it may prevent you from upgrading them to new versions. Aim to extend the classes you want to build upon or if you need even more flexibility use one of the provided interfaces e.g. `PT_IHttp`, however bear in mind this will result in loss of existing class capabilities.

## Avoid using magic strings
**PT_HttpRequest** requires you to provide the identifier of the related metadata record. The simplest way and the most obvious way of doing that is to simply pass it as a string e.g.

```Apex
new PT_HttpRequest('MyFirstRequest');
```

It's advised to do not use **magic strings** at all. Here are multiple ways of dealing with that issue:

### Use Enum
An _enum_ containing identifiers of the metadata records can be created (or even better generated). Example:

```Apex
public enum HttpRequestTypes {
    MyFirstRequest,
    MySecondRequest, 
    MyThirdRequest
}
```
Then the value can be easily converted to String:
```Apex
String identifier = HttpRequestTypes.MyFirstRequest.name();
```

### Use Const
Probably the easiest alternative to use **magic string** is to use _constant_. It can be defined within the business class responsible for making the request or within a class holding a group of related constants. Example:
```Apex
public static final String Identifier = 'MyFirstRequest';
```

Please bear in mind using a large class, with all the constants, is discouraged. It may seem convenient, unfortunately, in large Salesforce implementations it can have a significant impact on the heap, as all the constants within a class are loaded into memory. 

It's much better to create a dedicated, specialized set of constant classes which hold only closely related constants or even better store the constants in the relevant business classes. 

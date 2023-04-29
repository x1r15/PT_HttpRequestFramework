/**
 * Class to build upon. Probably best place to add request and response logging.
 */
public virtual class PT_Http implements PT_IHttp {

    private static final Http http = new Http();

    public HttpResponse send(PT_IHttpRequest request) {
        HttpRequest httpRequest = request.toRequest();
        beforeRequest(httpRequest);
        HttpResponse httpResponse;
        if (shouldReturnMock(request)) {
            httpResponse = ((PT_IMockable)request).getMock();
        } else {
            httpResponse = http.send(httpRequest);
        }
        afterRequest(httpRequest, httpResponse);
        return httpResponse;
    }

    private static Boolean shouldReturnMock(PT_IHttpRequest request) {
        PT_IMockable mockable;
        try {
            mockable = (PT_IMockable) request;
        } catch (TypeException ex){
            return false;
        }
        return mockable.shouldBeMocked();
    }

    protected virtual void beforeRequest(HttpRequest request) {}

    protected virtual void afterRequest(HttpRequest request, HttpResponse response) {}
}
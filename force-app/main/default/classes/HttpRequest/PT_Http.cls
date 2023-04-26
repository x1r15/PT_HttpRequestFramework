/**
 * Class to build upon. Probably best place to add request and response logging.
 */
public virtual class PT_Http implements PT_IHttp {

    private static final Http http = new Http();

    @TestVisible
    private static HttpResponse responseMock;

    public HttpResponse send(PT_IHttpRequest request) {
        if (responseMock != null) {
            return responseMock;
        }
        HttpRequest httpRequest = request.toRequest();
        beforeRequest(httpRequest);
        HttpResponse httpResponse = http.send(httpRequest);
        afterRequest(httpRequest, httpResponse);

        return httpResponse;
    }

    protected virtual void beforeRequest(HttpRequest request) {}

    protected virtual void afterRequest(HttpRequest request, HttpResponse response) {}
}
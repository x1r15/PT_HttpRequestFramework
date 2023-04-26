/**
 * Class to build upon. Probably best place to add request and response logging.
 */
public class PT_Http implements PT_IHttp {
    private static final Http http = new Http();

    @TestVisible
    private static HttpResponse responseMock;
    public HttpResponse send(PT_IHttpRequest request) {
        if (responseMock != null) {
            return responseMock;
        }
        return http.send(request.toRequest());
    }
}

public class PT_RuntimeHttpResponseMock implements PT_IHttpResponseMock {
    //Not storing HttpResponse to avoid potential serialization issues;
    private final Integer statusCodeMocked;
    private final String bodyMocked;

    public PT_RuntimeHttpResponseMock(Integer statusCode, String body) {
        statusCodeMocked = statusCode;
        bodyMocked = body;
    }

    public HttpResponse respond(HttpRequest request) {
        HttpResponse httpResponseMock = new HttpResponse();
        if (!String.isEmpty(bodyMocked)) {
            httpResponseMock.setBody(bodyMocked);
        }
        httpResponseMock.setStatusCode(Integer.valueOf(statusCodeMocked));
        return httpResponseMock;
    }
}

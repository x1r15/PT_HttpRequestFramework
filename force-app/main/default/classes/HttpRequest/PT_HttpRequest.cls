public class PT_HttpRequest implements PT_IHttpRequest, PT_IMockable {

    @TestVisible
    private PT_IHttpRequestConfig config;
    private PT_IHttpRequestBody body;

    @TestVisible
    private PT_HttpRequest() {}

    public PT_HttpRequest(String metadataName) {
        config = new PT_HttpRequestConfig(metadataName);
    }

    public PT_IHttpRequest setBody(PT_IHttpRequestBody body) {
        this.body = body;
        return this;
    }

    public HttpRequest toRequest() {
        HttpRequest req = new HttpRequest();
        req.setMethod(config.getMethod());
        req.setTimeout(config.getTimeout());
        String endpoint = config.getEndpoint();

        if (body != null) {
            if (PT_HttpMethods.areTheSame(config.getMethod(), PT_HttpMethod.HTTP_GET)) {
                endpoint += body.toQueryParams();
            } else {
                req.setBody(body.toJsonBody());
            }
        }

        req.setEndpoint(endpoint);
        return req;
    }

    public Boolean shouldBeMocked() {
        return config.hasActiveMock();
    }

    public PT_IHttpResponseMock getMock() {
        return config.getActiveMock();
    }
}

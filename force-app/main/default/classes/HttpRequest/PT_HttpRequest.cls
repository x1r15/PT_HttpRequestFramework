public class PT_HttpRequest implements PT_IHttpRequest, PT_IMockable {

    @TestVisible
    private PT_IHttpRequestConfig config;
    private PT_IHttpRequestBody body;
    private List<Object> params;

    @TestVisible
    private PT_HttpRequest() {}

    public PT_HttpRequest(String metadataIdentifier) {
        config = new PT_HttpRequestConfig(metadataIdentifier);
    }

    public PT_IHttpRequest setBody(PT_IHttpRequestBody body) {
        this.body = body;
        return this;
    }

    public PT_IHttpRequest setParams(List<String> values) {
        params = values;
        return this;
    }

    public HttpRequest toRequest() {
        HttpRequest req = new HttpRequest();
        req.setMethod(config.getMethod());
        req.setTimeout(config.getTimeout());
        String endpoint = config.getEndpoint();
        if (params != null && !params.isEmpty()) {
            endpoint = String.format(endpoint, params);
        }

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

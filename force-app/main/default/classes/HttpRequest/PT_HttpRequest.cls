public class PT_HttpRequest implements PT_IHttpRequest{

    @TestVisible
    private PT_IHttpRequestConfig config;
    private PT_IRequestBody body;
    @TestVisible
    private PT_HttpRequest() {}
    public PT_HttpRequest(String metadataName) {
        config = new PT_HttpRequestConfig(metadataName);
    }

    public PT_IHttpRequest setBody(PT_IRequestBody body) {
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
}

public interface PT_IHttpRequestConfig {
    Integer getTimeout();
    String getEndpoint();
    String getMethod();
    Boolean hasActiveMock();
    PT_IHttpResponseMock getActiveMock();
}
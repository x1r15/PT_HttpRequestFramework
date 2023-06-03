public interface PT_IHttpRequest {
    PT_IHttpRequest setBody(PT_IHttpRequestBody body);
    PT_IHttpRequest setParams(List<String> values);
    HttpRequest toRequest();
}

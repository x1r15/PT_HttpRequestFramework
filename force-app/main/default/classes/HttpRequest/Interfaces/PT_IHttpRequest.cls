public interface PT_IHttpRequest {
    PT_IHttpRequest setBody(PT_IHttpRequestBody body);
    HttpRequest toRequest();
}
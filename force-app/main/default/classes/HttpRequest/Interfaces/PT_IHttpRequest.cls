public interface PT_IHttpRequest {
    PT_IHttpRequest setBody(PT_IRequestBody body);
    HttpRequest toRequest();
}

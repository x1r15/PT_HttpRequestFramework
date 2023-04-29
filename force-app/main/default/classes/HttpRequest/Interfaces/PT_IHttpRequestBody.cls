/**
 * For most of the use cases extending PT_HttpRequestBodyBase will be easier than implementing this interface.
 */
public interface PT_IHttpRequestBody {
    String toQueryParams();
    String toJsonBody();
}
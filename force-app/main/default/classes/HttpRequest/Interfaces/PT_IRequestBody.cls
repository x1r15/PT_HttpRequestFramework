/**
 * For most of the use cases extending PT_RequestBodyBase will be easier than implementing this interface.
 */
public interface PT_IRequestBody {
    String toQueryParams();
    String toJsonBody();
}

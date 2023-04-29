/**
 * Extend this class to create new types conveniently convertable to query params & json body.
 * Custom conversion can be provided by implementing PT_IHttpRequestBody instead of extending this class.
 */
public abstract class PT_HttpRequestBodyBase implements PT_IHttpRequestBody {
    public String toQueryParams() {
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(this));
        List<String> paramsTokens = new List<String>();
        for (String key : params.keySet()) {
            paramsTokens.add(key + '=' + params.get(key));
        }
        return '?' + String.join(paramsTokens, '&');
    }

    public String toJsonBody() {
        return JSON.serialize(this);
    }
}
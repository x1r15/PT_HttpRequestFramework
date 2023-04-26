/*
 * Using native Stub API to avoid dependencies on third party tools
 */
@IsTest
public class PT_HttpRequestConfigMock implements System.StubProvider, PT_IHttpRequestConfig {
    private final static String Method_GetTimeout = 'getTimeout';
    private final static String Method_GetEndpoint = 'getEndpoint';
    private final static String Method_GetMethod = 'getMethod';

    private final Integer timeoutMock;
    private final String endpointMock;
    private final String methodMock;

    public PT_HttpRequestConfigMock(Integer timeout, String endpoint, String method) {
        this.timeoutMock = timeout;
        this.endpointMock = endpoint;
        this.methodMock = method;
    }
    public Object handleMethodCall(Object stubbedObject, String stubbedMethodName,
            Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames,
            List<Object> listOfArgs) {
        if (stubbedMethodName == Method_GetTimeout) {
            return getTimeout();
        } else if (stubbedMethodName == Method_GetEndpoint) {
            return getEndpoint();
        } else if (stubbedMethodName == Method_GetMethod) {
            return getMethod();
        }
        return null;
    }

    public Integer getTimeout() {
        return timeoutMock;
    }

    public String getEndpoint() {
        return endpointMock;
    }

    public String getMethod() {
        return methodMock;
    }
}

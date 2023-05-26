@IsTest
private class PT_HttpRequestTest {
    private static final String HttpMethod_Get = 'GET';
    private static final String HttpMethod_Post = 'POST';
    private static final String EndpointMock = 'ENDPOINT_MOCK';
    private static final String ParametrizedEndpointMock = '/{0}/{1}/{2}';
    private static final Integer TimeoutMock = 1;
    private static final String MetadataNameMock = 'Lorem Ipsum';
    private static final String BodyMock_Query = '?a=b';
    private static final String BodyMock_Json = '{"a":"b"}';

    @IsTest
    static void toRequestNoBody_Test() {
        //Arrange
        PT_IHttpRequestConfig requestConfigMock =
                (PT_IHttpRequestConfig)Test.createStub(
                        PT_IHttpRequestConfig.class,
                        new PT_HttpRequestConfigMock(
                                TimeoutMock,
                                EndpointMock,
                                HttpMethod_Get));

        PT_HttpRequest ptReq = new PT_HttpRequest();
        ptReq.config = requestConfigMock;

        //Act
        Test.startTest();
        HttpRequest req = ptReq.toRequest();
        Test.stopTest();

        //Assert
        System.assertEquals(requestConfigMock.getEndpoint(), req.getEndpoint());
        System.assertEquals(requestConfigMock.getMethod(), req.getMethod());
    }

    @IsTest
    static void constructionNoMdtFound_Test() {
        //Arrange
        PT_HttpRequestConfigException expectedException;

        //Act
        Test.startTest();
        try {
            new PT_HttpRequest(MetadataNameMock);
        } catch (PT_HttpRequestConfigException ex) {
            expectedException = ex;
        }
        Test.stopTest();

        //Assert
        System.assertNotEquals(null, expectedException);
        System.assert(expectedException.getMessage().contains(MetadataNameMock));
    }

    @IsTest
    static void queryParamBodyForGetMethod_Test() {
        //Arrange
        PT_IHttpRequestConfig requestConfigMock =
                (PT_IHttpRequestConfig)Test.createStub(
                        PT_IHttpRequestConfig.class,
                        new PT_HttpRequestConfigMock(
                                TimeoutMock,
                                EndpointMock,
                                HttpMethod_Get));

        PT_HttpRequest ptReq = new PT_HttpRequest();
        ptReq.config = requestConfigMock;

        //Act
        Test.startTest();
        ptReq.setBody(new PT_TestRequestBody()); // Check inner class below
        HttpRequest req = ptReq.toRequest();
        Test.stopTest();

        //Assert
        System.assert(req.getEndpoint().contains(BodyMock_Query));
        System.assert(req.getEndpoint().contains(EndpointMock));
        System.assert(String.isEmpty(req.getBody()));
    }

    @IsTest
    static void jsonParamBodyForPostMethod_Test() {
        //Arrange
        PT_IHttpRequestConfig requestConfigMock =
                (PT_IHttpRequestConfig)Test.createStub(
                        PT_IHttpRequestConfig.class,
                        new PT_HttpRequestConfigMock(
                                TimeoutMock,
                                EndpointMock,
                                HttpMethod_Post));

        PT_HttpRequest ptReq = new PT_HttpRequest();
        ptReq.config = requestConfigMock;

        //Act
        Test.startTest();
        ptReq.setBody(new PT_TestRequestBody()); // Check inner class below
        HttpRequest req = ptReq.toRequest();
        Test.stopTest();

        //Assert
        System.assertEquals(BodyMock_Json, req.getBody());
        System.assertEquals(EndpointMock, req.getEndpoint());
        System.assert(!req.getEndpoint().contains(BodyMock_Query));
        System.assert(!req.getEndpoint().contains(BodyMock_Json));
    }

    @IsTest
    static void parametrizeEndpoint_Test() {
        //Arrange
        PT_IHttpRequestConfig requestConfigMock =
                (PT_IHttpRequestConfig)Test.createStub(
                        PT_IHttpRequestConfig.class,
                        new PT_HttpRequestConfigMock(
                                TimeoutMock,
                                ParametrizedEndpointMock,
                                HttpMethod_Get));

        PT_HttpRequest ptReq = new PT_HttpRequest();
        ptReq.config = requestConfigMock;

        List<String> mockedParams = new List<String> {'a', 'b', 'c'};

        //Act
        Test.startTest();
        ptReq.setParams(mockedParams);
        HttpRequest req = ptReq.toRequest();
        Test.stopTest();

        //Assert
        System.assertEquals(req.getEndpoint(), '/a/b/c');
    }

    private class PT_TestRequestBody implements PT_IHttpRequestBody {
        public String toQueryParams() {
            return BodyMock_Query;
        }

        public String toJsonBody() {
            return BodyMock_Json;
        }
    }
}

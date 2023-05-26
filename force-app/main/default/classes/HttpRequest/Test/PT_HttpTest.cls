@IsTest
private class PT_HttpTest {
    private final static String BodyMock = 'TEST';
    private final static Integer SuccessCode = 200;
    private static final String HttpMethod_Get = 'GET';
    private static final String EndpointMock = 'ENDPOINT_MOCK';
    private static final Integer TimeoutMock = 1;

    @IsTest
    static void respondWithProvidedMock_Test() {

        //Arrange
        PT_IHttpRequestConfig requestConfigMock =
                (PT_IHttpRequestConfig)Test.createStub(
                        PT_IHttpRequestConfig.class,
                        new PT_HttpRequestConfigMock(
                                TimeoutMock,
                                EndpointMock,
                                HttpMethod_Get,
                                new PT_HttpCalloutMock()));

        PT_HttpRequest ptReq = new PT_HttpRequest();
        ptReq.config = requestConfigMock;

        //Act
        HttpResponse response = new PT_Http().send(ptReq);

        //Assert
        System.assertEquals(BodyMock, response.getBody());
        System.assertEquals(SuccessCode, response.getStatusCode());
    }

    @IsTest
    static void sendActualRequest_Test() {
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
        ptReq.setBody(new PT_TestRequestBody());

        Test.setMock(HttpCalloutMock.class, new PT_HttpCalloutMock());

        //Act
        HttpResponse response = new PT_Http().send(ptReq);

        //Assert
        System.assertEquals(BodyMock, response.getBody());
        System.assertEquals(SuccessCode, response.getStatusCode());
    }

    @IsTest
    static void noMockUsedWhenRequestIsNotMockable_Test() {
        PT_IHttpRequest req = new PT_NonMockableRequest();
        Test.setMock(HttpCalloutMock.class, new PT_HttpCalloutMock());

        //Act
        HttpResponse response = new PT_Http().send(req);

        //Assert
        System.assertEquals(BodyMock, response.getBody());
        System.assertEquals(SuccessCode, response.getStatusCode());
    }

    private class PT_NonMockableRequest implements PT_IHttpRequest {
        public PT_IHttpRequest setBody(PT_IHttpRequestBody body) {
            return this;
        }
        public PT_IHttpRequest setParams(List<String> values) {
            return this;
        }
        public HttpRequest toRequest() {
            return new HttpRequest();
        }
    }

    private class PT_TestRequestBody extends PT_HttpRequestBodyBase {}

    private class PT_HttpCalloutMock implements HttpCalloutMock, PT_IHttpResponseMock {
        private HttpResponse getMockedResponse() {
            HttpResponse res = new HttpResponse();
            res.setBody(BodyMock);
            res.setStatusCode(SuccessCode);
            return res;
        }

        public HttpResponse respond(HttpRequest req) {
            return getMockedResponse();
        }
    }
}

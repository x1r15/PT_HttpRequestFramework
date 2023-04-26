@IsTest
public class PT_HttpRequestTest {
    private static final String HttpMethod_Get = 'GET';
    private static final String HttpMethod_Post = 'POST';
    private static final String EndpointMock = 'ENDPOINT_MOCK';
    private static final Integer TimeoutMock = 1;
    private static final String MetadataNameMock = 'Lorem Ipsum';
    private static final String BodyMock_Query = 'QUERY';
    private static final String BodyMock_Json = 'JSON';

    @IsTest
    static void toRequestNoBody_Test() {
        //Arrange
        PT_HttpRequest__mdt configMdt = getMetadataRecord();
        PT_IHttpRequest ptReq = new PT_HttpRequest(configMdt.DeveloperName);

        //Act
        Test.startTest();
        HttpRequest req = ptReq.toRequest();
        Test.stopTest();

        //Assert
        System.assertEquals(configMdt.PT_Endpoint__c, req.getEndpoint());
        System.assertEquals(configMdt.PT_HttpMethod__c, req.getMethod());
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

    /*
     * Created to facilitate cross org test success, though still at least
     * one record has to be created. Mocking metadata retrieval is not relevant
     * for performing HttpRequests thus it was not implemented.
     */
    private static PT_HttpRequest__mdt getMetadataRecord() {
        return [
                SELECT Id, DeveloperName, PT_HttpMethod__c, PT_Endpoint__c, PT_Timeout__c
                FROM PT_HttpRequest__mdt
                LIMIT 1
        ];
    }

    private class PT_TestRequestBody implements PT_IRequestBody {
        public String toQueryParams() {
            return BodyMock_Query;
        }

        public String toJsonBody() {
            return BodyMock_Json;
        }
    }
}

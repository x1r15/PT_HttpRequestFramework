@IsTest
public class PT_HttpRequestConfigTest {
    private final static String MockedMethod = 'GET';
    private final static String MockedEndpoint = 'https://test.com';
    private final static Decimal MockedTimeout = 10000;

    @IsTest
    static void configNotFoundExceptionThrown_Test() {
        //Arrange
        String fakeName = 'fake_name_to_trigger_exception';
        PT_HttpRequestConfigException expectedException;
        //Act
        try {
            new PT_HttpRequestConfig(fakeName);
        } catch (PT_HttpRequestConfigException ex) {
            expectedException = ex;
        }

        //Assert
        System.assertNotEquals(null, expectedException);
        System.assert(expectedException.getMessage().contains(fakeName));
    }

    @IsTest
    static void getDataBasedOnMetadata_Test() {
        //Arrange
        PT_HttpRequest__mdt configRecord = getMetadataRecord();
        PT_HttpRequestConfig config = new PT_HttpRequestConfig(); //unavailable in business code
        config.record = configRecord; //unavailable in business code

        //Act
        String method = config.getMethod();
        String endpoint = config.getEndpoint();
        Integer timeout = config.getTimeout();

        //Assert
        System.assertEquals(configRecord.PT_HttpMethod__c, method);
        System.assertEquals(configRecord.PT_Endpoint__c, endpoint);
        System.assertEquals(configRecord.PT_Timeout__c, timeout);
    }

    /*
     * Created to facilitate cross-org test execution without dependency on actual configuration
     */
    private static PT_HttpRequest__mdt getMetadataRecord() {

        Map<String, Object> untypedMetadataRecord = new Map<String, Object> {
                PT_HttpRequest__mdt.PT_HttpMethod__c.getDescribe().name => MockedMethod,
                PT_HttpRequest__mdt.PT_Endpoint__c.getDescribe().name => MockedEndpoint,
                PT_HttpRequest__mdt.PT_Timeout__c.getDescribe().name => MockedTimeout
        };
        return (PT_HttpRequest__mdt)JSON.deserialize(JSON.serialize(untypedMetadataRecord), PT_HttpRequest__mdt.class);
    }
}

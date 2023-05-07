/*
    Not tested: getActiveMock positive scenario to avoid dependency on actual MDT records
 */

@IsTest
private class PT_HttpRequestConfigTest {
    private final static String IsSandboxFieldName = 'IsSandbox';
    private final static String MockedDeveloperName = 'ABC';
    private final static String MockedMethod = 'GET';
    private final static String MockedEndpoint = '/some/endpoint';
    private final static String MockedNamedCredentials = 'NamedCredential';
    private final static Decimal MockedTimeout = 10000;
    private final static String NamedCredentialsPrefix = 'callout:';

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
        Boolean isSandbox = false;
        PT_HttpRequest__mdt configRecord = getMetadataRecord(isSandbox);
        PT_HttpRequestConfig config = new PT_HttpRequestConfig(); //unavailable in business code
        config.record = configRecord; //unavailable in business code

        //Act
        String method = config.getMethod();
        String endpoint = config.getEndpoint();
        Integer timeout = config.getTimeout();

        //Assert
        String expectedEndpoint =
                NamedCredentialsPrefix +
                        configRecord.PT_NamedCredentials__c +
                        configRecord.PT_Endpoint__c;

        System.assertEquals(configRecord.PT_HttpMethod__c, method);
        System.assertEquals(expectedEndpoint, endpoint);
        System.assertEquals(configRecord.PT_Timeout__c, timeout);
    }

    @IsTest
    static void exceptionWhenMockRequestedButThereIsNoMock_Test() {
        //Arrange
        Boolean isSandbox = false;
        PT_HttpRequestConfigException expectedException;
        PT_HttpRequest__mdt configRecord = getMetadataRecord(isSandbox);
        PT_HttpRequestConfig config = new PT_HttpRequestConfig(); //unavailable in business code
        config.record = configRecord; //unavailable in business code

        //Act
        try {
            config.getActiveMock();
        } catch (PT_HttpRequestConfigException ex) {
            expectedException = ex;
        }

        //Assert
        System.assertNotEquals(null, expectedException);
        System.assert(expectedException.getMessage().contains(MockedDeveloperName));
    }

    @IsTest
    static void statingThereIsNoMockInUnitTestsWhenMockRecordIsPresent_Test() {
        //Arrange
        Boolean isSandbox = false;
        PT_HttpRequest__mdt configRecord = getMetadataRecord(isSandbox);
        Id val = PT_HttpResponseMock__mdt.SObjectType.getDescribe().getKeyPrefix() + '5500a2r15wqs';
        configRecord.put(PT_HttpRequest__mdt.PT_HttpMethod__c, val);
        PT_HttpRequestConfig config = new PT_HttpRequestConfig(); //unavailable in business code
        config.record = configRecord; //unavailable in business code

        //Act
        Boolean hasActiveMock = config.hasActiveMock();

        //Assert
        System.assert(!hasActiveMock);
    }

    @IsTest
    static void fetchMetadataForTheRightEnvironmentType_Test() {
        Boolean isSandbox = true;
        setEnvironmentType(isSandbox);
        PT_HttpRequest__mdt configRecord = getMetadataRecord(isSandbox);
        PT_HttpRequestConfig.ConfigsCache = new List<PT_HttpRequest__mdt> {configRecord};

        PT_HttpRequestConfigException expectedException; //should not throw exception

        //Act
        try {
            new PT_HttpRequestConfig(MockedDeveloperName);
        } catch (PT_HttpRequestConfigException ex) {
            expectedException = ex;
        }

        //Assert
        System.assertEquals(null, expectedException);
    }

    @IsTest
    static void exceptionWhenNoRecordForGivenEnvironmentExists_Test() {
        Boolean isSandbox = true;
        setEnvironmentType(isSandbox);
        PT_HttpRequest__mdt configRecord = getMetadataRecord(!isSandbox);
        PT_HttpRequestConfig.ConfigsCache = new List<PT_HttpRequest__mdt> {configRecord};

        PT_HttpRequestConfigException expectedException;

        //Act
        try {
            new PT_HttpRequestConfig(MockedDeveloperName);
        } catch (PT_HttpRequestConfigException ex) {
            expectedException = ex;
        }

        //Assert
        System.assertNotEquals(null, expectedException);
        System.assert(expectedException.getMessage().contains(MockedDeveloperName));
    }

    /*
     * Created to facilitate cross-org test execution without dependency on actual configuration
     */
    private static PT_HttpRequest__mdt getMetadataRecord(Boolean useInProduction) {

        Map<String, Object> untypedMetadataRecord = new Map<String, Object> {
                PT_HttpRequest__mdt.DeveloperName.getDescribe().name => MockedDeveloperName,
                PT_HttpRequest__mdt.PT_Identifier__c.getDescribe().name => MockedDeveloperName,
                PT_HttpRequest__mdt.PT_HttpMethod__c.getDescribe().name => MockedMethod,
                PT_HttpRequest__mdt.PT_Endpoint__c.getDescribe().name => MockedEndpoint,
                PT_HttpRequest__mdt.PT_Timeout__c.getDescribe().name => MockedTimeout,
                PT_HttpRequest__mdt.PT_NamedCredentials__c.getDescribe().name => MockedNamedCredentials,
                PT_HttpRequest__mdt.PT_UseInProduction__c.getDescribe().name => !useInProduction
        };
        return (PT_HttpRequest__mdt)JSON.deserialize(JSON.serialize(untypedMetadataRecord), PT_HttpRequest__mdt.class);
    }

    private static void setEnvironmentType(Boolean isSandbox) {
        Map<String, Object> untypedOrganizationRecord = new Map<String, Object> {
                IsSandboxFieldName => isSandbox
        };
        PT_EnvironmentInformation.OrganizationData =
                (Organization)JSON.deserialize(JSON.serialize(untypedOrganizationRecord), Organization.class);
    }
}

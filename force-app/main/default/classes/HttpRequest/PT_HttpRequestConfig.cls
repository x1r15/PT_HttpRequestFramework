public class PT_HttpRequestConfig implements PT_IHttpRequestConfig {

    private final static Integer DefaultTimeout = 10000;
    private final static String NamedCredentialsPrefix = 'callout:';

    @TestVisible
    private static List<PT_HttpRequest__mdt> ConfigsCache = PT_HttpRequest__mdt.getAll().values();
    @TestVisible
    private PT_HttpRequest__mdt record;
    @TestVisible
    private PT_HttpRequestConfig() {}

    public PT_HttpRequestConfig(String metadataIdentifier) {
        if (record == null) {
            record = getMetadataRecord(metadataIdentifier);
        }
    }

    public PT_IHttpResponseMock getActiveMock() {
        if (!hasActiveMock()) {
            throw new PT_HttpRequestConfigException(
                    PT_HttpRequestConfigException.ExceptionType.NoMockFound,
                    record.DeveloperName);
        }

        PT_HttpResponseMock__mdt requestMock =
                PT_HttpResponseMock__mdt.getInstance(record.PT_ActiveMock__c);

        return new PT_RuntimeHttpResponseMock(
                Integer.valueOf(requestMock.PT_StatusCode__c),
                requestMock.PT_Body__c);
    }

    public Boolean hasActiveMock() {
        return record.PT_ActiveMock__c != null && inValidContext();
    }

    public Integer getTimeout() {
        return record.PT_Timeout__c == null ? DefaultTimeout : Integer.valueOf(record.PT_Timeout__c);
    }

    public String getEndpoint() {
        return NamedCredentialsPrefix + record.PT_NamedCredentials__c +  record.PT_Endpoint__c;
    }

    public String getMethod() {
        return record.PT_HttpMethod__c;
    }

    private static Boolean inValidContext() {
        //In tests always respond with native HttpCalloutMock
        return !Test.isRunningTest();
    }

    private static PT_HttpRequest__mdt getMetadataRecord(String identifier) {
        Boolean isSandbox = PT_EnvironmentInformation.getInstance().isSandbox();
        for (PT_HttpRequest__mdt requestConfig : ConfigsCache) {
            if (requestConfig.PT_Identifier__c == identifier && requestConfig.PT_UseInProduction__c != isSandbox) {
                return requestConfig;
            }
        }
        throw new PT_HttpRequestConfigException(
                PT_HttpRequestConfigException.ExceptionType.NoMdtFound,
                identifier);
    }
}


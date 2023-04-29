public class PT_HttpRequestConfig implements PT_IHttpRequestConfig {
    @TestVisible
    private PT_HttpRequest__mdt record;

    @TestVisible
    private PT_HttpRequestConfig() {}

    public PT_HttpRequestConfig(String metadataName) {
        record = PT_HttpRequest__mdt.getInstance(metadataName);
        if (record == null) {
            throw new PT_HttpRequestConfigException(
                    PT_HttpRequestConfigException.ExceptionType.NoMdtFound,
                    metadataName);
        }
    }

    public PT_IHttpResponseMock getActiveMock() {
        if (!hasActiveMock()) {
            throw new PT_HttpRequestConfigException(
                    PT_HttpRequestConfigException.ExceptionType.NoMockFound,
                    record.DeveloperName);
        }

        return new PT_RuntimeHttpResponseMock(record.PT_ActiveMock__r);
    }

    public Boolean hasActiveMock() {
        return record.PT_ActiveMock__c != null && inValidContext();
    }

    public Integer getTimeout() {
        return Integer.valueOf(record.PT_Timeout__c);
    }

    public String getEndpoint() {
        return record.PT_Endpoint__c;
    }

    public String getMethod() {
        return record.PT_HttpMethod__c;
    }

    private static Boolean inValidContext() {
        //In tests always respond with native HttpCalloutMock
        return !Test.isRunningTest();
    }
}
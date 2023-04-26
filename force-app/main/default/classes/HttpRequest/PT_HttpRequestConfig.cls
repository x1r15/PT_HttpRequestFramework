public class PT_HttpRequestConfig implements PT_IHttpRequestConfig {
    @TestVisible
    private PT_HttpRequest__mdt record;

    @TestVisible
    private PT_HttpRequestConfig() {}

    public PT_HttpRequestConfig(String metadataName) {
        record = PT_HttpRequest__mdt.getInstance(metadataName);
        if (record == null) {
            throw new PT_HttpRequestConfigException(PT_HttpRequestConfigException.ExceptionType.NoMdtFound, metadataName);
        }
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
}

public class PT_RuntimeHttpResponseMock implements PT_IHttpResponseMock {

    private final PT_HttpResponseMock__mdt record;

    public PT_RuntimeHttpResponseMock(PT_HttpResponseMock__mdt record) {
        this.record = PT_HttpResponseMock__mdt.getInstance(record.DeveloperName);
    }

    public HttpResponse respond(HttpRequest request) {
        HttpResponse httpResponseMock = new HttpResponse();
        if (record.PT_Body__c != null) {
            httpResponseMock.setBody(record.PT_Body__c);
        }
        httpResponseMock.setStatusCode(Integer.valueOf(record.PT_StatusCode__c));
        return httpResponseMock;
    }
}
@IsTest
public class PT_HttpRequestBodyBaseTest {
    private static final String StringValue = 'abcdef';
    private static final Integer IntegerValue = 12345;
    @IsTest
    static void toQueryParams_Test() {
        //Arrange
        PT_TestRequestBody body = new PT_TestRequestBody();
        body.stringValue = StringValue;
        body.integerValue = IntegerValue;

        Pattern queryPattern = Pattern.compile('^\\?([\\w-]+(=[\\w-]*)?(&[\\w-]+(=[\\w-]*)?)*)?$');

        //Act
        String bodyAsQueryParams = body.toQueryParams();

        //Assert
        Matcher matcher = queryPattern.matcher(bodyAsQueryParams);
        System.assert(matcher.matches());
        System.assert(bodyAsQueryParams.contains('stringValue=' + StringValue));
        System.assert(bodyAsQueryParams.contains('integerValue=' + IntegerValue));
    }

    @IsTest
    static void toJsonBody_Test() {
        //Arrange
        PT_TestRequestBody body = new PT_TestRequestBody();
        body.stringValue = StringValue;
        body.integerValue = IntegerValue;

        //Act
        String bodyAsQueryParams = body.toJsonBody();

        //Assert
        Map<String, Object> deserializedBody = (Map<String, Object>)JSON.deserializeUntyped(bodyAsQueryParams);
        System.assertEquals(StringValue, deserializedBody.get('stringValue'));
        System.assertEquals(IntegerValue, deserializedBody.get('integerValue'));
    }
    private class PT_TestRequestBody extends PT_HttpRequestBodyBase {
        public String stringValue;
        public Integer integerValue;
    }
}
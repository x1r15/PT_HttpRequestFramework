@IsTest
public class ExampleServiceTest {
    @IsTest
    static void executeSuccess_Test() {
        //Arrange
        String mockedResponseMessage = '{"message":"Sample response message"}';
        HttpResponse responseMock = new HttpResponse();
        responseMock.setBody(mockedResponseMessage);
        responseMock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, new SuccessResponseMock(responseMock));

        //Act
        Test.startTest();
        String result = new ExampleService().execute();
        Test.stopTest();

        //Assert
        System.assertEquals(result, mockedResponseMessage);
    }

    private class SuccessResponseMock implements HttpCalloutMock {
        private final HttpResponse response;

        public SuccessResponseMock(HttpResponse response) {
            this.response = response;
        }

        public HttpResponse respond(HttpRequest request) {
            return response;
        }
    }
}
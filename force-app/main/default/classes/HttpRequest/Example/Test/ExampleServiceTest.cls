@IsTest
public class ExampleServiceTest {
    @IsTest
    static void executeSuccess_Test() {
        //Arrange
        String mockedResponseMessage = '{"message":"Sample response message"}';
        HttpResponse responseMock = new HttpResponse();
        responseMock.setBody(mockedResponseMessage);
        responseMock.setStatusCode(200);
        PT_Http.responseMock = responseMock;

        //Act
        Test.startTest();
        String result = new ExampleService().execute();
        Test.stopTest();

        //Assert
        System.assertEquals(result, mockedResponseMessage);
    }
}
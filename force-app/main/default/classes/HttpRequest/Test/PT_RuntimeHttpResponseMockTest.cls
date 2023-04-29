@IsTest
private class PT_RuntimeHttpResponseMockTest {
    @IsTest
    static void respondWithMetadataValues_Test() {
        //Arrange
        Integer statusCodeMock = 418;
        String bodyMock = '{"a":"b"}';
        PT_RuntimeHttpResponseMock mock = new PT_RuntimeHttpResponseMock(statusCodeMock, bodyMock);

        //Act
        HttpResponse response = mock.respond(null); //request not relevant

        //Assert
        System.assertEquals(statusCodeMock, response.getStatusCode());
        System.assertEquals(bodyMock, response.getBody());
    }
}

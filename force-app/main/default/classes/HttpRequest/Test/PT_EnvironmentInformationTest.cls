@IsTest
private class PT_EnvironmentInformationTest {
    private final static String IsSandboxFieldName = 'IsSandbox';

    @IsTest
    static void isSandboxRealData_Test() {
        //Arrange
        Boolean isSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        PT_IEnvironmentInformation envInformation = PT_EnvironmentInformation.getInstance();

        //Act
        Boolean receivedIsSandbox = envInformation.isSandbox();

        //Assert
        System.assertEquals(isSandbox, receivedIsSandbox);
    }

    @IsTest
    static void isSandboxTestData_Test() {
        //Arrange
        Boolean fakeIsSandbox = true;
        setEnvironmentType(fakeIsSandbox);
        PT_IEnvironmentInformation envInformation = PT_EnvironmentInformation.getInstance();

        //Act
        Boolean receivedIsSandbox = envInformation.isSandbox();

        //Assert
        System.assertEquals(fakeIsSandbox, receivedIsSandbox);
    }

    private static void setEnvironmentType(Boolean isSandbox) {
        Map<String, Object> untypedOrganizationRecord = new Map<String, Object> {
                IsSandboxFieldName => isSandbox
        };
        PT_EnvironmentInformation.OrganizationData =
                (Organization)JSON.deserialize(JSON.serialize(untypedOrganizationRecord), Organization.class);
    }
}

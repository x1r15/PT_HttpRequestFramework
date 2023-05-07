public class PT_EnvironmentInformation implements PT_IEnvironmentInformation {

    @TestVisible
    private static PT_EnvironmentInformation instance;

    @TestVisible
    private static Organization OrganizationData = [SELECT IsSandbox FROM Organization];

    public static PT_IEnvironmentInformation getInstance() {
        if (instance == null) {
            instance = new PT_EnvironmentInformation();
        }
        return instance;
    }

    private PT_EnvironmentInformation() {}

    public Boolean isSandbox() {
        return OrganizationData.IsSandbox;
    }
}

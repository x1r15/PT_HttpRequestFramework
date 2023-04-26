public class PT_HttpMethods {
    private final static String HTTP_TOKEN = 'HTTP_';
    public static Boolean areTheSame(String sHttpMethod, PT_HttpMethod eHttpMethod) {
        return sHttpMethod == eHttpMethod.name().remove(HTTP_TOKEN);
    }
}

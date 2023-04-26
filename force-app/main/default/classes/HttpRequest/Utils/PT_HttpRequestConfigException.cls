public class PT_HttpRequestConfigException extends Exception {
    private static final Map<ExceptionType, String> MessageByExceptionType =
            new Map<ExceptionType, String> {
                    ExceptionType.NoMdtFound => 'No metadata of type PT_HttpRequest__mdt was found for a developer name {0}'
            };
    public enum ExceptionType {
        NoMdtFound
    }

    public PT_HttpRequestConfigException(ExceptionType exType, String detail) {
        setMessage(String.format(MessageByExceptionType.get(exType), new List<Object> {detail}));
    }
}

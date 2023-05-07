public class PT_HttpRequestConfigException extends Exception {
    private static final Map<ExceptionType, String> MessageByExceptionType =
            new Map<ExceptionType, String> {
                    ExceptionType.NoMdtFound => 'No PT_HttpRequest__mdt record was found for an identifier {0}',
                    ExceptionType.NoMockFound => 'No PT_HttpResponseMock__mdt record, related to {0} PT_HttpRequest__mdt was found'
            };

    public enum ExceptionType {
        NoMdtFound,
        NoMockFound
    }

    public PT_HttpRequestConfigException(ExceptionType exType, String detail) {
        setMessage(String.format(MessageByExceptionType.get(exType), new List<Object> {detail}));
    }
}

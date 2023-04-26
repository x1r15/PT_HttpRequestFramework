public class ExampleService {
    private final static String ApiKey = 'demo';
    private final static String Interval = '5min';
    private final static String Symbol = 'imb';
    private final static String Function = 'TIME_SERIES_INTRADAY';

    // Method containing actual business logic
    public String execute() {

        ExampleRequestBody b = new ExampleRequestBody();
        b.apikey = ApiKey; // Kept here for brevity
        b.interval = Interval;
        b.symbol = Symbol;
        b.function = Function;

        PT_IHttpRequest req =
                new PT_HttpRequest(ExampleRequestTypes.AlphaVantageRequest.name())
                        .setBody(b);

        String responseBody = new PT_Http().send(req).getBody();

        System.debug(responseBody);
        return responseBody;
    }
}
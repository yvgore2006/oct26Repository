public with sharing class PaymentIntegrationService {

    public class PaymentRequest {
        public String amount;
        public String currency1;
        public String customerName;
    }

    public class PaymentResponse {
        public String paymentId;
        public String status;
    }
    
    public static PaymentResponse createPayment(Opportunity opp) {

    Http http = new Http();
    HttpRequest req = new HttpRequest();

    String endpoint = 'callout:PaymentAPI/payments';
        //req.setEndpoint('callout:PaymentAPI/payments');

    req.setEndpoint(endpoint);
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');

    PaymentRequest requestBody = new PaymentRequest();
    requestBody.amount = String.valueOf(opp.Amount);
    requestBody.currency1 = 'INR';
    requestBody.customerName = opp.Name;

    String requestJSON = JSON.serialize(requestBody);
    req.setBody(requestJSON);

    try {
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {

            // ✅ SUCCESS LOG
            IntegrationLogger.log(
                requestJSON,
                res.getBody(),
                'Success',
                null,
                endpoint,
                opp.Id
            );

            return (PaymentResponse) JSON.deserialize(res.getBody(), PaymentResponse.class);

        } else {

            // ❌ FAILURE LOG
            IntegrationLogger.log(
                requestJSON,
                res.getBody(),
                'Failed',
                'Non-200 status code',
                endpoint,
                opp.Id
            );

            throw new CalloutException('API Error');
        }

    } catch (Exception e) {

        // ❌ EXCEPTION LOG
        IntegrationLogger.log(
            requestJSON,
            null,
            'Failed',
            e.getMessage(),
            endpoint,
            opp.Id
        );

        throw e;
    }
}

    
    
    /*
    public static PaymentResponse createPayment(Opportunity opp) {

        Http http = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint('callout:PaymentAPI/payments');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        PaymentRequest requestBody = new PaymentRequest();
        requestBody.amount = String.valueOf(opp.Amount);
        requestBody.currency1 = 'INR';
        requestBody.customerName = opp.Name;

        req.setBody(JSON.serialize(requestBody));

        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            return (PaymentResponse) JSON.deserialize(res.getBody(), PaymentResponse.class);
        } else {
            throw new CalloutException('Payment API failed: ' + res.getBody());
        }
    }*/
}
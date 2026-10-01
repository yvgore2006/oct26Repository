public class IntegrationLogger {

    public static void log(String request, String response, String status,
                           String errorMsg, String endpoint, String recordId) {

        Integration_Log__c log = new Integration_Log__c();

        log.Request_Body__c = request;
        log.Response_Body__c = response;
        log.Status__c = status;
        log.Error_Message__c = errorMsg;
        log.Endpoint__c = endpoint;
        log.Record_Id__c = recordId;

        insert log;
    }
}
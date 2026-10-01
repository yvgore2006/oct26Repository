public class PaymentQueueable implements Queueable, Database.AllowsCallouts {

    private List<Id> oppIds;

    public PaymentQueueable(List<Id> oppIds) {
        this.oppIds = oppIds;
    }

    public void execute(QueueableContext context) {

        List<Opportunity> opps = [
            SELECT Id, Name, Amount FROM Opportunity WHERE Id IN :oppIds
        ];

        List<Opportunity> updateList = new List<Opportunity>();

        for (Opportunity opp : opps) {
            try {
                PaymentIntegrationService.PaymentResponse res =
                    PaymentIntegrationService.createPayment(opp);

                opp.Payment_Id__c = res.paymentId;
                opp.Payment_Status__c = res.status;

                updateList.add(opp);

            } catch (Exception e) {
                opp.Payment_Status__c = 'Failed';
                updateList.add(opp);
            }
        }

        if (!updateList.isEmpty()) {
            update updateList;
        }
    }
}
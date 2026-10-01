trigger OpportunityTrigger on Opportunity (after update) {

    List<Id> oppIds = new List<Id>();

    for (Opportunity opp : Trigger.new) {
        Opportunity oldOpp = Trigger.oldMap.get(opp.Id);

        if (opp.StageName == 'Closed Won' &&
            oldOpp.StageName != 'Closed Won') {

            oppIds.add(opp.Id);
        }
    }

    if (!oppIds.isEmpty()) {
        System.enqueueJob(new PaymentQueueable(oppIds));
    }
}
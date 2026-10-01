trigger OLITrigger on OpportunityLineItem (
    after insert, after update, after delete, after undelete
) {

    Set<Id> oppIdSet = new Set<Id>();

    // Collect Opportunity Ids
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (OpportunityLineItem oli : Trigger.new) {
            if (oli.OpportunityId != null) {
                oppIdSet.add(oli.OpportunityId);
            }
        }
    }

    if (Trigger.isDelete) {
        for (OpportunityLineItem oli : Trigger.old) {
            if (oli.OpportunityId != null) {
                oppIdSet.add(oli.OpportunityId);
            }
        }
    }

    if (oppIdSet.isEmpty()) return;

    // Map to group OLIs by Opportunity
    Map<Id, List<OpportunityLineItem>> oppIdToOLIs = new Map<Id, List<OpportunityLineItem>>();

    for (OpportunityLineItem oli : [
        SELECT Id, OpportunityId, Status__c, IgnoreStatus__c
        FROM OpportunityLineItem
        WHERE OpportunityId IN :oppIdSet
    ]) {

        // Ignore flagged records
        if (oli.IgnoreStatus__c == true) continue;

        if (!oppIdToOLIs.containsKey(oli.OpportunityId)) {
            oppIdToOLIs.put(oli.OpportunityId, new List<OpportunityLineItem>());
        }

        oppIdToOLIs.get(oli.OpportunityId).add(oli);
    }

    List<Opportunity> oppsToUpdate = new List<Opportunity>();

    for (Id oppId : oppIdSet) {

        List<OpportunityLineItem> oliList = oppIdToOLIs.get(oppId);

        // Skip if all OLIs are ignored
        if (oliList == null || oliList.isEmpty()) continue;

        Boolean allApproved = true;
        Boolean allRejected = true;
        Boolean anyPending = false;

        for (OpportunityLineItem oli : oliList) {

            if (oli.Status__c == 'Pending') {
                anyPending = true;
            }

            if (oli.Status__c != 'Approved') {
                allApproved = false;
            }

            if (oli.Status__c != 'Rejected') {
                allRejected = false;
            }
        }

        String finalStatus;

        if (anyPending) {
            finalStatus = 'Pending';
        } else if (allApproved) {
            finalStatus = 'Approved';
        } else if (allRejected) {
            finalStatus = 'Rejected';
        } else {
            finalStatus = 'Pending'; // Mixed case
        }

        oppsToUpdate.add(new Opportunity(
            Id = oppId,
            OLI_Status__c = finalStatus   // Field on Opportunity
        ));
    }

    // Update Opportunity (safe in after trigger)
    if (!oppsToUpdate.isEmpty()) {
        update oppsToUpdate;
    }
}
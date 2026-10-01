trigger OppTrigger on Opportunity (after insert, after update, after delete, after undelete) {
    
    Set<Id> accountIdSet = new Set<Id>();
    
    if(trigger.isInsert || trigger.IsUpdate || trigger.isUndelete){
        for(Opportunity Opp: trigger.new){
            if(opp.accountId != null){
                accountIdSet.add(opp.accountId);
            }
        }
    }
    
    if(trigger.isDelete){
        for(Opportunity Opp: trigger.old){
            if(opp.accountId != null){
                accountIdSet.add(opp.accountId);
            }
        }
    }
    
    Map<Id, Integer> accOppMap = new Map<Id, Integer>();
    
    for(AggregateResult ar :[SELECT  AccountId accId, Count(Id) oppCount FROM Opportunity WHERE AccountId IN: accountIdSet Group by AccountId]){
        accOppMap.put((Id) ar.get('accId'), (Integer)ar.get('oppCount'));
    }
    
    
    Map<Id, Integer> accWonOppMap = new Map<Id, Integer>();
    
    for(AggregateResult ar :[SELECT  AccountId accId, Count(Id) oppCount FROM Opportunity WHERE AccountId IN: accountIdSet AND StageName='Closed Won' Group by AccountId]){
        accWonOppMap.put((Id) ar.get('accId'), (Integer)ar.get('oppCount'));
    }
    
    List<Account> accListToUpdate = new List<Account>();
    for(Id accId: accountIdSet){
        Account acc = new Account(Id = accId);
        if(accOppMap.containsKey(acc.Id)){
            acc.Total_Opps__c = accOppMap.get(accId);
        }
        
        if(accWonOppMap.containsKey(acc.Id)){
            acc.Closed_Won_Opps__c = accWonOppMap.get(accId);
        }
        accListToUpdate.add(acc);
    }
    if(!accListToUpdate.isEmpty()){
        update accListToUpdate;
    }

}
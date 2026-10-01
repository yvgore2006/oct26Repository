// updated trigger deployed using manifest
trigger AccountTrigger on Account (before delete, after update) {
    Set<Id> accIds = new Set<Id>();
    
    List<Account> accList = [Select id from Account where Id IN (Select AccountId FROM Contact)];
    
    for(Account acc: accList){        
        if(accList.Size()>0){
            accIds.Add(acc.Id);
        }
        
    }    

    for(Account acc: Trigger.old){
        if(Trigger.isDelete){
            acc.addError('Account has contacts. Cannot be deleted');
        }
    }
    
   if (Trigger.isUpdate) {
        List<Id> accIds = new List<Id>();

        for (Account acc : Trigger.new) {
            Account oldAcc = Trigger.oldMap.get(acc.Id);

            if (acc.Type != oldAcc.Type) {
                accIds.add(acc.Id);
            }
        }

        if (!accIds.isEmpty()) {
            System.enqueueJob(new AccountIntegrationJob(accIds));
        }
    }
    
}
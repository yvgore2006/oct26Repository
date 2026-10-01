public class AccountIntegrationJob implements Queueable, Database.AllowsCallouts {

    List<Id> accIds;

    public AccountIntegrationJob(List<Id> accIds) {
        this.accIds = accIds;
    }

    public void execute(QueueableContext context) {

        List<Opportunity> oppList = new List<Opportunity>();

        for (Account acc : [SELECT Id, name, Type FROM Account WHERE Id IN :accIds]) {

            RestIntegrationDemo.UserWrapper user = RestIntegrationDemo.getUserData();
            system.debug('User--'+ user);

            if (user != null) {
                oppList.add(new Opportunity(
                    Name = acc.name + acc.Type + '-Inte-' + user.name,
                    StageName = 'Prospecting',
                    CloseDate = Date.today(),
                    AccountId = acc.Id
                ));
            }
        }

        if (!oppList.isEmpty()) {
            insert oppList;
          
        }
    }
}
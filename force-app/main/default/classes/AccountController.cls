public with sharing class AccountController {
    @AuraEnabled(Cacheable = true)
    public static List<Account> getAccounts() {
        return [SELECT Id, name, industry, Phone FROM Account LIMIT 7];

    }
}
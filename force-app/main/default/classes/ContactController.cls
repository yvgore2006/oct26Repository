public with sharing class ContactController {
    
    @AuraEnabled
    public static void createContact(String firstName, String lastName) {
        Contact con = new Contact();
        con.FirstName = firstName;
        con.LastName = lastName;
        
        insert con;
    }
}
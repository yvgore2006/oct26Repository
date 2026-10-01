public with sharing class CreateContact {

    @AuraEnabled
    public static void CreateContactFromForm(string Firstname, String Lastname) {

        Contact con = new Contact();
        con.firstname= Firstname;
        con.Lastname = Lastname;

        insert con;

    }
}
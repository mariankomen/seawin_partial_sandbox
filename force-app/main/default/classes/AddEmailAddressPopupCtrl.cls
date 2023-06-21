public with sharing class AddEmailAddressPopupCtrl {
    
    public SelectOption[] selectedContacts { get; set; }
    public static string selectedEmails {get; set;}
    public SelectOption[] allContacts { get; set; }
    public SelectOption[] allSalesReps { get; set; }
    
    public string shipmentId {get; set;}
    
    public string existingTo {get; set;}
    public string completeCc {get; set;}
    
    public string existingCc {get; set;}
    public string completeTo {get; set;}
    
    public String message { get; set; }
    
    public AddEmailAddressPopupCtrl() {
        
        string acctId = ApexPages.currentPage().getParameters().get('accountId');
        shipmentId = ApexPages.currentPage().getParameters().get('shipmentId');
        
        existingTo = ApexPages.currentPage().getParameters().get('existingTo');
        completeCc = ApexPages.currentPage().getParameters().get('completeCc');
        
        existingCc = ApexPages.currentPage().getParameters().get('existingCc');
        completeTo = ApexPages.currentPage().getParameters().get('completeTo');
        
        selectedContacts = new List<SelectOption>();
        // Account contacts
        allContacts = new List<SelectOption>();
        List<Contact> contacts = [SELECT Name, Id, Email FROM Contact where AccountId =:acctId and 
                                  Email != null]; 
        for ( Contact c : contacts ) {
            allContacts.add(new SelectOption(c.id, c.Name + '(' + c.Email + ')'));
        }
        
        // sales reps
        allSalesReps = new List<SelectOption>();
        List<sales_rep__c> sreps = [SELECT Name, Id, Email__c FROM sales_rep__c where name != 'Automated Process' 
                                    and Email__c != null]; 
        for ( sales_rep__c s : sreps ) {
            allSalesReps.add(new SelectOption(s.id, s.Name + '(' + s.Email__c + ')'));
        }
    }
    
    public void save() {
        system.debug('Selected Emails are:' + selectedEmails);
    }
    public void cancel(){
          
    }
}
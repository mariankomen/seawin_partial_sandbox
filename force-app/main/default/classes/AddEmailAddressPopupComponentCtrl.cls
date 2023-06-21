public class AddEmailAddressPopupComponentCtrl {
    // SelectOption lists for public consumption
    public string selectedEmails { get; set; }
    public SelectOption[] contactsOptions { get; set; }
    public SelectOption[] salesRepOptions { get; set; }
    public SelectOption[] rightOptions { get; set; }
    
    public SelectOption[] searchOption {get; set;}
    
    public string searchText {get; set;}
    
    public AddEmailAddressPopupComponentCtrl(){
        
        searchOption = new list<selectOption>();
        
        selectedEmails = '';
    }
    
    // Parse &-separated values and labels from value and 
    // put them in option
    private void buildEmails(String value) {
        
        String[] parts = value.split('&');
        for(string str : parts){
            string email = str.split(':')[0];
            if(email != '' || email != null){
                
                selectedEmails += email + ';';
                
            }
        }
        // selectedEmails = selectedEmails.removeStart(';');
        // selectedEmails = selectedEmails.removeEnd(';');
        
        AddEmailAddressPopupCtrl.selectedEmails = selectedEmails;
        
    }
    public String rightOptionsHidden { get; set {
        rightOptionsHidden = value;
        buildEmails(value);
    }
                                     }
    public PageReference searchMethod(){
        
        if(searchText != null){
            
            searchOption = new list<selectOption>();
            
            string nameIs = '%' + searchText + '%';
            
            set<string> UniqueEmails = new set<string>();
            
            // --------------- Search Contacts --------------------------- //
            
            // search contact name first
            list<contact> contacts = [select id, name, email from contact where name like:nameIs];
            if(contacts.IsEmpty()){
                // now search email
                contacts = [select id, name, email from contact where email like:nameIs];
                if(!contacts.IsEmpty()){
                    
                    for ( Contact c : contacts ) {
                        if(!UniqueEmails.contains(c.Name + '(' + c.Email + ')')){
                            UniqueEmails.add(c.Name + '(' + c.Email + ')');
                            searchOption.add(new SelectOption(c.id, c.Name + '(' + c.Email + ')'));
                        }
                    }
                }
            }else{
                for ( Contact c : contacts ) {
                    if(!UniqueEmails.contains(c.Name + '(' + c.Email + ')')){
                        UniqueEmails.add(c.Name + '(' + c.Email + ')');
                        searchOption.add(new SelectOption(c.id, c.Name + '(' + c.Email + ')'));
                    }
                }
            }
            
            // ------------- Search Sales Rep -------------------------- //
            list<sales_rep__c> reps = [select id, name, email__c from sales_rep__c where name like:nameIs];
            if(reps.IsEmpty()){
                // now search email
                reps = [select id, name, email__c from sales_rep__c where email__c like:nameIs];
                if(!reps.IsEmpty()){
                    for ( sales_rep__c s : reps ) {
                        if(!UniqueEmails.contains(s.Name + '(' + s.Email__c + ')')){
                            UniqueEmails.add(s.Name + '(' + s.Email__c + ')');
                            searchOption.add(new SelectOption(s.id, s.Name + '(' + s.Email__c + ')'));
                        }
                    }
                }
            }else{
                for ( sales_rep__c s : reps ) {
                    if(!UniqueEmails.contains(s.Name + '(' + s.Email__c + ')')){
                        UniqueEmails.add(s.Name + '(' + s.Email__c + ')');
                        searchOption.add(new SelectOption(s.id, s.Name + '(' + s.Email__c + ')'));
                    }
                }
            }
        }
        
        return null;
    }
}
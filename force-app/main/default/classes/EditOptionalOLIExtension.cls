public class EditOptionalOLIExtension {
    
    Private Id oppId {get; set;}
    public string RetURL {get; set;}
    Private static Id optionalOliId {get; set;}    
    Private List<Optional_Products_Opportunity__c> optionalOli {get; set;}
    public Boolean EditErrorMsgOpp {get; set;}
    public String tabname {get; set;}
    public String title {get; set;}
    
    public EditOptionalOLIExtension(ApexPages.StandardController std){
     
        optionalOliId = (Id)std.getId();
        RetURL = ApexPages.currentPage().getParameters().get('retURL');
        
        optionalOli = [select id, Opportunity__c from Optional_Products_Opportunity__c where id =: optionalOliId];
        oppId = optionalOli[0].Opportunity__c;
    
         
        if(RetURL.contains('OpportunityPage')){
            tabname = 'Opportunity';
            title = 'Opportunity';   
        }else{
            tabname = 'Quote';
            title = 'Quote';    
        }
        
    
        EditErrorMsgOpp = true;
    }
    
    public PageReference EditProcess(){
         
        LIST<AcctSeedERP__Sales_Order__c> SO = [select id from AcctSeedERP__Sales_Order__c
                                                where AcctSeedERP__Opportunity__c =: oppId limit 1];
       
        if(SO.isEmpty()){
            PageReference page = new PageReference('/'+optionalOliId+'/e?nooverride=1&retURL='+oppId);
            page.setRedirect(true);
            EditErrorMsgOpp = false;
            return page;
        }
        
        return null;
    }
    
    public PageReference back(){
        
        PageReference redirectPage = null;
        
        //if(soId != null){
            redirectPage = new PageReference('/' + oppId);
            redirectPage.setRedirect(true);
            return redirectPage;
    }
    
}
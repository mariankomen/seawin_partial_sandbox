public class OpportunityEditOverrideExtension {

    public string OppID {get; set;}
    public string RetURL {get; set;}
    Public Boolean EditErrorMsgOpp {get; set;}
    public string tabname{get; set;}
    public string title{get; set;}
    public string recordtypeid {get; set;}
    
    public OpportunityEditOverrideExtension(ApexPages.StandardController std){
        
        OppID = ApexPages.currentPage().getParameters().get('id');
        RetURL = ApexPages.currentPage().getParameters().get('retURL');
        recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
        
        if(RetURL.contains('OpportunityPage')){ 
            tabname = 'Opportunity';
            title = 'Opportunity';   
        }else if(RetURL.contains('AccountPage')){
            tabname = 'Account';
            title = 'Account';                              
        }else{
            tabname = 'Contact';
            title = 'Contact';    
        }
        
        EditErrorMsgOpp  = true;
    }
    
    public PageReference EditProcess(){
        LIST<AcctSeedERP__Sales_Order__c> SO = [select id from AcctSeedERP__Sales_Order__c
                                                where AcctSeedERP__Opportunity__c =: OppID limit 1];
        if(SO.isEmpty()){
            EditErrorMsgOpp = false;
            string urlPart = '';
            
            if(recordtypeid == null){
                
                urlPart = '/'+OppID+'/e?retURL=/apex/OpportunityPage?id='+OppID+'&nooverride=1';
                
            }else{
                
                urlPart = '/'+OppID+'/e?retURL=/apex/OpportunityPage?id='+OppID+'&nooverride=1&RecordType='+recordtypeid;
            }
            
            
            PageReference page = new PageReference(urlPart);
            page.setRedirect(true);
            return page;
        }
         
        return null;
    }
    
    public PageReference back(){
      
         PageReference page = new PageReference(RetURL);
         page.setRedirect(true);
         return page;
     }
}
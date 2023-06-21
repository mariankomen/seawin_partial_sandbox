public class OpportunityShipmentAddExtension {
    
    public string OppID {get; set;}
    public string RetURL {get; set;}
    Public Boolean AddErrorMsgOpp {get; set;}

    public OpportunityShipmentAddExtension(ApexPages.StandardController std){ 
        
        RetURL = ApexPages.currentPage().getParameters().get('retURL');
        OppID = RetURL.substringBetween('id=', '&sfdc');
        AddErrorMsgOpp  = true;
    }
    
    public PageReference AddProcess(){
        
        LIST<Opportunity> opp = [select id, name from Opportunity where id =: OppID limit 1];
        LIST<AcctSeedERP__Sales_Order__c> SO = [select id from AcctSeedERP__Sales_Order__c
                                                where AcctSeedERP__Opportunity__c =: OppID limit 1];
        if(SO.isEmpty()){
            AddErrorMsgOpp = false;
            PageReference page = new PageReference('/a1n/e?CF00N1I00000OZRfu='+opp.get(0).Name+'&nooverride=1&CF00N1I00000OZRfu_lkid='+
                                                   OppID+'&retURL=/'+OppID);
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
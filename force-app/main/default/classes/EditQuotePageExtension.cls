public class EditQuotePageExtension {
    public Quote quote {get; set;}
    public Opportunity opp {get; set;}
    public string r {get; set;}
    public Boolean notApproved {get; set;}
    public Boolean EditQuoteErrorMsg{get; set;}
    private string retUrl {private get; private set;}
    
    public EditQuotePageExtension(ApexPages.StandardController std){
        
        List<string> fieldNames = new List<string>{'OpportunityId'};

        if(!Test.isRunningTest()) std.addFields(fieldNames);

        retUrl = ApexPages.currentPage().getParameters().get('retURL');
        quote = (Quote)std.getRecord();
        opp = [select id, recordtypeid, Approval_Status__c
               from opportunity where id =: quote.OpportunityId limit 1];
        
        r = [select name from recordtype where 
             sobjecttype = 'Opportunity' and 
             id =:opp.recordtypeId limit 1][0].name;
    }
     
    public PageReference pageAction(){
        
        PageReference page = new PageReference('/'+quote.id+'/e?retURL=/'+quote.id + '&nooverride=1');
        LIST<AcctSeedERP__Sales_Order__c> SO = [select id from AcctSeedERP__Sales_Order__c
                                                where AcctSeedERP__Opportunity__c =: opp.Id limit 1];

        if(opp.Approval_Status__c != 'Approved' && (r == 'Seawin USA Hospitality' || 
                                                    r == 'Seawin China Hospitality' ||
                                                    r == 'Seawin China OEM')){
                                                        notApproved = true;
                                                        return null;
                                                    }
        else if(!SO.isEmpty()){
            EditQuoteErrorMsg = true;
            return null;
        }
        
        page.setRedirect(true);
        
        return page;

    } 
    
    public PageReference back(){
         
        PageReference page = new PageReference(RetURL);
        page.setRedirect(true);
        return page;
    }
}
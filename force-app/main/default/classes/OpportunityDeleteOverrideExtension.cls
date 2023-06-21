public class OpportunityDeleteOverrideExtension {
    
    private string oppId {private get; private set;}
    private opportunity opp {private get; private set;}
    private string parentId {private get; private set;}
    private string retUrl {private get; private set;}
    public string tabname{get; set;}
  
    Public Boolean DeleteErrorMsgOpp {get; set;}
    
    public OpportunityDeleteOverrideExtension(ApexPages.StandardController std){
        
        retUrl = ApexPages.currentPage().getParameters().get('retURL');
        oppId = (string)std.getId();
        
        opp = [select id, parent_opportunity__c from opportunity where id =:oppId limit 1];
        
        parentId = opp.Parent_Opportunity__c;
        DeleteErrorMsgOpp = false;
    }
    
    public PageReference TryDelete(){
        List<AcctSeed__Billing__c> relatedBillins = [SELECT Id, AcctSeed__Opportunity__c, AcctSeed__Status__c FROM AcctSeed__Billing__c WHERE AcctSeed__Opportunity__c =:Opp.Id LIMIT 50000];
        Integer countPosted = 0;
        Integer countPayments = 0;
        Integer countCreditMemosOrInvoices = 0;
        if(!relatedBillins.isEmpty()){
            for(AcctSeed__Billing__c billing: relatedBillins){
                if(billing.AcctSeed__Status__c == 'Posted'){
                    countPosted += 1;
                }
            }
        }
        
        if(!relatedBillins.isEmpty()){
            List<AcctSeed__Billing_Cash_Receipt__c> relatedCashReceipts = [SELECT Id FROM AcctSeed__Billing_Cash_Receipt__c WHERE AcctSeed__Billing__c IN:relatedBillins];
            countPayments = relatedCashReceipts.size();

            List<AcctSeed__Billing_Credit_Memo__c> relatedCreditMemos = [SELECT Id FROM AcctSeed__Billing_Credit_Memo__c WHERE AcctSeed__Billing_Credit_Memo__c IN:relatedBillins OR AcctSeed__Billing_Invoice__c IN:relatedBillins ];
            countCreditMemosOrInvoices = relatedCreditMemos.size();
        }

        if(countPosted > 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Opportunity can not be deleted because has posted Billing.')); 
            return null;
        }else if(countPayments > 0 || countCreditMemosOrInvoices > 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Opportunity can not be deleted because Billing has Payment(s) or Credit Memo(s) or Credit Invoice(s).')); 
            return null;
        }else if(countPosted == 0 && countPayments == 0 && countCreditMemosOrInvoices == 0){
            try{
                if(!relatedBillins.isEmpty()) delete relatedBillins;
                delete opp;
                PageReference page = new PageReference('/006/o');
            page.setRedirect(true);
            
                return page;
            }catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage())); 
            }
        }

        return null;
    }
    
    public PageReference back(){
      
         if(retUrl.contains('/006/o')){
             retUrl = '/apex/OpportunityPage?id='+oppId+'&sfdc.override=1';
         }
         
         PageReference page = new PageReference(RetURL);
         page.setRedirect(true);
         return page;
     }
    
}
public class SalesOrderDeleteExtension {

    public string SOID {get; set;}
    public string RetURL {get; set;}
    public AcctSeedERP__Sales_Order__c SO{get; set;}
    Public Boolean ErrorMsgPO {get; set;}
    public string tabname{get; set;}
    public string title{get; set;}
    
    public SalesOrderDeleteExtension(ApexPages.StandardController std){
         
        SOID = ApexPages.currentPage().getParameters().get('id');
        RetURL = ApexPages.currentPage().getParameters().get('retURL');

        SO = [select id from AcctSeedERP__Sales_Order__c where id =: SOID limit 1];
        
        ErrorMsgPO  = false;
    }
    
    public PageReference DeleteProcess(){
        List<AcctSeed__Billing__c> relatedBillins = [SELECT Id, AcctSeedERP__Sales_Order__c, AcctSeed__Status__c FROM AcctSeed__Billing__c WHERE AcctSeedERP__Sales_Order__c =:SO.Id LIMIT 50000];
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

        PageReference page = new PageReference('/'+SOID);
        if(countPosted > 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Sales Order can not be deleted because has posted Billing.')); 
            return null;
        }else if(countPayments > 0 || countCreditMemosOrInvoices > 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Sales Order can not be deleted because Billing has Payment(s) or Credit Memo(s) or Credit Invoice(s).')); 
            return null;
        }else if(countPosted == 0 && countPayments == 0 && countCreditMemosOrInvoices == 0){
            if(!relatedBillins.isEmpty()) delete relatedBillins;
            delete SO;

            page = new PageReference('/a1H/o');
        }

        
        page.setRedirect(true);
        
        return page;
    }
    
    public PageReference back(){
      
         
        RetURL = '/'+SOID;
         
        PageReference page = new PageReference(RetURL);
        System.debug('RetURL: ' + RetURL);
        page.setRedirect(true);
        return page;
         
     }
    
}
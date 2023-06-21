public with sharing class BillingTaxesMessageController {

    public Id billingId {get; set;}
    public Boolean billingHasTaxes {get; set;}
    public BillingTaxesMessageController(ApexPages.StandardController stdController) {
        billingId = stdController.getId();
        billingHasTaxes = true;

        billingHasTaxLine();
    }


    public void billingHasTaxLine(){
        AcctSeed__Billing__c billing = [SELECT Id, GL_Account_Variable_1__c, AcctSeed__Customer__c FROM AcctSeed__Billing__c WHERE Id=:billingId];

        try{
            if(billing.GL_Account_Variable_1__c == 'Seawin USA'){

                List<AcctSeed__Billing_Line__c> lines = [SELECT Id, AcctSeed__Product__c FROM AcctSeed__Billing_Line__c WHERE AcctSeed__Billing__c=:billingId];
                Set<Id> linesProducts = new Set<Id>();
                for(AcctSeed__Billing_Line__c bli: lines){
                    linesProducts.add(bli.AcctSeed__Product__c);
                }
        
                List<AcctSeed__Account_Tax__c> accountTaxes = [SELECT id, AcctSeed__Tax_Rate__c, AcctSeed__Tax_Rate__r.AcctSeed__Accounting_Type__c FROM AcctSeed__Account_Tax__c WHERE AcctSeed__Account__c=:billing.AcctSeed__Customer__c LIMIT 1];
        
                if(accountTaxes.isEmpty()){
                    billingHasTaxes = true;
                    return;
                }
                if(!accountTaxes.isEmpty() && !linesProducts.contains(accountTaxes[0].AcctSeed__Tax_Rate__c) && accountTaxes[0].AcctSeed__Tax_Rate__r.AcctSeed__Accounting_Type__c == 'Tax Rate'){
                    billingHasTaxes = false;
                }else{
                    billingHasTaxes = true;
                }
            }
        }catch(Exception e){
            system.debug(e.getMessage());
        }
        
        
    }
}
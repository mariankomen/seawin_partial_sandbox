public with sharing class AfterBillingCashReceiptExtension {
    

    /*****************************************************************************************************
    *   @method       : unpostRelatedCashReceipts
    *   @description  : Unpost and delete related to Billing Cash Receipts which was deleted
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    @future
    public static void unpostRelatedCashReceipts(Set<Id> cash_receipts_ids){
        

        List<AcctSeed__Cash_Receipt__c> cash_receipts = [SELECT Id,
                                                                AcctSeed__Accounting_Period__c,
                                                                AcctSeed__Accounting_Year__c,
                                                                AcctSeed__Account__c
                                                        FROM AcctSeed__Cash_Receipt__c 
                                                        WHERE Id IN:cash_receipts_ids];
        if(!Test.isRunningTest()){
            AcctSeed.PostResult[] unpostResults = AcctSeed.CashReceiptPostService.unpostCashReceipts(cash_receipts);
        }                                                       
        
        try{
            delete cash_receipts;
        } catch(Exception e){
            system.debug(e.getMessage());
        }
    }
}
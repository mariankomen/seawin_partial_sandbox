public with sharing class AfterBillingCashReceiptExtension {
    
    public static final String DELETE_WITH_EXISTING_PAYABLE_ERROR = '<h1>Can not delete cash receipt, as it have related commission(s) with payables.</h1>';

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

    public static void beforedDelete_checkIfAvailableForDelete(List<sObject> oldList , Map<Id, sObject> oldMap){
        List<AcctSeed__Billing_Cash_Receipt__c> cashReceiptOldList = (List<AcctSeed__Billing_Cash_Receipt__c>)oldList;
        Map<Id, sObject> cashReceiptOldMap = (Map<Id, sObject>)oldMap;

        List<Sales_Order_Commissions__c> commissionList = [SELECT Id, Billing_Cash_Receipt__c, Billing_Cash_Receipt__r.AcctSeed__Cash_Receipt__c FROM Sales_Order_Commissions__c WHERE Billing_Cash_Receipt__c IN:cashReceiptOldMap.keySet()];

        Map<Id, Set<Id>> cashReceiptWithCommissionsMap = new Map<Id, Set<Id>>();

        for(Sales_Order_Commissions__c commission: commissionList){
            if(commission.Billing_Cash_Receipt__r.AcctSeed__Cash_Receipt__c != null){
                if(!cashReceiptWithCommissionsMap.containsKey(commission.Billing_Cash_Receipt__c)){
                    cashReceiptWithCommissionsMap.put(commission.Billing_Cash_Receipt__c, new Set<Id>{commission.Id});
                }else{
                    cashReceiptWithCommissionsMap.get(commission.Billing_Cash_Receipt__c).add(commission.Id);
                }
            }
        }
        system.debug('cashReceiptWithCommissionsMap: '+cashReceiptWithCommissionsMap);
        List<AcctSeed__Account_Payable__c> commissionPayableList = [SELECT Id, Sales_Order_Commissions__c FROM AcctSeed__Account_Payable__c WHERE Sales_Order_Commissions__c IN:commissionList];

        Map<Id, Boolean> commissionHasPayableMap = new Map<Id, Boolean>();

        for(AcctSeed__Account_Payable__c payable: commissionPayableList){
            commissionHasPayableMap.put(payable.Sales_Order_Commissions__c, true);
        }
        system.debug('commissionHasPayableMap: '+commissionHasPayableMap);
        for(AcctSeed__Billing_Cash_Receipt__c cashReceipt: cashReceiptOldList){
            Set<Id> cashReceiptCommissionIds = cashReceiptWithCommissionsMap.containsKey(cashReceipt.Id) ? cashReceiptWithCommissionsMap.get(cashReceipt.Id) : null;
            system.debug('cashReceiptCommissionIds: '+cashReceiptCommissionIds);
            if(cashReceiptCommissionIds != null && !cashReceiptCommissionIds.isEmpty()){
                system.debug('here');
                for(Id commissionId: cashReceiptCommissionIds){
                    if(commissionHasPayableMap.containsKey(commissionId)){ //if payable exist
                        cashReceipt.addError(DELETE_WITH_EXISTING_PAYABLE_ERROR, false);
                    }
                }
            }
        }
        






    }
}
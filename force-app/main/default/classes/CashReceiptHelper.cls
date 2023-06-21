public with sharing class CashReceiptHelper implements ITriggerHelper{

    public static final String DELETE_WITH_EXISTING_PAYABLE_ERROR = 'Can not delete cash receipt, as it have related commission(s) with payables.';

    public static void beforeInsert(List<sObject> newList) {

    }
     
    public static void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
         
    }
     
    public static void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {

    }
     
    public static void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
    }
     
    public static void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        beforedDelete_checkIfAvailableForDelete(oldList, oldMap);
    }
     
    public static void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
         
    }
     
    public static void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
         
    }


    public static void beforedDelete_checkIfAvailableForDelete(List<sObject> oldList , Map<Id, sObject> oldMap){
        List<AcctSeed__Cash_Receipt__c> cashReceiptOldList = (List<AcctSeed__Cash_Receipt__c>)oldList;
        Map<Id, sObject> cashReceiptOldMap = (Map<Id, sObject>)oldMap;

        List<Sales_Order_Commissions__c> commissionList = [SELECT Id, Billing_Cash_Receipt__r.AcctSeed__Cash_Receipt__c FROM Sales_Order_Commissions__c WHERE Billing_Cash_Receipt__r.AcctSeed__Cash_Receipt__c IN:cashReceiptOldMap.keySet()];

        Map<Id, Set<Id>> cashReceiptWithCommissionsMap = new Map<Id, Set<Id>>();

        for(Sales_Order_Commissions__c commission: commissionList){
            if(commission.Billing_Cash_Receipt__r.AcctSeed__Cash_Receipt__c != null){
                if(!cashReceiptWithCommissionsMap.containsKey(commission.Billing_Cash_Receipt__r.AcctSeed__Cash_Receipt__c)){
                    cashReceiptWithCommissionsMap.put(commission.Billing_Cash_Receipt__r.AcctSeed__Cash_Receipt__c, new Set<Id>{commission.Id});
                }else{
                    cashReceiptWithCommissionsMap.get(commission.Billing_Cash_Receipt__r.AcctSeed__Cash_Receipt__c).add(commission.Id);
                }
            }
        }

        List<AcctSeed__Account_Payable__c> commissionPayableList = [SELECT Id, Sales_Order_Commissions__c FROM AcctSeed__Account_Payable__c WHERE Sales_Order_Commissions__c IN:commissionList];

        Map<Id, Boolean> commissionHasPayableMap = new Map<Id, Boolean>();

        for(AcctSeed__Account_Payable__c payable: commissionPayableList){
            commissionHasPayableMap.put(payable.Sales_Order_Commissions__c, true);
        }

        for(AcctSeed__Cash_Receipt__c cashReceipt: cashReceiptOldList){
            Set<Id> cashReceiptCommissionIds = cashReceiptWithCommissionsMap.containsKey(cashReceipt.Id) ? cashReceiptWithCommissionsMap.get(cashReceipt.Id) : null;
            if(cashReceiptCommissionIds != null && !cashReceiptCommissionIds.isEmpty()){
                for(Id commissionId: cashReceiptCommissionIds){
                    if(commissionHasPayableMap.containsKey(commissionId)){ //if payable exist
                        cashReceipt.addError(DELETE_WITH_EXISTING_PAYABLE_ERROR);
                    }
                }
            }
        }
        






    }
}
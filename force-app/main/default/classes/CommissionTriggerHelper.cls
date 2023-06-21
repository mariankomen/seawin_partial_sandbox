public with sharing class CommissionTriggerHelper implements ITriggerHelper{
    
    public static final String COMMISSION_WITH_PAYABLE_ERROR = '<h1>You can not delete commission because it has associated Payable</h1>';

    public static void beforeInsert(List<sObject> newList) {
    }
     
    public static void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        CommissionTriggerHandler.afterInsertHandler((List<Sales_Order_Commissions__c>)newList);
    }
     
    public static void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {

    }
     
    public static void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        CommissionTriggerHandler.afterInsertHandler((List<Sales_Order_Commissions__c>)newList);
    }
     
    public static void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        beforeDelete_checkIfDeleteAvailable(oldList);
    }
     
    public static void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        CommissionTriggerHandler.afterInsertHandler((List<Sales_Order_Commissions__c>)oldList);
    }
     
    public static void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
         
    }

    public static void beforeDelete_checkIfDeleteAvailable(List<sObject> oldList){
        List<Sales_Order_Commissions__c> commissionList = (List<Sales_Order_Commissions__c>)oldList;
        Map<Id, Sales_Order_Commissions__c> commissionMap = new Map<Id, Sales_Order_Commissions__c>(commissionList);

        List<AcctSeed__Account_Payable__c> commissionPayableList = [SELECT Id, Sales_Order_Commissions__c FROM AcctSeed__Account_Payable__c WHERE Sales_Order_Commissions__c IN:commissionMap.keySet()];
        Set<Id> commissionWithPayableSet = new Set<Id>();

        for(AcctSeed__Account_Payable__c payable: commissionPayableList){
            commissionWithPayableSet.add(payable.Sales_Order_Commissions__c);
        }

        for(Sales_Order_Commissions__c com: commissionList){
            if(commissionWithPayableSet.contains(com.Id)){
                com.addError(COMMISSION_WITH_PAYABLE_ERROR, false);
            }
        }

    }
}
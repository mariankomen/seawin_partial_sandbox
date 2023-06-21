public with sharing class PurchaseOrderLineHelper implements ITriggerHelper{
    
    public static final String ERROR_LINE_RELATED_TO_PAYABLE = '<h1>Purchase Order Line can not be deleted as it associated with Payable record.</h1>';



    public static void beforeInsert(List<sObject> newList) {
    }
     
    public static void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        List<AcctSeedERP__Purchase_Order_Line__c> purchaseOrderLineList = (List<AcctSeedERP__Purchase_Order_Line__c>)newList;

        ProductLastestPurchasedCostHandler.updateLastCostForNonInventory(purchaseOrderLineList);
        PurchaseOrderETACopyHandler.UpdateFields(purchaseOrderLineList);
        PurchaseOrderLineHandler.UpdateFields(purchaseOrderLineList);
        RollupPOLineOnSOLineHandler.rollup(purchaseOrderLineList, Trigger.operationType, false);

    }
     
    public static void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        PurchaseOrderLineHandler.beforeUpdateHandler((Map<Id, AcctSeedERP__Purchase_Order_Line__c>)oldMap, (Map<Id, AcctSeedERP__Purchase_Order_Line__c>)newMap);

    }
     
    public static void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        ProductLastestPurchasedCostHandler.AfterCreation(oldList, newList);
        ProductLastestPurchasedCostHandler.updateLastCostForNonInventory(newList);
        RollupPOLineOnSOLineHandler.rollup(newList, Trigger.operationType, false);

    }
     
    public static void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        beforeDelete_checkDoPayableExist(oldList, oldMap);
    }
     
    public static void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        POandSOResortHandler.reSort(new list<AcctSeedERP__Sales_Order_Line__c>(), oldList);
        RollupPOLineOnSOLineHandler.rollup(oldList, Trigger.operationType, false);


    }
     
    public static void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
        POandSOResortHandler.reSort(new list<AcctSeedERP__Sales_Order_Line__c>(), Trigger.new);
        RollupPOLineOnSOLineHandler.rollup(newList, Trigger.operationType, false);


    }











    public static void beforeDelete_checkDoPayableExist(List<SObject> oldList, Map<Id, SObject> oldMap){
        List<AcctSeedERP__Purchase_Order_Line__c> purchaseOrderOldList = (List<AcctSeedERP__Purchase_Order_Line__c>)oldList;
        Map<Id, AcctSeedERP__Purchase_Order_Line__c> purchaseOrderLineOldMap = (Map<Id, AcctSeedERP__Purchase_Order_Line__c>)oldMap;
        Set<Id> paidPurchaseOrderLinesSet = new Set<Id>();
        List<AcctSeed__Account_Payable_Line__c> payableLines = [SELECT Id, AcctSeedERP__Purchase_Order_Line__c FROM AcctSeed__Account_Payable_Line__c WHERE AcctSeedERP__Purchase_Order_Line__c IN: purchaseOrderLineOldMap.keySet()];

        for(AcctSeed__Account_Payable_Line__c payableLine: payableLines){
            paidPurchaseOrderLinesSet.add(payableLine.AcctSeedERP__Purchase_Order_Line__c);
        }

        for(AcctSeedERP__Purchase_Order_Line__c poLine: purchaseOrderOldList){
            if(paidPurchaseOrderLinesSet.contains(poLine.Id)){ //If set contains id of line, than current line have related payable and can not be deleted
                poLine.addError(ERROR_LINE_RELATED_TO_PAYABLE, false);
            }
        }

    }
}
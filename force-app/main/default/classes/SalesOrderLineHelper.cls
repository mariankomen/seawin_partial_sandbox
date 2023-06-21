public with sharing class SalesOrderLineHelper implements ITriggerHelper{

    public static void beforeInsert(List<sObject> newList) {
    }
     
    public static void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        List<AcctSeedERP__Sales_Order_Line__c> triggerNewList = (List<AcctSeedERP__Sales_Order_Line__c>)newList;

        SalesOrderLineInfoHandler.UpdateInfo(triggerNewList);
        after_calculateTotalNotShippedOnProduct(newList, newMap);

    }
     
    public static void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {

    }
     
    public static void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        List<AcctSeedERP__Sales_Order_Line__c> triggerNewList = (List<AcctSeedERP__Sales_Order_Line__c>)newList;
        List<AcctSeedERP__Sales_Order_Line__c> triggerOldList = (List<AcctSeedERP__Sales_Order_Line__c>)oldList;

        afterUpdate_calculateInStock(newList, oldList);
        SalesOrderLineDescriptionHandler.UpdateIt(triggerOldList, triggerNewList);
        SalesOrderLineFieldValueChangeHandler.FieldValueChange(triggerOldList, triggerNewList);
        SalesOrderLineUpdateDeleteHandler.UpdateCase(triggerNewList);

        after_calculateTotalNotShippedOnProduct(newList, newMap);

    }
     
    public static void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {

    }
     
    public static void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        List<AcctSeedERP__Sales_Order_Line__c> triggerOldList = (List<AcctSeedERP__Sales_Order_Line__c>)oldList;

        POandSOResortHandler.reSort(oldList, new list<AcctSeedERP__Purchase_Order_Line__c>());
        after_calculateTotalNotShippedOnProduct(oldList, oldMap);
    }
     
    public static void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
        List<AcctSeedERP__Sales_Order_Line__c> triggerNewList = (List<AcctSeedERP__Sales_Order_Line__c>)newList;

        POandSOResortHandler.reSort(triggerNewList, new list<AcctSeedERP__Purchase_Order_Line__c>());

        after_calculateTotalNotShippedOnProduct(newList, newMap);
    }


    public static void afterUpdate_calculateInStock(List<SObject> triggerNew, List<SObject> triggerOld){
        List<AcctSeedERP__Sales_Order_Line__c> triggerNewList = (List<AcctSeedERP__Sales_Order_Line__c>)triggerNew;
        List<AcctSeedERP__Sales_Order_Line__c> triggerOldList = (List<AcctSeedERP__Sales_Order_Line__c>)triggerOld;

        // map<id, AcctSeedERP__Sales_Order_Line__c> solMap = 
        //         new map<id, AcctSeedERP__Sales_Order_Line__c>();
            
        //     integer i = 0;
        //     for(AcctSeedERP__Sales_Order_Line__c sol : triggerNewList){
        //         if(sol.AcctSeedERP__Quantity_Shipped__c != 
        //         triggerOldList[i].AcctSeedERP__Quantity_Shipped__c){
                       
        //                solMap.put(sol.id, sol);
        //            }
        //         i++;
        //     }
            
        //     if(solMap.size() > 0){
                
        //         List<AcctSeedERP__Sales_Order_Inventory_Movement__c> soimData = [
        //             select id,AcctSeedERP__Inventory_Balance__c from AcctSeedERP__Sales_Order_Inventory_Movement__c
        //             where AcctSeedERP__Sales_Order_Line__c in:solMap.keyset()
        //         ];
                
        //         if(!soimData.isEmpty()){
                    
        //             set<id> inventoryIds = new set<id>();
                    
        //             for(AcctSeedERP__Sales_Order_Inventory_Movement__c soim : soimData){
                        
        //                 inventoryIds.add(soim.AcctSeedERP__Inventory_Balance__c);
        //             }
                    
        //             InStockQuantityHandler.Process(inventoryIds);
                    
        //         }
        //     }
    }




    public static void after_calculateTotalNotShippedOnProduct(List<SObject> data, Map<Id, SObject> dataMap){
        List<AcctSeedERP__Sales_Order_Line__c> triggerDataList = (List<AcctSeedERP__Sales_Order_Line__c>)data;
        Map<Id, AcctSeedERP__Sales_Order_Line__c> triggerDataMap = (Map<Id, AcctSeedERP__Sales_Order_Line__c>)dataMap;

        Set<Id> productIds = new Set<Id>();

        for(AcctSeedERP__Sales_Order_Line__c sol: triggerDataList){
            if(sol.AcctSeedERP__Product__c != null){
                productIds.add(sol.AcctSeedERP__Product__c);
            }
        }

        if(productIds.isEmpty()) return;

        List<AggregateResult> agrResult = [SELECT SUM(Unallocated_Quantity__c) unallocated, 
                                            AcctSeedERP__Product__c prod 
                                            FROM AcctSeedERP__Sales_Order_Line__c 
                                            WHERE Unallocated_Quantity__c > 0 AND AcctSeedERP__Product__c IN:productIds GROUP BY AcctSeedERP__Product__c];
        system.debug('agrResult: '+agrResult);
        Map<Id, Decimal> productWithUnallocatedQuantityTotalMap = new Map<Id, Decimal>();

        for(AggregateResult agr: agrResult){
            Id productId = (Id)agr.get('prod');
            Decimal unallocatedTotal = (Decimal)agr.get('unallocated');

            productWithUnallocatedQuantityTotalMap.put(productId, unallocatedTotal);
        }

        List<Product2> products = [SELECT Id, Total_UnAllocated_Quantity_on_SO__c FROM Product2 WHERE Id IN:productIds];

        for(Product2 prod: products){
            system.debug('productWithUnallocatedQuantityTotalMap.get(prod.Id): '+productWithUnallocatedQuantityTotalMap.get(prod.Id));
            prod.Total_UnAllocated_Quantity_on_SO__c = productWithUnallocatedQuantityTotalMap.containsKey(prod.Id) ? productWithUnallocatedQuantityTotalMap.get(prod.Id) : 0;
        }

        update products;



    }
}
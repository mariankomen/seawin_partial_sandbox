public with sharing class InventoryBalanceHelper implements ITriggerHelper{
    
    public static void beforeInsert(List<sObject> newList) {
    }
     
    public static void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        updateProductsAvailableQuantityAndInstock(newList);
    }
     
    public static void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {

    }
     
    public static void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        updateProductsAvailableQuantityAndInstock(newList);

    }
     
    public static void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
    }
     
    public static void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        updateProductsAvailableQuantityAndInstock(oldList);
    }
     
    public static void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
         
    }

    public static void updateProductsAvailableQuantityAndInstock(List<SObject> inventoryBalance){
        List<AcctSeedERP__Inventory_Balance__c> inventoryBalanceList = (List<AcctSeedERP__Inventory_Balance__c>)inventoryBalance;
        
        Set<Id> productIds = new Set<Id>();

        for(AcctSeedERP__Inventory_Balance__c balance: inventoryBalanceList){
            if(balance.AcctSeedERP__Product__c != null){
                productIds.add(balance.AcctSeedERP__Product__c);
            }
        }

        if(productIds.isEmpty()) return;

        List<AggregateResult> availableAndInStockQuantity = [SELECT count(Available_Quantity__c), 
                                                            SUM(In_Stock__c ) instock, 
                                                            SUM(Available_Quantity__c) quantity, 
                                                            AcctSeedERP__Product__c product 
                                                            FROM AcctSeedERP__Inventory_Balance__c 
                                                            WHERE AcctSeedERP__Product__c IN:productIds
                                                            GROUP BY AcctSeedERP__Product__c];
        Map<Id, ProductInventoryInfo> totalInventoryData = new Map<Id, ProductInventoryInfo>();

        for(AggregateResult agr: availableAndInStockQuantity){
            totalInventoryData.put((Id)agr.get('product'), new ProductInventoryInfo(
                                                                                    (Id)agr.get('product'),
                                                                                    (Decimal)agr.get('instock'),
                                                                                    (Decimal)agr.get('quantity')
                                                                                    )
            );
        }

        List<Product2> products = [SELECT Id, In_Stock__c, Available_Quantity__c FROM Product2 WHERE Id IN:totalInventoryData.keySet()];

        for(Product2 product: products){
            if(!totalInventoryData.containsKey(product.Id)) continue;
            ProductInventoryInfo inventoryInfo = totalInventoryData.get(product.Id);

            product.In_Stock__c = inventoryInfo.instock;
            product.Available_Quantity__c = inventoryInfo.availabe_quantity;
        }

        update products;
    }



    public class ProductInventoryInfo {
        public Id productId {get;set;}
        public Decimal instock {get;set;}
        public Decimal availabe_quantity {get;set;}

        public ProductInventoryInfo(Id productId, Decimal instock, Decimal availabe_quantity){
            this.productId = productId;
            this.instock = instock;
            this.availabe_quantity = availabe_quantity;

        }
    }
}
public class KitHandler {
    
    public static void process(List<AcctSeedERP__Inventory_Balance__c> od, List<AcctSeedERP__Inventory_Balance__c> nd){
        
        integer i = 0;
        map<id, id> KitChildrenMap = new map<id, id>();
        
        for(AcctSeedERP__Inventory_Balance__c ib : nd){
            
            if(ib.AcctSeedERP__Available_Quantity__c != od[i].AcctSeedERP__Available_Quantity__c){
                
                
                KitChildrenMap.put(ib.AcctSeedERP__Product__c, ib.AcctSeedERP__Product__c);
            }
            
            i++;
        }
        
        if(KitChildrenMap.size() > 0){
            
            List<AcctSeed__Product_Part__c> parentProducts = [SELECT Id, Kit_Product__c 
                                                              FROM AcctSeed__Product_Part__c 
                                                              where Kit_Children__c in:KitChildrenMap.keyset()];
            
            if(!parentProducts.isEmpty()){
                
                set<id> productIds = new set<id>();
                
                for(AcctSeed__Product_Part__c parentProduct : parentProducts){
                    
                    productIds.add(parentProduct.Kit_Product__c);
                }
                
                if(!productIds.isEmpty()){
                    
                    UpdateProductsOfAccountingTypeKit(productIds);
                    
                }
            }
        }
    }
    
    @future
    public static void UpdateProductsOfAccountingTypeKit(set<id> productIds){
        
        Map<id, list<decimal>> Inventories = InventoryCalculationHelper.Calculate(productIds);
        
        if(Inventories.size() > 0){
            
            List<Product2> products = [select id, Kit_Available_Quantity__c from Product2
                                       where id in:Inventories.keyset()];
            
            if(!products.isEmpty()){
                
                for(product2 p : products){
                    
                    p.Kit_Available_Quantity__c = Inventories.get(p.id)[0];
                    
                }
                
                update products;
            }
        }
    }
}
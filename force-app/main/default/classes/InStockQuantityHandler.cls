public class InStockQuantityHandler {
    
    public static void Process(set<id> IDs) {
        
        set<Id> productIds = new Set<Id>();
        
        map<Id, AcctSeedERP__Inventory_Balance__c> InventoryMap = 
            new Map<Id, AcctSeedERP__Inventory_Balance__c>([select id, AcctSeedERP__Product__c from 
                                                            AcctSeedERP__Inventory_Balance__c where id in:IDs]);
        
        for (AcctSeedERP__Inventory_Balance__c ib : InventoryMap.values()) {
            
            productIds.add(ib.AcctSeedERP__Product__c);
        }
        
        if (InventoryMap.size() > 0) {
            UpdateInStock(InventoryMap.keyset(), productIds);
        }
    }
    public static void UpdateInStock(set<id> InventoryIds, set<id> productIds) {
        List<AcctSeedERP__Inventory_Balance__c> Inventories = [
            SELECT Id, In_Stock__c
            FROM AcctSeedERP__Inventory_Balance__c
            WHERE id IN :InventoryIds
        ];
        
        List<AcctSeedERP__Inventory_Balance__c> Updatables = new List<AcctSeedERP__Inventory_Balance__c>();
        
        map<string, Decimal> InStockMap = InventoryCalculationHelper.CalculateInStock(
            productIds
        );
        
        if (InStockMap.size() > 0) {
            for (AcctSeedERP__Inventory_Balance__c ib : Inventories) {
                if (InStockMap.containsKey(ib.id)) {
                    ib.In_Stock__c = InStockMap.get(ib.id);
                    Updatables.add(ib);
                }
            }
            
            if (!Updatables.isEmpty()) {
                try {
                    update Updatables;
                } catch (Exception ex) {
                    system.debug(ex.getMessage());
                }
            }
        }
    }
    
}
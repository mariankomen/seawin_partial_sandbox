trigger InStockQuantityIQATrigger on AcctSeedERP__Inventory_Balance__c (after update) {
    
    // This trigger is fired when the Available Quantity field on Inventory Quantity Available/Inventory Balance
    // is updated
    
    // if(Trigger.isAfter){
    //     if(Trigger.isUpdate){
    //         map<id, AcctSeedERP__Inventory_Balance__c> InventoryMap = 
    //             new map<id, AcctSeedERP__Inventory_Balance__c>();
    //         Integer i = 0;
    //         for(AcctSeedERP__Inventory_Balance__c ib : trigger.new){
                
    //             if(ib.AcctSeedERP__Available_Quantity__c != Trigger.old[i].AcctSeedERP__Available_Quantity__c){

    //                 InventoryMap.put(ib.id, ib);
    //             }
                
    //             i++;
    //         }
            
    //         if(InventoryMap.size() > 0){
                
    //             InStockQuantityHandler.Process(InventoryMap.keyset());
    //         }
    //     }
        
    // }

    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
}
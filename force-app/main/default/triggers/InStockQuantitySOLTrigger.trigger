trigger InStockQuantitySOLTrigger on AcctSeedERP__Sales_Order_Line__c (after update) {
    
    // if(Trigger.isAfter){
    //     if(Trigger.isUpdate){
            
    //         map<id, AcctSeedERP__Sales_Order_Line__c> solMap = 
    //             new map<id, AcctSeedERP__Sales_Order_Line__c>();
            
    //         integer i = 0;
    //         for(AcctSeedERP__Sales_Order_Line__c sol : Trigger.new){
    //             if(sol.AcctSeedERP__Quantity_Shipped__c != 
    //                Trigger.old[i].AcctSeedERP__Quantity_Shipped__c){
                       
    //                    solMap.put(sol.id, sol);
    //                }
    //             i++;
    //         }
            
    //         if(solMap.size() > 0){
                
    //             List<AcctSeedERP__Sales_Order_Inventory_Movement__c> soimData = [
    //                 select id,AcctSeedERP__Inventory_Balance__c from AcctSeedERP__Sales_Order_Inventory_Movement__c
    //                 where AcctSeedERP__Sales_Order_Line__c in:solMap.keyset()
    //             ];
                
    //             if(!soimData.isEmpty()){
                    
    //                 set<id> inventoryIds = new set<id>();
                    
    //                 for(AcctSeedERP__Sales_Order_Inventory_Movement__c soim : soimData){
                        
    //                     inventoryIds.add(soim.AcctSeedERP__Inventory_Balance__c);
    //                 }
                    
    //                 InStockQuantityHandler.Process(inventoryIds);
                    
    //             }
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
}
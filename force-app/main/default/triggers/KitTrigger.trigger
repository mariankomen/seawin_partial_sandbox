trigger KitTrigger on AcctSeedERP__Inventory_Balance__c (after update) {
    
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            
            KitHandler.process(Trigger.old, Trigger.new);
        }
        
    }

}
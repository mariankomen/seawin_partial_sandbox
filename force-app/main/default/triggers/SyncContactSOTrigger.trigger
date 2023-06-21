trigger SyncContactSOTrigger on AcctSeedERP__Sales_Order__c (after update) {
    if(Trigger.IsAfter){
        if(Trigger.IsUpdate){
            SyncContactOPandSOHandler.SalesOrder_Update(trigger.old, trigger.new);
        }
        
    }
}
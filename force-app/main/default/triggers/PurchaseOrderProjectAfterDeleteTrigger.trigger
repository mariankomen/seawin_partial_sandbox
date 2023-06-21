trigger PurchaseOrderProjectAfterDeleteTrigger on AcctSeedERP__Purchase_Order__c (after delete) {

    if(Trigger.IsAfter && Trigger.IsDelete){
        
        PurchaseOrderProjectAfterDeleteHandler.afterDelete(trigger.old);
        
    }
}
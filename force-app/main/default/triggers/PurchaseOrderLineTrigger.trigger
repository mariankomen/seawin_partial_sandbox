trigger PurchaseOrderLineTrigger on AcctSeedERP__Purchase_Order_Line__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    
    TriggerDispatcher.run('PurchaseOrderLineTrigger');
}
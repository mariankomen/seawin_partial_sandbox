trigger InventoryBalanceTrigger on AcctSeedERP__Inventory_Balance__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    TriggerDispatcher.run('InventoryBalanceTrigger');

}
trigger PurchaseOrderAccountChangeTrigger on AcctSeedERP__Purchase_Order__c (before update) {
	if(trigger.isBefore && trigger.IsUpdate){
        PurchaseOrderAccountChangeHandler.ChangeAccountAddress(trigger.old, trigger.new);
    }
}
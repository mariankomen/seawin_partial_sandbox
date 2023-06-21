trigger SalesOrderAccountChangeTrigger on AcctSeedERP__Sales_Order__c (before update) {
	if(trigger.isBefore && trigger.IsUpdate){
        SalesOrderAccountChangeHandler.ChangeAccountAddress(trigger.old, trigger.new);
    }
}
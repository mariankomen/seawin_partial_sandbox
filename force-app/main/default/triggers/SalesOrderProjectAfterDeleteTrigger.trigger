trigger SalesOrderProjectAfterDeleteTrigger on AcctSeedERP__Sales_Order__c (after delete) {
	if(Trigger.IsAfter && Trigger.IsDelete){
        
        SalesOrderProjectAfterDeleteHandler.afterDelete(trigger.old);
        
    }
}
trigger BeforeSalesOrderTrigger on AcctSeedERP__Sales_Order__c (before insert, before update) {
	if(Trigger.isBefore && Trigger.isInsert){
        
        NullifyTemporaryValues.Nullify(Trigger.new);
        SalesOrderStatusChangeHandler.runHandler(trigger.new);
    }else if(Trigger.isBefore && Trigger.isUpdate){
     
        NullifyTemporaryValues.Nullify(Trigger.new);
        // SalesOrderContactChangeHandler.runHandler(Trigger.old, Trigger.new);
    }
}
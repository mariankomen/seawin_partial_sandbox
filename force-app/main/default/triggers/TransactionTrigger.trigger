trigger TransactionTrigger on AcctSeed__Transaction__c (before insert) {
	if(Trigger.isBefore && Trigger.isInsert){
        
        TransactionHandler.BeforeHandler(Trigger.new);
    }
}
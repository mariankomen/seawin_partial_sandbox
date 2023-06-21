trigger SalesOrderProjectTrigger on AcctSeedERP__Sales_Order__c (after insert, after update) {
	
    if(Trigger.IsAfter && Trigger.IsInsert){
        
        SalesOrderProjectTriggerHandler.createIt(new list<AcctSeedERP__Sales_Order__c>(), Trigger.new);
        
    }else if(Trigger.IsAfter && Trigger.IsUpdate){
        
        SalesOrderProjectTriggerHandler.createIt(Trigger.old, Trigger.new);
        
    } 
}
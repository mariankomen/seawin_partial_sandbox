trigger SyncCustomerETAPoTrigger on AcctSeedERP__Purchase_Order__c (after update) {
	if(Trigger.isAfter && Trigger.IsUpdate){
        
        SyncCustomersETAOPsoPOHandler.syncIt(new list<Opportunity>(), new list<Opportunity>(), 
                                         new list<AcctSeedERP__Sales_Order__c>(), new list<AcctSeedERP__Sales_Order__c>(),
                                        Trigger.old, Trigger.new);
        
    }
}
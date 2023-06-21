trigger SyncCustomerETASoTrigger on AcctSeedERP__Sales_Order__c (after update) {
	 if(Trigger.isAfter && Trigger.IsUpdate){
        
        SyncCustomersETAOPsoPOHandler.syncIt(new list<Opportunity>(), new list<Opportunity>(), 
                                         Trigger.old, Trigger.new,
                                        new list<AcctSeedERP__Purchase_Order__c>(), new list<AcctSeedERP__Purchase_Order__c>());
        
    }
}
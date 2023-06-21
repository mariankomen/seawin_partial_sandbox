trigger BillingTrigger on AcctSeed__Billing__c (after insert) {
    
    if(Trigger.IsAfter){
    	if(Trigger.IsInsert){
        
        	BillingHandler.Billing_Contact_Assignment(Trigger.newMap.Keyset());
    	}       
    }
}
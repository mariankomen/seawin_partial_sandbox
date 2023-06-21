trigger AfterBillingCashReceiptTrigger on AcctSeed__Billing_Cash_Receipt__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    
    TriggerDispatcher.run('AfterBillingCashReceiptTrigger');

}
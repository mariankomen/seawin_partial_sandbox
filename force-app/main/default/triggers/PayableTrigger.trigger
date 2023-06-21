trigger PayableTrigger on AcctSeed__Account_Payable__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    TriggerDispatcher.run('PayableTrigger');
}
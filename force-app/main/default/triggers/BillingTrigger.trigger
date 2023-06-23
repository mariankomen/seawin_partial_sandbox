/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 06-22-2023
 * @last modified by  : Marian Lyzhychka
**/
trigger BillingTrigger on AcctSeed__Billing__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    TriggerDispatcher.run('BillingTrigger');
}
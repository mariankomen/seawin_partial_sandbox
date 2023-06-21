trigger CreditOrderTrigger on Credit_Order__c (after insert, after update, before insert, before update, before delete, after delete) {
    
    if(Trigger.isAfter){

    }else if(Trigger.isBefore){
        if(Trigger.isUpdate){
            CreditOrderTriggerHandler.beforeUpdateExtension(Trigger.new);
        }
    }
}
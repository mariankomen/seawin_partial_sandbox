trigger CreditOrderLineTrigger on Credit_Order_Line__c (after insert, after update, after delete, before insert, before update, before delete) {

    if(Trigger.isAfter){
        if(Trigger.isInsert){

        }else if(Trigger.isUpdate){

        }else if(Trigger.isDelete){

        }
    }else if(Trigger.isBefore){
        if(Trigger.isInsert){

        }else if(Trigger.isUpdate){
            CreditOrderLineTriggerHandler.beforeUpdateExtension(Trigger.new);
        }else if(Trigger.isDelete){
            
        }
    }
}
trigger KitInventoryTrigger on AcctSeed__Product_Part__c (after insert, after update, after delete, after undelete) {

    if(Trigger.isAfter){

        if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete){

            KitInventoryHandler.Process(Trigger.new);
        }else if(Trigger.isDelete){

            KitInventoryHandler.Process(Trigger.old);
        }
    }
}
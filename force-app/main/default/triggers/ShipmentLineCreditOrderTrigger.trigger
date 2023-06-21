trigger ShipmentLineCreditOrderTrigger on Shipment_Line_Credit_Order__c (after insert, after update, after delete, before insert) {

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            
        }else if(Trigger.isUpdate){

        }else if(Trigger.isDelete){

        }
    }else if(Trigger.isBefore){
        if(Trigger.isInsert){
            ShipmentCreditOrderLineTriggerHandler.beforeInsertExtension(Trigger.new);
        }
    }
}
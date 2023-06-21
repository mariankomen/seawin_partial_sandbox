trigger OptionalProductOppTrigger on Optional_Products_Opportunity__c (after insert, after update, after delete) {

        if(trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)){
            OptionalProductOppHandler.addProducts(Trigger.isDelete ? Trigger.old : Trigger.new, Trigger.operationType);
            
        }  
}
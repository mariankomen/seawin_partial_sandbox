trigger OptionalProductQuoteTrigger on Optional_Products_Quote__c (after insert, after update, after delete) {
    
    if(trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)){
        
        OptionalProductQuoteHandler.addProducts(Trigger.isDelete ? Trigger.old : Trigger.new, Trigger.operationType);
        
    }

}
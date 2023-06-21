trigger QuoteAfterTrigger on Quote (after update) {
    
    if(Trigger.isAfter && Trigger.isUpdate){
        
        RecordTypeSyncHandler.AfterUpdateQuote(Trigger.old, Trigger.new);
        
    }
}
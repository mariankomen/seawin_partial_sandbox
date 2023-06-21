trigger CopyOptionalProductsToQuoteTrigger on Quote (after insert) {
    
    if(trigger.isAfter && Trigger.isInsert){
            
            CopyOptionalProductsToQuoteHandler.moveOptionalProducts(Trigger.new);
            
        }  
}
trigger ProductTrigger on Product2 (after insert) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            
            ProductHandler.process(Trigger.new);
        }
        
    }

}
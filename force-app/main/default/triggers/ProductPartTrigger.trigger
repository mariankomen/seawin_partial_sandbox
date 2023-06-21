trigger ProductPartTrigger on AcctSeed__Product_Part__c (before insert) {
    
    if(Trigger.isInsert && Trigger.IsBefore){
        
        ProductPartHandler.BeforeInsert(Trigger.new);
    }
}
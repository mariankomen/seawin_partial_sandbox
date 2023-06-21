trigger ProjectTrigger on AcctSeed__Project__c (after update) {
    
    if(Trigger.IsAfter && Trigger.IsUpdate){
        
        ProjectHandler.UpdateIt(Trigger.old, Trigger.new);
    }
}
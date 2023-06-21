trigger GLAccountAfterTrigger on AcctSeed__GL_Account__c (after update) {
    
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            
            GLAccountAfterHandler.Changes(Trigger.old, Trigger.new);
        }
    }
}
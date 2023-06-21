trigger POGLVariableUpdateTrigger on AcctSeedERP__Purchase_Order__c (after update) {
    
    if(Trigger.IsAfter && Trigger.IsUpdate){
     
  		POGLVariableUpdateHandler.changeIt(Trigger.old, Trigger.new);
        
    }
}
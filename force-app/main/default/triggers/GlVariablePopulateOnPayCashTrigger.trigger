trigger GlVariablePopulateOnPayCashTrigger on AcctSeed__AP_Disbursement__c (after insert) {
    
    if(Trigger.IsAfter && Trigger.IsInsert){
        GlVariablePopulateOnPayCashHandler.populateGLVariable1(Trigger.new);
    }
    
}
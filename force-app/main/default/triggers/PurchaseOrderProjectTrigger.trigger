trigger PurchaseOrderProjectTrigger on AcctSeedERP__Purchase_Order__c (after insert, after update) {
    
    if(Trigger.IsAfter && Trigger.IsInsert){
        
        if(!Test.isRunningTest()) PurchaseOrderProjectTriggerHandler.createIt(new list<AcctSeedERP__Purchase_Order__c>(), Trigger.new);
        if(!Test.isRunningTest()) ProjectAutomaticalyClose.checkIfProjectAvailableForClosing(ProjectAutomaticalyClose.prepareSetStrings(Trigger.new, 'Project__c'));
    }else if(Trigger.IsAfter && Trigger.IsUpdate){
        
        PurchaseOrderProjectTriggerHandler.createIt(Trigger.old, Trigger.new);
        if(!Test.isRunningTest()) ProjectAutomaticalyClose.checkIfProjectAvailableForClosing(ProjectAutomaticalyClose.prepareSetStrings(Trigger.old, 'Project__c'));
    }
}
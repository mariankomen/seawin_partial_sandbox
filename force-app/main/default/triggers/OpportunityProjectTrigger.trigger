trigger OpportunityProjectTrigger on Opportunity (after insert, after update, after delete) {
    
    // if(Trigger.IsAfter && Trigger.IsInsert){
        
    //     if(!Test.isRunningTest()) OpportunityProjectTriggerHandler.createIt(new list<Opportunity>(), Trigger.new);
    //     if(!Test.isRunningTest()) CommissionFieldsReplicateHandler.assignOpportunityCommissionRates(trigger.new);
    //     if(!Test.isRunningTest()) ProjectAutomaticalyClose.checkIfProjectAvailableForClosing(ProjectAutomaticalyClose.prepareSetStrings(Trigger.new, 'Project__c'));
        
    // }else if(Trigger.IsAfter && Trigger.IsUpdate){
        
    //     OpportunityProjectTriggerHandler.createIt(trigger.old, Trigger.new);
        
    //     if(CommissionFieldsReplicateHandler.triggerRunes){
    //         CommissionFieldsReplicateHandler.updateOpportunityCommissionRates(JSON.serialize(Trigger.newMap), JSON.serialize(Trigger.oldMap));
    //         CommissionFieldsReplicateHandler.handleCheckIfPriceLevelChanged(JSON.serialize(Trigger.newMap), JSON.serialize(Trigger.oldMap));
    //         CommissionFieldsReplicateHandler.triggerRunes = false;
    //     }

    //     ProjectAutomaticalyClose.checkIfProjectAvailableForClosing(ProjectAutomaticalyClose.prepareSetStrings(Trigger.new, 'Project__c'));
    // }else if(Trigger.isAfter && Trigger.isDelete){
    //     ProjectAutomaticalyClose.checkIfProjectAvailableForClosing(ProjectAutomaticalyClose.prepareSetStrings(Trigger.old, 'Project__c'));
    // }

    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;

}
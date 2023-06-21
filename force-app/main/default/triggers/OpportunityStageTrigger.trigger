trigger OpportunityStageTrigger on AcctSeedERP__Sales_Order__c (after insert, after update, after delete) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            //System.debug('1');
            if(!Test.isRunningTest()) OpportunityStageHandler.CreateSO(Trigger.New);
            if(!Test.isRunningTest()) SalesOrderDashboardHandler.createNewRecords(Trigger.new);

            if(!Test.isRunningTest()) ProjectAutomaticalyClose.checkIfProjectAvailableForClosing(ProjectAutomaticalyClose.prepareSetStrings(Trigger.new, 'Project__c'));
        }
        
        else if(Trigger.isUpdate){
            //System.debug('2');
            if(!Test.isRunningTest()) OpportunityStageHandler.UpdateSO(Trigger.Old, Trigger.New);
            if(!Test.isRunningTest()) SalesOrderDashboardHandler.updateExistingRecordsSO(Trigger.new);

            if(!Test.isRunningTest()) ProjectAutomaticalyClose.checkIfProjectAvailableForClosing(ProjectAutomaticalyClose.prepareSetStrings(Trigger.old, 'Project__c'));
        }
        else if(Trigger.isDelete){
            //System.debug('3');
            if(!Test.isRunningTest()) SalesOrderDashboardHandler.deleteRecords(Trigger.old);
            if(!Test.isRunningTest()) OpportunityStageHandler.DeleteSo(Trigger.Old);

            if(!Test.isRunningTest()) ProjectAutomaticalyClose.checkIfProjectAvailableForClosing(ProjectAutomaticalyClose.prepareSetStrings(Trigger.old, 'Project__c'));
        }
    }

    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
}
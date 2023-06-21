trigger CommissionFieldsReplicateTrigger on AcctSeedERP__Sales_Order__c (after insert, after update) {

    if(Trigger.isAfter && Trigger.isInsert){

        CommissionFieldsReplicateHandler.assignSalesOrderCommissionRates(trigger.new);
        //AllowOppSharingHandler.handleSalesOrderCreate(Trigger.new);

    }else if(Trigger.isAfter && Trigger.isUpdate){

        if(CommissionFieldsReplicateHandler.isSOCommissionRateTriggerRun == false){
            CommissionFieldsReplicateHandler.updateSalesOrderCommissionRates(JSON.serialize(Trigger.newMap), JSON.serialize(Trigger.oldMap));
            CommissionFieldsReplicateHandler.handleCheckIfSalesOrderPriceLevelChanged(JSON.serialize(Trigger.newMap), JSON.serialize(Trigger.oldMap));

            CommissionFieldsReplicateHandler.isSOCommissionRateTriggerRun = true;
        }
        
        //AllowOppSharingHandler.handleSalesOrderChange(Trigger.new, Trigger.old);
    }
}
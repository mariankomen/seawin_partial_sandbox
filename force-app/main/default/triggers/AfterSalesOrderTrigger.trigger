trigger AfterSalesOrderTrigger on AcctSeedERP__Sales_Order__c (after insert) {

    if(Trigger.isAfter && Trigger.isInsert){
        
        AfterSalesOrderTriggerHandler.LinkBillings(Trigger.new);
        AfterSalesOrderTriggerHandler.UpdateRelatedBilling(Trigger.new);
        AfterSalesOrderTriggerHandler.checkInsertedSalesOrders(Trigger.new);
        
        //Since we have set SO as private in the Sharing Settings, then on create of SO, we need to create sharing access 
        //specific to the Sales Rep team members of this SO. So that all members should have edit permissions
        
        //AfterSalesOrderTriggerHandler.SalesRepTeamAccessibility(Trigger.New);
     	AttachExistingCaseHandler.PrePorcessing(Trigger.new);
    }
    
}
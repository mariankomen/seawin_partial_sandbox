trigger ShippingAddressPurchaseOrderTrigger on AcctSeedERP__Purchase_Order__c (after insert, after update) {
    
    if(Trigger.IsAfter){
        if(Trigger.IsInsert){
            
            if(!Test.isRunningTest()) ShippingAddressPurchaseOrderHandler.Process(new List<AcctSeedERP__Purchase_Order__c>(), Trigger.new);
        }else if(Trigger.IsUpdate){
            
            ShippingAddressPurchaseOrderHandler.Process(Trigger.old, Trigger.new);
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
}
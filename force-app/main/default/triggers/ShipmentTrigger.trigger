trigger ShipmentTrigger on AcctSeedERP__Shipment__c (before insert) {

    if(Trigger.IsBefore && Trigger.IsInsert){
        
        ShipmentHandler.createIt(Trigger.new);
    }
}
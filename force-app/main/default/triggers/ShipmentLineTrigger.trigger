trigger ShipmentLineTrigger on AcctSeedERP__Shipment_Line__c (after update) {

    if(Trigger.isUpdate && Trigger.IsAfter){
        
        ShipmentLineUpdateHandler.UpdateIt(Trigger.old, Trigger.new);
        
    }
}
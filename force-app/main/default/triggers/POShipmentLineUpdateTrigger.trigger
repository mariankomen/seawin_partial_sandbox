trigger POShipmentLineUpdateTrigger on PO_Shipment_Line__c (after update) {

    if(Trigger.IsUpdate && Trigger.IsAfter){
        
        POShipmentLineUpdateHandler.UpdateIt(Trigger.old, Trigger.new);
    }
}
trigger POShipmentCreateTrigger on AcctSeedERP__Shipment_Line__c (after insert) {
    
    If(Trigger.IsInsert && Trigger.IsAfter){
        
        //POShipmentCreateHandler.CreateShipment(Trigger.new);
        
    }

}
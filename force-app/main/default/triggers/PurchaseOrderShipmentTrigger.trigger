trigger PurchaseOrderShipmentTrigger on AcctSeedERP__Purchase_Order_Inventory_Movement__c (after insert) {
    
    if(Trigger.IsAfter && Trigger.IsInsert){
        
        // PurchaseOrderShipmentHandler.CreateShipment(trigger.new);
        PurchaseOrderShipmentHandler.createPurchaseOrderShipment(trigger.new);
    }

}
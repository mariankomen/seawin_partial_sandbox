public class ShipmentUpdateHandler {
    public static void UpdateIt(List<AcctseedERP__Shipment__c> oldData, list<Acctseederp__shipment__c> newData){
        
        map<id, AcctSeedERP__Shipment__c> shipmentMap = new map<id, AcctSeedERP__Shipment__c>();
        
        integer i = 0;
        for(AcctseedERP__Shipment__c s : newData){
            
            if(s.Carrier__c != oldData[i].carrier__c || 
               s.AcctSeedERP__Shipping_Comment__c != oldData[i].AcctSeedERP__Shipping_Comment__c ||
               s.AcctSeedERP__Shipment_Date__c != oldData[i].AcctSeedERP__Shipment_Date__c ||
               s.AcctSeedERP__Packing_Slip_Format__c != oldData[i].AcctSeedERP__Packing_Slip_Format__c ||  
               s.Project__c != oldData[i].Project__c ||
               s.AcctSeedERP__Shipping_Reference__c != oldData[i].AcctSeedERP__Shipping_Reference__c ||  
               s.AcctSeedERP__Status__c != oldData[i].AcctSeedERP__Status__c ||
               s.tracking_number__c != oldData[i].tracking_number__c){

                   shipmentMap.put(s.id, s);
               }
            i++;
        }
        
        if(shipmentMap.size() > 0){
            
            list<PO_Shipment__c> poShipments = [SELECT Name, Id, Purchase_Order__c, Carrier__c, Comment__c, Contact__c, 
                                                Date__c, GL_Account_Variable_1__c, Packing_Slip_Format__c, Project__c, 
                                                Reference__c, Sales_Order__c, Status__c, Tracking_Number__c, Shipment_ETA__c, 
                                                Shipment__c FROM PO_Shipment__c where shipment__c in:shipmentMap.keyset()];
            
            if(!poShipments.isEmpty()){
                for(Po_Shipment__c shp : poShipments){
                    
                    AcctSeedERP__Shipment__c shipment = shipmentMap.get(shp.shipment__c);
                    
                    if(shipment == null) continue;
                    
                    shp.Carrier__c = shipment.Carrier__c;
                    shp.Comment__c = shipment.AcctSeedERP__Shipping_Comment__c;
                    // shp.Contact__c =
                    shp.Date__c = shipment.AcctSeedERP__Shipment_Date__c;
                    //shp.GL_Account_Variable_1__c = shipment.GL_Account_Variable_1__c;
                    shp.Packing_Slip_Format__c = shipment.AcctSeedERP__Packing_Slip_Format__c;
                    shp.Project__c = shipment.Project__c;
                    shp.Reference__c = shipment.AcctSeedERP__Shipping_Reference__c;
                    //shp.Shipment_ETA__c =
                    shp.Status__c = shipment.AcctSeedERP__Status__c;
                    shp.Tracking_Number__c = shipment.tracking_number__c;
                }
                
                update poShipments;
            }
        }
    }
}
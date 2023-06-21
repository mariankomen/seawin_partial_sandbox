public class POShipmentLineUpdateHandler {
    public static void UpdateIt(List<PO_Shipment_Line__c> oldData, List<PO_Shipment_Line__c> newData){
        
        map<id, PO_Shipment_Line__c> POshipmentLineMap = new map<id, PO_Shipment_Line__c>();
        
        integer i = 0;
        for(PO_Shipment_Line__c sl : newData){
            
            if(sl.Quantity_Shipped__c != oldData[i].Quantity_Shipped__c){
                
                POshipmentLineMap.put(sl.Sales_Order_Line__c, sl);
            }
            i++;
        }
        
        if(POshipmentLineMap.size() > 0){
            
            list<AcctseedERP__Shipment_Line__c> ShipmentLines = [SELECT Id, AcctSeedErP__Quantity_Shipped__c, 
                                                                 AcctseedErP__Sales_Order_Line__c FROM 
                                                     AcctseedERP__Shipment_Line__c where AcctseedErP__Sales_Order_Line__c 
                                                                   in:POshipmentLineMap.keyset()];
            
            if(!ShipmentLines.isEmpty()){
                for(AcctseedERP__Shipment_Line__c shpl : ShipmentLines){
                    
                    PO_Shipment_Line__c shipmentLine = POshipmentLineMap.get(shpl.AcctseedErP__Sales_Order_Line__c);
                    
                    if(shipmentLine == null) continue;
                    
                    shpl.AcctSeedErP__Quantity_Shipped__c = shipmentLine.Quantity_Shipped__c;
                }
                
                update ShipmentLines;
            }
        }
        
    }

}
public class ShipmentLineUpdateHandler {
    
    public static void UpdateIt(List<AcctseedErP__Shipment_Line__c> oldData, List<AcctseedERP__Shipment_Line__c> newData){
        
        map<id, AcctSeedERP__Shipment_Line__c> shipmentLineMap = new map<id, AcctSeedERP__Shipment_Line__c>();
        
        integer i = 0;
        for(AcctseedERP__Shipment_Line__c sl : newData){
            
            if(sl.Acctseederp__Quantity_Shipped__c != oldData[i].Acctseederp__Quantity_Shipped__c){
                
                shipmentLineMap.put(sl.AcctseedErP__Sales_Order_Line__c, sl);
            }
            i++;
        }
        
        if(shipmentLineMap.size() > 0){
            
            list<PO_Shipment_Line__c> poShipmentLines = [SELECT Id, Quantity_Shipped__c, Sales_Order_Line__c FROM 
                                                     PO_Shipment_Line__c where Sales_Order_Line__c in:shipmentLineMap.keyset()];
            
            if(!poShipmentLines.isEmpty()){
                for(Po_Shipment_Line__c shpl : poShipmentLines){
                    
                    AcctSeedERP__Shipment_Line__c shipmentLine = shipmentLineMap.get(shpl.Sales_Order_Line__c);
                    
                    if(shipmentLine == null) continue;
                    
                    shpl.Quantity_Shipped__c = shipmentLine.AcctSeederp__Quantity_Shipped__c;
                }
                
                update poShipmentLines;
            }
        }
        
    }
    
}
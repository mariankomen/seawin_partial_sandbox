public class POShipmentCreateHandler {
    
    public static void CreateShipment(List<AcctSeedERP__Shipment_Line__c> data){
        
        
        map<id, AcctSeedERP__Shipment_Line__c> TriggerMap = new map<id, AcctSeedERP__Shipment_Line__c>(data);
        map<id, PO_Shipment__c> poShipmentMap = new map<id, Po_Shipment__c>();
        
        List<AcctSeedERP__Shipment_Line__c> SOQLLines = [select id, name, AcctSeedERP__Shipment__r.Carrier__c,
                                                         AcctSeedERP__Shipment__r.AcctSeedERP__Shipping_Comment__c,
                                                         AcctSeedERP__Shipment__r.AcctSeedERP__Shipment_Date__c,
                                                         AcctSeedERP__Shipment__r.AcctSeedERP__Sales_Order__r.GL_Account_Variable_1__c,
                                                         AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__r.AcctSeedERP__Type__c,
                                                         AcctSeedERP__Shipment__r.AcctSeedERP__Packing_Slip_Format__c,
                                                         AcctSeedERP__Shipment__r.Project__c,
                                                         AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__c,
                                                         AcctSeedERP__Shipment__r.AcctSeedERP__Shipping_Reference__c,
                                                         AcctSeedERP__Shipment__r.AcctSeedERP__Sales_Order__c,
                                                         AcctSeedERP__Shipment__r.AcctSeedERP__Status__c,
                                                         AcctSeedERP__Shipment__r.Tracking_Number__c,
                                                         AcctSeedERP__Sales_Order__c,
                                                         AcctSeedERP__Shipment__c,
                                                         AcctSeedERP__Sales_Order_Line__c,
                                                         AcctSeedERP__Quantity_Shipped__c,
                                                         AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__c,
                                                         AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__c from 
                                                         AcctSeedERP__Shipment_Line__c where
                                                         id in:TriggerMap.keyset() and 
                                                         AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__c != null
                                                        ];
        
        
        if(!soqlLines.isEmpty()){
            map<id, id> UniqueIds = new map<id, id>();
            list<PO_Shipment__c> POShipments = new list<PO_Shipment__c>();
            
            for(AcctSeedERP__Shipment_Line__c line : SOQLLines){
                
                if(Line.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__c != null){
                    
                    if(Line.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__r.AcctSeedERP__Type__c 
                       == 'Drop Shipment'){
                           
                           if(UniqueIds.containskey(line.AcctSeedERP__Shipment__c)){
                               
                           }else{
                               UniqueIds.put(line.AcctSeedERP__Shipment__c, line.AcctSeedERP__Shipment__c);
                               
                               PO_Shipment__c shipment = new PO_Shipment__c();
                               
                               shipment.Carrier__c = Line.AcctSeedERP__Shipment__r.Carrier__c;
                               shipment.Comment__c = Line.AcctSeedERP__Shipment__r.AcctSeedERP__Shipping_Comment__c;
                               shipment.Date__c = Line.AcctSeedERP__Shipment__r.AcctSeedERP__Shipment_Date__c;
                               shipment.GL_Account_Variable_1__c = Line.AcctSeedERP__Shipment__r.AcctSeedERP__Sales_Order__r.GL_Account_Variable_1__c;
                               shipment.Packing_Slip_Format__c = Line.AcctSeedERP__Shipment__r.AcctSeedERP__Packing_Slip_Format__c;
                               shipment.Project__c = Line.AcctSeedERP__Shipment__r.Project__c;
                               shipment.Purchase_Order__c = 
                                   Line.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__c;
                               shipment.Reference__c = Line.AcctSeedERP__Shipment__r.AcctSeedERP__Shipping_Reference__c;
                               shipment.Sales_Order__c = Line.AcctSeedERP__Shipment__r.AcctSeedERP__Sales_Order__c;
                               shipment.Status__c = Line.AcctSeedERP__Shipment__r.AcctSeedERP__Status__c;
                               shipment.Tracking_Number__c = Line.AcctSeedERP__Shipment__r.Tracking_Number__c;
                               shipment.Shipment__c = Line.AcctSeedERP__Shipment__c;
                               
                               POShipments.add(shipment);
                           }
                       }
                }
            }
            if(!POShipments.isEmpty()){
                
                insert POShipments;
                for(Po_Shipment__c shpmt : POShipments){
                    
                    poShipmentMap.put(shpmt.shipment__c, shpmt);     
                    
                }
            }
        }
        
        if(poShipmentMap.size() > 0){
            
            list<Po_Shipment_Line__c> POShipmentLines = new list<Po_Shipment_Line__c>();
            
            // Create PO Shipment Lines
            for(AcctSeedERP__Shipment_Line__c l : SOQLLines){
                
                PO_Shipment__c shpt = POShipmentMap.get(l.AcctseedErP__Shipment__c);
                
                if(shpt == null) continue;
                
                Po_Shipment_Line__c Lins = new Po_Shipment_Line__c();
                
                Lins.Sales_Order__c = l.AcctSeedERP__Sales_Order__c;
                Lins.Sales_Order_Line__c = l.AcctSeedERP__Sales_Order_Line__c;
                Lins.Quantity_Shipped__c = l.AcctSeedERP__Quantity_Shipped__c;
                Lins.Purchase_Order__c = 
                    l.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__c;
                Lins.Purchase_Order_Line__c = 
                    l.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__c;
                Lins.Product__c = l.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__c;
                Lins.PO_Shipment__c = shpt.id;
                
                POShipmentLines.add(Lins);
            }
            
            insert POShipmentLines;
        }
        
        // update the Sales order shipment
        list<AcctSeedERP__Shipment__c> Updatables = [select id, Purchase_Order_Shipment__c from AcctSeedERP__Shipment__c
                                                     where id in:POShipmentMap.keyset()];
        
        if(!Updatables.isEmpty()){
            
            for(AcctSeedERP__Shipment__c updt : updatables){
                
                Po_Shipment__c shpmnt = POShipmentMap.get(updt.id);
                
                if(shpmnt == null) continue;
                
                updt.Purchase_Order_Shipment__c = shpmnt.id;
                
                
            }
            
            if(!updatables.isEmpty()){
                
                update updatables;
                
            }
        }
    }
}
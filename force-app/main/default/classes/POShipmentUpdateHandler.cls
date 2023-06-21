public class POShipmentUpdateHandler {
    public static void UpdateIt(List<PO_Shipment__c> oldData, list<PO_Shipment__c> newData){

        map<id, PO_Shipment__c> POShipmentMap = new map<id, PO_Shipment__c>();
        map<id, PO_Shipment__c> POShipmentIdMap = new map<id, PO_Shipment__c>();
        map<id, PO_Shipment__c> AnotherMethodMap = new map<id, PO_Shipment__c>();
        
        integer i = 0;
        for(PO_Shipment__c s : newData){
            if(s.Sales_Order__c != null && s.shipment__c == null){
                // PO Shipment from the new PO shipment button on Po shipment list on PO
                AnotherMethodMap.put(s.Sales_Order__c, s);
            }else if(!oldData.isEmpty()){ 
                if(s.Carrier__c != oldData[i].carrier__c || 
                   s.Comment__c != oldData[i].Comment__c ||
                   s.Date__c != oldData[i].Date__c ||
                   s.Packing_Slip_Format__c != oldData[i].Packing_Slip_Format__c ||  
                   s.Project__c != oldData[i].Project__c ||
                   s.Reference__c != oldData[i].Reference__c ||  
                   s.Status__c != oldData[i].Status__c ||
                   s.tracking_number__c != oldData[i].tracking_number__c){
                       
                       POShipmentMap.put(s.id, s);
                       POShipmentIdMap.put(s.Shipment__c, s);
                   }
            }
            i++;
        }
        
        if(POShipmentMap.size() > 0){
            
            list<AcctSeedERP__Shipment__c> Shipments = [SELECT Id, Name, AcctSeedERP__Sales_Order__c, 
                                                        AcctSeedERP__Carrier__c, AcctSeedERP__Packing_Slip_Format__c, 
                                                        AcctSeedERP__Shipment_Date__c, AcctSeedERP__Shipping_Comment__c, 
                                                        AcctSeedERP__Shipping_Reference__c, AcctSeedERP__Status__c, 
                                                        tracking_number__c, Project__c, GL_Account_Variable_1__c, 
                                                        Carrier__c, Total_Quantity_Shipped__c, Purchase_Order_Shipment__c 
                                                        FROM AcctSeedERP__Shipment__c where 
                                                        Purchase_Order_Shipment__c in:POShipmentMap.keyset() OR 
                                                       Id in:POShipmentIdMap.keyset()];
            
            if(!Shipments.isEmpty()){
                for(AcctSeedERP__Shipment__c shp : Shipments){
                    
                    PO_Shipment__c shipment = null; 
                        
                    shipment = POShipmentMap.get(shp.Purchase_Order_Shipment__c);
                    
                    if(shipment == null){shipment = POShipmentIdMap.get(shp.id);}
                    
                    if(shipment == null) continue;
                    
                    shp.Carrier__c = shipment.Carrier__c;
                    shp.AcctSeedERP__Shipping_Comment__c = shipment.Comment__c;
                    // shp.Contact__c =
                    shp.AcctSeedERP__Shipment_Date__c = shipment.Date__c;
                    //shp.GL_Account_Variable_1__c = shipment.GL_Account_Variable_1__c;
                    shp.AcctSeedERP__Packing_Slip_Format__c = shipment.Packing_Slip_Format__c;
                    shp.Project__c = shipment.Project__c;
                    shp.AcctSeedERP__Shipping_Reference__c = shipment.Reference__c;
                    //shp.Shipment_ETA__c =
                    shp.AcctSeedERP__Status__c = shipment.Status__c;
                    shp.Tracking_Number__c = shipment.tracking_number__c;
                }
                update Shipments;
            }
        }
        
        if(AnotherMethodMap.size() > 0){
            
            UpdatePOShipmentAndCreateLines(json.serialize(AnotherMethodMap));
        }
    }
    
    @future
    public static void UpdatePOShipmentAndCreateLines(String POShipmentDatas){
        
        map<id, PO_Shipment__c> POShipmentData = (map<id, PO_Shipment__c>)
            JSON.deserialize(POShipmentDatas, map<id, PO_Shipment__c>.class);
        
        // pick the latest shipment for each sales order
        list<AcctSeedERP__Shipment__c> Shipments = [SELECT Id, Name,AcctSeedERP__Sales_Order__c, 
                                                    AcctSeedERP__Carrier__c, AcctSeedERP__Packing_Slip_Format__c, 
                                                    AcctSeedERP__Shipment_Date__c, AcctSeedERP__Shipping_Comment__c, 
                                                    AcctSeedERP__Shipping_Reference__c, AcctSeedERP__Status__c, 
                                                    tracking_number__c, Project__c, GL_Account_Variable_1__c, 
                                                    Carrier__c, Total_Quantity_Shipped__c, Purchase_Order_Shipment__c 
                                                    FROM AcctSeedERP__Shipment__c where 
                                                    AcctSeedERP__Sales_Order__c in:POShipmentData.keyset() 
                                                    order by createddate desc
                                                    limit 1];
        
        map<id, AcctSeedERP__Shipment__c> shipmentMap = new map<id, AcctSeedERP__Shipment__c>(shipments);
        
        List<AcctseedERP__Shipment_Line__c> shipmentLines = [SELECT Id, Name, AcctSeedERP__Shipment__c, 
                                                             AcctSeedERP__Sales_Order_Line__c, 
                                                             AcctSeedERP__Product__c, 
                                                             AcctSeedERP__Quantity_Shipped__c, 
                                                             AcctSeedERP__Sales_Order__c, 
                                                             AcctSeedERP__Serialized__c,
                                                             AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__c,
                                                             AcctSeedERP__Sales_Order_Line__r.AcctSeedErP__Product__c,
                                                             AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__c,
                                                             Quantity_Shipped__c FROM AcctSeedERP__Shipment_Line__c 
                                                             where AcctseedERP__Shipment__c 
                                                             in:shipmentMap.keyset()];
        
        if(!shipments.isEmpty()){
            
            for(AcctSeedERP__Shipment__c shp : shipments){
                
                PO_Shipment__c shpmt = POShipmentData.get(shp.AcctSeedERP__Sales_Order__c);
                
                shpmt.Carrier__c = shp.Carrier__c;
                shpmt.Comment__c = shp.AcctSeedERP__Shipping_Comment__c;
                // shp.Contact__c =
                shpmt.Date__c = shp.AcctSeedERP__Shipment_Date__c;
                //shp.GL_Account_Variable_1__c = shipment.GL_Account_Variable_1__c;
                shpmt.Packing_Slip_Format__c = shp.AcctSeedERP__Packing_Slip_Format__c;
                shpmt.Project__c = shp.Project__c;
                shpmt.Reference__c = shp.AcctSeedERP__Shipping_Reference__c;
                //shp.Shipment_ETA__c =
                shpmt.Status__c = shp.AcctSeedERP__Status__c;
                shpmt.Tracking_Number__c = shp.tracking_number__c;
                shpmt.Shipment__c = shp.id;
                
                POShipmentData.put(shp.AcctSeedERP__Sales_Order__c, shpmt);
                
            }
            
            if(POShipmentData.size() > 0){
                
                update POShipmentData.values();
                
                if(!shipmentLines.isEmpty()){
                    
                    set<id> PoShipmentIds = new set<id>();
                    
                    List<Po_shipment_Line__c> polns = new List<Po_shipment_Line__c>();
                    
                    for(AcctSeedERP__Shipment_Line__c ln : shipmentLines){
                        
                        if(ln.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__c != null){
                            
                            PO_Shipment__c shipmnt = POShipmentData.get(ln.AcctSeedERP__Sales_Order__c);
                            
                            if(ln.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.Acctseederp__purchase_order__c
                               == shipmnt.Purchase_Order__c){
                                   
                                   
                                   
                                   if(shipmnt == null) continue;
                                   
                                   PoShipmentIds.add(shipmnt.id);
                                   
                                   Po_Shipment_Line__c poln = new Po_shipment_Line__c();
                                   
                                   poln.PO_Shipment__c = shipmnt.id;
                                   poln.Product__c = ln.AcctSeedERP__Sales_Order_Line__r.AcctSeedErP__Product__c;
                                   poln.Purchase_Order__c = shipmnt.Purchase_Order__c;
                                   poln.Purchase_Order_Line__c = ln.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__c;
                                   poln.Quantity_Shipped__c = ln.AcctSeedERP__Quantity_Shipped__c;
                                   poln.Sales_Order__c = ln.AcctSeedERP__Sales_Order__c;
                                   poln.Sales_Order_Line__c = ln.AcctSeedERP__Sales_Order_Line__c;
                                   
                                   polns.add(poln);
                               }
                        }
                    }
                    
                    if(!polns.isEmpty()){
                        
                        delete [select id from po_shipment_line__c where PO_Shipment__c in:PoShipmentIds];
                        
                        insert polns;
                    }
                }
            }       
        }
    }
}
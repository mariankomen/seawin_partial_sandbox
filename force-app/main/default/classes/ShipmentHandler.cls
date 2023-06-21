public class ShipmentHandler {
    
    public static void createIt(list<AcctSeedERP__Shipment__c> data){
        
        set<id> soIds = new set<id>();
        map<id, AcctseedERP__Shipment__c> sIdAndShipmentMap = new map<id, AcctseedERP__Shipment__c>();
        
        for(AcctSeedERP__Shipment__c shipment : data){
            if(shipment.AcctSeedERP__Sales_Order__c != null){
                
                soIds.add(shipment.AcctSeedERP__Sales_Order__c);
                sIdAndShipmentMap.put(shipment.AcctSeedERP__Sales_Order__c, shipment);
                
            }
        }
        
        if(sIdAndShipmentMap.size() > 0){
            
            // get so with project
            // loop on so, get the shipment and assign the project
            // update shipments
            
            
            list<AcctSeedERP__Sales_Order__c> orders = [select id, project__c from AcctseedERP__Sales_Order__c
                                                       where id in:soIds];
            
            if(!orders.IsEmpty()){
                
                for(AcctSeedERP__Sales_Order__c so:orders){
                    
                    AcctSeedERP__Shipment__c shipping = sIdAndShipmentMap.get(so.id);
                    
                    if(shipping == null) continue;
                    
                    shipping.Project__c = so.Project__c;
                    
                }
            }
        }
    }
}
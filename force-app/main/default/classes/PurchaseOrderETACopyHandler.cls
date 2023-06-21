public class PurchaseOrderETACopyHandler {
    
    public static void UpdateFields(List<AcctSeedERP__Purchase_Order_Line__c> plines){
        /*
        set<id> lineIds = new set<id>(); // to get the sales order lines
        map<id, id> lineorderMap = new map<id, id>(); // to create a map between purchase order and sales order
        set<id> orderIds = new set<id>(); // to get purchase orders
        
        for(AcctSeedERP__Purchase_Order_Line__c pline : plines){
            
            lineIds.add(pline.id);
            orderIds.add(pline.AcctSeedERP__Purchase_Order__c);
            lineorderMap.put(pline.id, pline.AcctSeedERP__Purchase_Order__c);
            
        }
        if(!lineIds.IsEmpty()){
        	FinallyUpdate(JSON.serialize(lineorderMap), lineIds, orderIds);
        }
		*/
    }
    /*
    @future
    public static void FinallyUpdate(String lineorderString, Set<id> lineIds, set<id> orderIds){
        
        if(!lineIds.IsEmpty()){
            
            map<id, id> lineorderMap = (map<id, id>)json.deserialize(lineorderString, map<id, id>.class);
			
            // get the sales order lines
            // create a map between purchase order and sales order
            
            map<id, id> ordersorderMap = new map<id, id>();
            set<id> sorderIds = new set<id>();
            
            for(AcctSeedERP__Sales_Order_Line__c sline : [select id, AcctSeedERP_Description__c, AcctSeedERP__Sales_Order__c, AcctSeedERP__Sales_Order__r.Customer_s_eta__c, AcctSeedERP__Purchase_Order_Line__c from AcctSeedERP__Sales_Order_Line__c where AcctSeedERP__Purchase_Order_Line__c in:lineIds]){
                
                sorderIds.add(sline.AcctSeedERP__Sales_Order__c);
                
                Id purchaseOrderId = lineorderMap.get(sline.AcctSeedERP__Purchase_Order_Line__c);
                if(purchaseOrderId == null) continue;
                ordersorderMap.put(purchaseOrderId, sline.AcctSeedERP__Sales_Order__c);
            }
            
            system.debug('Pre Purchase Order/Sales Order Map value: ' + ordersorderMap);

            map<id, AcctSeedERP__Sales_Order__c> sorderMap = new map<id, AcctSeedERP__Sales_Order__c>();
            
            for(AcctSeedERP__Sales_Order__c so : [select id, Customer_s_eta__c from AcctSeedERP__Sales_Order__c where id in:sorderIds]){
                
                sorderMap.put(so.id, so);
                
            }
            
            // get purchase orders to update
            
            List<AcctSeedERP__Purchase_Order__c> porders = [select id, Customer_s_eta__c from AcctSeedERP__Purchase_Order__c where id in:orderIds];
            
            for(AcctSeedERP__Purchase_Order__c poc : porders){
                
                Id salesid = ordersorderMap.get(poc.id);
                
                AcctSeedERP__Sales_Order__c saleso = sorderMap.get(salesid);
                
                if(saleso == null) continue;
                poc.Customer_s_ETA__c = saleso.Customer_s_eta__c;
            }
            
            update porders;
        }
    }
    */
}
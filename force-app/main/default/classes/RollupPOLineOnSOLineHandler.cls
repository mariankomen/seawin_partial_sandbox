public class RollupPOLineOnSOLineHandler {
    
    public static void rollup(List<AcctSeedERP__Purchase_Order_Line__c> data, TriggerOperation typ, Boolean isHelper){
        
        // get the parent ids
        set<id> poIds = new set<id>();
        
        for(AcctSeedERP__Purchase_Order_Line__c poline : data){
            
            poIds.add(poline.AcctSeedERP__Purchase_Order__c);
            
        }
        
        map<id, id> poWithSOMap = new map<id, id>(); // po key, so value
        
        if(isHelper){
            
            for(AcctSeedERP__Purchase_Order__c po : [select id, sales_order__c from AcctSeedERP__Purchase_Order__c
                                                     where id in:poIds and isdeleted = true ALL ROWS]){
                                                         
                                                         poWithSOMap.put(po.id, po.Sales_Order__c);
                                                         
                                                     }
        }else{
            
            for(AcctSeedERP__Purchase_Order__c po : [select id, sales_order__c from AcctSeedERP__Purchase_Order__c
                                                     where id in:poIds]){
                                                         
                                                         poWithSOMap.put(po.id, po.Sales_Order__c);
                                                         
                                                     }
            
        }
        
        set<id> solId = new set<id>();
        for(AcctSeedERP__Purchase_Order_Line__c pol : data){
            
            Id soHasId = poWithSOMap.get(pol.AcctSeedERP__Purchase_Order__c);
            
            if(pol.Sales_Order_Line__c != null && soHasId != null ){
                solId.add(pol.Sales_Order_Line__c); 
            }  
        }
        
        // solid would have on sales order line id
        
        if(!solId.isEmpty()){
            // get the po lines for this sol
            
            AggregateResult[] POLQuantitiesWithSOLid = [select sales_order_line__c sid, SUM(quantity_formula__c) from
                                                        AcctSeedERP__Purchase_Order_Line__c where
                                                        sales_order_line__c in:solId
                                                        and isdeleted = false group by sales_order_line__c];
            
            system.debug(POLQuantitiesWithSOLid);
            
            map<id, Decimal> SOLidAndQuantityMap = new map<id, Decimal>();
            set<id> newSoid = new set<id>();
            
            if(POLQuantitiesWithSOLid.size() > 0){
                
                for(AggregateResult ar : POLQuantitiesWithSOLid){
                    
                    SOLidAndQuantityMap.put((Id)ar.get('sid'), (Double)ar.get('expr0'));
                    newSoid.add((Id)ar.get('sid'));
                    
                }
                
                FillQuantity(SOLidAndQuantityMap, POLQuantitiesWithSOLid, newSoid);
            }else{
                
                FillQuantity(SOLidAndQuantityMap, POLQuantitiesWithSOLid, solId);
            }
        }
    }
    public static void FillQuantity(map<id, Decimal> SOLidAndQuantityMap, 
                                    AggregateResult[] POLQuantitiesWithSOLid,set<id> newSoid){
        
        // get the soline and update the POL quantity on this.poline's soline
        
        list<AcctSeedERP__Sales_Order_Line__c> lines = [select id, POL_Quantity__c
                                                        from AcctSeedERP__Sales_Order_Line__c
                                                        where id =:newSoid and isdeleted = false];
        
        if(!lines.isEmpty()){
            
            for(AcctSeedERP__Sales_Order_Line__c line : lines){
                
                Decimal quantity = (POLQuantitiesWithSOLid.size() > 0) ? 
                    SOLidAndQuantityMap.get(line.id):0;
                
                if(quantity == null) continue;
                
                line.POL_Quantity__c = quantity;
                
            }
            update lines;
        }
    }
}
public class SalesOrderProjectTriggerHandler {
    
    public static void createIt(list<AcctSeedERP__Sales_Order__c> oldData, list<AcctSeedERP__Sales_Order__c> newData){
        
        // a map with SO id to Project id
        // get related opporutnity
        // get all related shipments
        // assign or remove project
        // get all related po
        // assign or remove project
        // update all
        
        map<id, id> SoIDtoProjectIDMap = new map<id,id>();
        Integer i = 0;
        map<id,id> OppIDtoProjectIDMap = new map<id, id>();
        
        for(AcctSeedERP__Sales_Order__c s : newData){
            
            if(!oldData.IsEmpty()){
                // if its an update
                if(s.Project__c != oldData[i].Project__c){
                    
                    SoIDtoProjectIDMap.put(s.id, s.Project__c);
                    if(s.AcctSeedERP__opportunity__c != null){
                        if(s.Project__c != null){
                            
                            OppIDtoProjectIDMap.put(s.AcctSeedERP__opportunity__c, s.Project__c);
                        }
                    }
                }
                
                i++;
                
            }else{
                // if its an insert
                SoIDtoProjectIDMap.put(s.id, s.Project__c);
                if(s.AcctSeedERP__opportunity__c != null){
                    
                    OppIDtoProjectIDMap.put(s.AcctSeedERP__opportunity__c, s.Project__c);
                }
            }
            
        }
        
        if(SoIDtoProjectIDMap.size() > 0){
            
            if(OppIDtoProjectIDMap.size() > 0){
                
                // get related opportunity, update only if the project has changed
                list<Opportunity> opportunities = [select id, project__c from opportunity where
                                                   id in:OppIDtoProjectIDMap.keySet()];
                
                if(!Opportunities.isEmpty()){
                    for(Opportunity o : opportunities){
                        
                        Id projectId = OppIDtoProjectIDMap.get(o.id);
                        
                        if(projectId == null){
                            o.Project__c = null;
                            o.Run_Validation_Rule__c = true;
                        }else{
                            o.Run_Validation_Rule__c = true;
                            o.Project__c = projectId;
                        }
                    }
                    
                    update opportunities;
                }
            }

            // get the related shipments
            
            list<AcctSeedERP__Shipment__c> shipments = [select id, AcctseedERP__Sales_Order__c, Project__c from
                                                        AcctSeedERP__Shipment__c where 
                                                        AcctSeedERP__Sales_Order__c in:SoIDtoProjectIDMap.keyset()];
            if(!shipments.isEmpty()){
                for(AcctSeedERP__Shipment__c shipment: shipments){
                    
                    Id projectId = SoIDtoProjectIDMap.get(shipment.AcctSeedERP__Sales_Order__c);
                    
                    if(projectId == null){
                        
                        shipment.Project__c = null;
                        
                    }else{
                        
                        shipment.Project__c = projectId;
                    }
                    
                }
                
                update shipments;
            }
            
            list<Acctseederp__purchase_order__c> purchases = [select id, Sales_order__c, project__c from
                                                              AcctSeederp__purchase_order__c where
                                                              Sales_order__c in:SoIDtoProjectIDMap.keyset()];
            
            if(!purchases.IsEmpty()){
                
                for(Acctseederp__purchase_order__c purchase: purchases){
                    
                    Id projectId = SoIDtoProjectIDMap.get(purchase.Sales_order__c);
                    
                    if(projectId == null){
                        
                        purchase.Project__c = null;
                        
                    }else{
                        
                        purchase.Project__c = projectId;
                    }
                    
                }
                
                update purchases;
                
            }
        }
    }
}
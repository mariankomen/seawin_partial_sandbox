public class PurchaseOrderProjectTriggerHandler {
    
    public static void createIt(list<AcctSeedERP__Purchase_Order__c> oldData, list<AcctSeedERP__Purchase_Order__c> newData){
       
        // a map with Po id and project id
        // get the related sales order
        // assign or remove project
        // update
        
        map<id, id> PoIDtoProjectIDMap = new map<id, id>();
        Integer i = 0;
        
        for(AcctSeedERP__Purchase_Order__c p : newData){
            if(!oldData.IsEmpty()){
                if(p.Project__c != oldData[i].Project__c){
                    
                    PoIDtoProjectIDMap.put(p.Sales_Order__c, p.Project__c);
                }
                i++;
                
            }else{
                
                PoIDtoProjectIDMap.put(p.Sales_Order__c, p.Project__c);
            }
            
        }
        
        if(PoIDtoProjectIDMap.size() > 0){
            
            // get the related so
         	list<AcctSeedERP__Sales_Order__c> orders = [select id,project__c from AcctSeedERP__Sales_Order__c
                                                       where id in:PoIDtoProjectIDMap.keyset()];
            
            if(!orders.IsEmpty()){
                
                for(AcctSeedERP__Sales_Order__c order : orders){
                    
                    Id projectId = PoIDtoProjectIDMap.get(order.id);
                    
                    if(projectId == null){
                        
                        order.Project__c = null;
                    }else{
                        
                        order.Project__c = projectId;
                    }
                }
                
                update orders;
                
            }
        }
    }
}
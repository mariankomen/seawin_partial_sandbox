public class OpportunityProjectTriggerHandler {
    
    public static void createIt(list<Opportunity> oldData, list<Opportunity> newData){
        
        // a map with opportunity id to project id
        // get all related so
        // assign/remove the project to so
        // update so
        
        map<id,id> OppIDtoProjectIDMap = new map<id, id>();
        set<id> opIds = new set<id>();
        
        Integer i = 0;
        for(Opportunity o : newData){
            if(!oldData.isEmpty()){
                // it an update call
                if(o.Project__c != oldData[i].Project__c){
                    OppIDtoProjectIDMap.put(o.id, o.project__c);  
                }
                i++;
            }else{
                // its an insert call
                    OppIDtoProjectIDMap.put(o.id, o.project__c);  
            }
        }
        
        if(OppIDtoProjectIDMap.size() > 0){
            
            // get all the related so
            list<AcctSeedERP__Sales_Order__c> orders = [select id, AcctSeedERP__Opportunity__c, Project__c from
                                                       AcctSeedERP__Sales_Order__c where
                                                       AcctSeedERP__Opportunity__c in:OppIDtoProjectIDMap.keyset()];
            
            if(!orders.IsEmpty()){
                for(AcctSeedERP__Sales_Order__c order : orders){
                	
                    Id projectId = OppIDtoProjectIDMap.get(order.AcctSeedERP__Opportunity__c);
                    
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
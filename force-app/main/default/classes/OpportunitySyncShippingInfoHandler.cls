public class OpportunitySyncShippingInfoHandler {
    
    public static void StartUpdate(list<Opportunity> od, list<opportunity> nd){
        
        map<id, set<id>> OppAndThirdPartyInfoMap = new map<id, set<id>>();
        set<id> oppIds = new set<id>();
        Integer i = 0;
        for(Opportunity o:nd){
            
            if(o.Shipping_Account__c != od[i].shipping_Account__c || 
              o.Shipping_Name__c != od[i].shipping_name__c){
                  oppIds.add(o.id);
                  OppAndThirdPartyInfoMap.put(o.id, new set<id>{o.shipping_Account__c, o.shipping_name__c});
            }
            i++;
        }
        
        if(OppAndThirdPartyInfoMap.size() > 0){
            
            // get all the quotes
            list<Quote> quotes = [select id, opportunityid, shipping_account__c, shipping_name__c from
                                 Quote where opportunityid in:oppIds];
            
            if(!quotes.IsEmpty()){
                
                for(quote q : quotes){
                    
                    set<id> values = OppAndThirdPartyInfoMap.get(q.OpportunityId);
                    
                    if(values == null) continue;
                    
                    list<id> valuesNew = new list<id>(values);
                    
                    q.Shipping_Account__c = valuesNew[0];
                    
                    if(valuesNew.size() > 1){
                    	q.Shipping_Name__c = valuesNew[1];
                    }
                    
                }
                
                update quotes;
                
            }
            
        }
        
    }

}
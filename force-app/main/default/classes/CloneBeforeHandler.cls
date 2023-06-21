public class CloneBeforeHandler {
    
    public static void Process(List<Opportunity> data){
        
        map<id, opportunity> c = new map<id, opportunity>();
     
        for(opportunity o : data){
            if(o.isClone()){
                
                c.put(o.getCloneSourceId(), o);
                
            }
        }
        
        if(c.size() > 0){
            
            List<Opportunity> ol = [select id, Sent_for_Approval__c from opportunity where id in:c.keyset()];
            
            map<id, opportunity> s = new map<id, opportunity>(ol);
            
            if(!ol.isEmpty()){
                for(opportunity o : data){
                    if(o.isClone()){
                        
                        opportunity source = s.get(o.getCloneSourceId());
                        
                        o.Sent_for_Approval__c = source.Sent_for_Approval__c;
                        o.Total_Commissions_Paid__c = 0.00;
                        o.Commissions_Total_Custom__c = 0.00;
                        o.Total_Commissions_Unpaid__c = 0.00;
                    }
                }
            }
        }
    }
}
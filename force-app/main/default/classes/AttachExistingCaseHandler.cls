public class AttachExistingCaseHandler {
    
    public static void PrePorcessing(List<AcctSeedERP__Sales_Order__c> orders){
        
        set<id> oppIds = new set<id>();
        
        for(AcctSeedERP__Sales_Order__c order : orders){
            
            if(String.IsNotBlank(order.AcctSeedERP__Opportunity__c)){
                
                oppIds.add(order.AcctSeedERP__Opportunity__c);
            }
        }
        
        if(oppIds.size() > 0){
            
            List<Case> cases = [Select Id, Opportunity__c, Sales_Order__c from
                                case where Opportunity__c in: oppIds];
            
            if(!cases.isEmpty()){
                
                AttachCases(cases, false);
                
            }
        }
    }
    public static void AttachCases(List<Case> cases, Boolean IsBefore){
        
        map<id, Case> OpportunityToCaseMap = new map<id, Case>();
        
        for(Case c : cases){
            
            if(String.IsNotBlank(c.Opportunity__c)){
                
                OpportunityToCaseMap.put(c.Opportunity__c, c);   
            }
        }
        
        if(OpportunityToCaseMap.size() > 0){
            
                List<Case> UpdateCases = new List<Case>();
            
                for(AcctSeedERP__Sales_Order__c s : [select Id, AcctseedERP__Opportunity__c from
                                                        AcctSeedERP__Sales_Order__c where
                                                        AcctseedERP__Opportunity__c in:OpportunityToCaseMap.keyset()]){
                                                            
                         Case cas = OpportunityToCaseMap.get(s.AcctseedERP__Opportunity__c);
                                                            
                         if(cas == null) continue;
                                                            
                         cas.Sales_Order__c = s.id;
                                                            
                         if(!isBefore) UpdateCases.add(cas);

                }
            
            if(!UpdateCases.isEmpty()){
                
                Database.update(UpdateCases, false);
            }
        }
    }
}
trigger CaseTrigger on Case (before update) {
    
    if(Trigger.isBefore && Trigger.IsUpdate){
        
        List<Case> Cases = new List<Case>();
        
        for(Case c : Trigger.new){
            
            if(c.Opportunity__c != 
               Trigger.OldMap.get(c.id).Opportunity__c){
                    if(String.IsNotBlank(c.Opportunity__c)){
                        
                        Cases.add(Trigger.NewMap.get(c.id));
                    }else{
                        
                        c.Sales_Order__c = null;
                    }
               }
        }
        
    	if(!Cases.isEmpty()) AttachExistingCaseHandler.AttachCases(Cases, Trigger.isBefore);    
    }
}
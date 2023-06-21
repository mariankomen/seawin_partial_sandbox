public class TaskHandler {
    
    public static void BeforeInsert(List<Task> data){
       
        for(Task t : data){
            if(t.WhatId != null)
                if(t.whatId.getSObjectType().getDescribe().getName() == 'Opportunity'){
                    
                    t.Opportunity__c = t.whatid;
                }
        }
    }
    
    public static void AfterInsert(List<Task> data){
        
        map<id, Task> taskMap = new map<id, Task>();
        
        for(Task t : data){
            if(t.WhatId != null)
                if(t.whatId.getSObjectType().getDescribe().getName() == 'Opportunity'){
                    
                    taskMap.put(t.whatId, t);
                    
                }
        }
        
        if(taskMap.size() > 0){
            
            List<Opportunity> opportunities = [select id, task__c, run_validation_rule__c from Opportunity
                                               where id in:taskMap.keyset()];
            
            if(!Opportunities.isEmpty()){
                
                for(opportunity o :Opportunities){
                    
                    o.Task__c = true;
                    o.Run_Validation_Rule__c = true;
                }
                
                try{
                    update opportunities;
                    
                }catch(Exception ex){
                    
                    for(Task t : data){
                        
                        t.WhatId.addError(ex.getDmlMessage(0));
                        
                    }
                }
                
            }
        }
    }
}
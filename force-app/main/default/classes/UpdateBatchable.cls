global class UpdateBatchable implements Database.Batchable<sObject>{
    List<sObject> dataList;
    Boolean allOrNothing;
    
    global UpdateBatchable(List<sObject> d, Boolean b){
        dataList = d;
        allOrNothing = b;
    }
    
    global List<sObject> start(Database.BatchableContext BC){
        return dataList;  
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope ){
        Database.update(scope, allOrNothing);
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}
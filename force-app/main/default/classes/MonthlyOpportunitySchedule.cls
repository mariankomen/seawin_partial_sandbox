public with sharing class MonthlyOpportunitySchedule Implements Schedulable{
    
    public void execute(SchedulableContext sc){
        MonthlyOpportunityBatch batch = new MonthlyOpportunityBatch();
        Database.executeBatch(batch, 1);    
    }
}
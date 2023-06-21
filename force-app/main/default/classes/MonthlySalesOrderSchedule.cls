public with sharing class MonthlySalesOrderSchedule Implements Schedulable{
    
    public void execute(SchedulableContext sc){
        MonthlySalesOrderBatch batch = new MonthlySalesOrderBatch();
        Database.executeBatch(batch, 1);    
    }
}
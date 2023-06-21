@isTest
public with sharing class MonthlyOpportunityScheduleTest {
    
    @isTest
    public static void monthlyOppScheduleJobTest(){
        Test.startTest();

        SchedulableContext sc = null;
        MonthlyOpportunitySchedule dlc = new MonthlyOpportunitySchedule();
        dlc.execute(sc);

        Test.stopTest();
    }
}
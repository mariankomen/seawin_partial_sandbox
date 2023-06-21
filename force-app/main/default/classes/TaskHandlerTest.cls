@isTest
public class TaskHandlerTest {
    
    @TestSetup static void MakeData(){

        AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c();
        av.Name = 'Test GL';
        av.AcctSeed__Type__c = 'GL Account Variable 1';
        insert av;
        
        Opportunity opp = new Opportunity();

        opp.StageName = 'Analysis';
        opp.CloseDate = Date.today() + 7;
        opp.name='Test Opportunity';
        opp.gl_account_variable_1__c = av.id;

        insert opp;

        Task t = new Task();

        t.Subject = 'Test Task';
        t.whatid = opp.id;
        t.OwnerId = userinfo.getUserId();

        insert t;
        
    }
    
    @isTest static void RunTest(){
        
        
    }

}
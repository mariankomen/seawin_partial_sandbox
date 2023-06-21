@isTest
public with sharing class OpportunityDashboardHandlerTest {
    
    @TestSetup
    static void makeData(){
        Sales_Rep__c sr = new Sales_Rep__c();
        
        sr.name = 'Test Team';
        sr.Email__c = 'team@test.com';
        sr.Team__c = UserInfo.getUserId();
        
        insert sr;

        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'Seawin USA';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;

        Account acct = new Account();
        acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'Test Account';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct;
        
        // create opportunity
        Opportunity opp = new Opportunity();
        
        opp.Name = 'Test Opportunity';
        opp.Sales_Rep_O__c = sr.id;
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Closed Won';
        opp.CloseDate = system.today();
        opp.GL_Account_Variable_1__c = accVar.Id;
        
        insert opp;

        opp.Name = 'test';
        update opp;
    }


    @isTest
    public static void OpportunityDashboardHandleTests(){
        String fields = MonthlyOpportunityBatch.getOpportunityFields();
        String soql = 'SELECT ' + fields + ' FROM Opportunity';
        List<Opportunity> opps = (List<Opportunity>)Database.query(soql);
        OpportunityDashboardHandler.createNewRecord(opps);
        OpportunityDashboardHandler.updateExistingRecords(opps);
        OpportunityDashboardHandler.deleteRecords(opps);
        
        delete opps[0];
    }
}
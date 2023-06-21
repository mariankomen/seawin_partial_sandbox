@isTest
public with sharing class OpportunityOwnerPageExtensionTest {
    
    @testSetup static void createData(){
        
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        Sales_Rep__c sr = new Sales_Rep__c();
        
        sr.name = 'Test Team';
        sr.Email__c = 'team@test.com';
        sr.Team__c = UserInfo.getUserId();
        
        insert sr;
        
        // create account
        Account acct = new Account();
        acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct;
        
        // create opportunity
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Closed Won';
        opp.CloseDate = system.today();
        opp.GL_Account_Variable_1__c = accVar.Id;
        
        insert opp;
    }
    
    @isTest static void StartProcess(){
      
        Opportunity opp = [select id from Opportunity where name = 'myOpportunity' limit 1];
        
        Sales_rep__c sr = [select id from Sales_rep__c where name = 'Test Team' Limit 1];
        
        test.startTest();
		        
        PageReference pageRef = Page.OpportunityRecordTypePage;
        Test.setCurrentPage(pageRef);
		
        ApexPages.currentPage().getParameters().put('retURL', opp.id);
        ApexPages.currentPage().getParameters().put('oppId', opp.id);
        
        OpportunityOwnerPageExtension obj1 = new OpportunityOwnerPageExtension();
        
        
        
        obj1.cancel();
        obj1.getSelected();
        obj1.setOptionValues();
        obj1.getAllOptionValues();
        obj1.getOptionValues();
        obj1.selected = sr.id;
        obj1.saveOverride();
        
        Test.stopTest();
         
    }

}
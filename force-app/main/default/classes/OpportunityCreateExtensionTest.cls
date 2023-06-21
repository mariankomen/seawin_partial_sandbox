@isTest
public with sharing class OpportunityCreateExtensionTest {
    
    @testSetup static void createData(){
        
        Sales_Rep__c sr = new Sales_Rep__c();
        
        sr.name = 'Test Team';
        sr.Email__c = 'team@test.com';
        sr.Team__c = UserInfo.getUserId();
        
        insert sr;
        
        
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'Test GL';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        // create account
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
    }
    
    @isTest static void StartProcess(){
      
        Sales_Rep__c sr = [Select id from Sales_Rep__c where 
        name='Test Team' Limit 1];

        Account acct = [select id from Account where name = 'Test Account' Limit 1];

        Opportunity opp = [Select id from Opportunity where name='Test Opportunity' Limit 1];

        Id recId = 
        Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
        
        AcctSeed__Accounting_Variable__c gl = [select id from 
        AcctSeed__Accounting_Variable__c where name ='Test GL' Limit 1];

        test.startTest();
		
        ApexPages.currentPage().getParameters().put('ownerid', UserInfo.getuserid());
        ApexPages.currentPage().getParameters().put('salesrepid', sr.id);
        ApexPages.currentPage().getParameters().put('acctId', acct.id);
        ApexPages.currentPage().getParameters().put('recordtypeid', recId);
        ApexPages.currentPage().getParameters().put('gl', gl.id);
        ApexPages.currentPage().getParameters().put('retURL', '/'+acct.id);

        ApexPages.StandardController std = new ApexPages.StandardController(opp);
        
        OpportunityCreateExtension oce = new OpportunityCreateExtension(std);
        
        oce.saveOverride();

        Test.stopTest();
         
    }

}
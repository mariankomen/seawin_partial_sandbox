@isTest
public with sharing class OpportunitySalesRepPageExtensionTest {
    
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
        
        Contact ct = new Contact();
        
        ct.FirstName = 'FirstName';
        ct.LastName = 'LastName';
        ct.AccountId = acct.id;
        ct.GL_Account_Variable_1__c = accVar.id;
        
        insert ct;
        
        
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
    
    @isTest static void OnlyOpportunity(){
      
        Opportunity opp = [select id,sales_rep_o__c from Opportunity where name = 'Test Opportunity' limit 1];
        
        test.startTest();
		        
        PageReference pageRef = Page.OpportunityRecordTypePage;
        Test.setCurrentPage(pageRef);
		
        ApexPages.currentPage().getParameters().put('retURL', opp.id);
        ApexPages.currentPage().getParameters().put('oppId', opp.id);
        
        OpportunitySalesRepPageExtension obj1 = new OpportunitySalesRepPageExtension();
        
        obj1.saveOverride();
        obj1.cancel();
        obj1.getSelected();
        obj1.setOptionValues();
        obj1.getAllOptionValues();

        Test.stopTest();
         
    }
    @isTest static void Account(){
      	
        Account acct = [select id,name,ownerid,sales_rep_o__c,Sales_Rep_Record_Type__c,
                                acctseed__gl_account_variable_1__r.name 
                from Account where name='Test Account' Limit 1];
        Opportunity opp = [select id,sales_rep_o__c from Opportunity where name = 'Test Opportunity' limit 1];
        
        test.startTest();
            
        Id recId = 
        Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
		
        ApexPages.currentPage().getParameters().put('retURL', '/' + acct.id);
        //ApexPages.currentPage().getParameters().put('oppId', opp.id);
        //
        ApexPages.currentPage().getParameters().put('id', acct.id);
        ApexPages.currentPage().getParameters().put('continue', '/'+opp.id);
        ApexPages.currentPage().getParameters().put('createproducts', 'yes');
        ApexPages.currentPage().getParameters().put('RecordType', recId);
        
        OpportunitySalesRepPageExtension obj1 = new OpportunitySalesRepPageExtension();
        
        obj1.saveOverride();
        obj1.cancel();
        obj1.getSelected();
        obj1.setOptionValues();
        obj1.getAllOptionValues();

        Test.stopTest();
         
    }
    @isTest static void Account2(){
      	
        Account acct = [select id,name,ownerid,sales_rep_o__c,Sales_Rep_Record_Type__c,
                                acctseed__gl_account_variable_1__r.name 
                from Account where name='Test Account' Limit 1];
        
        acct.AcctSeed__GL_Account_Variable_1__c = null;
        
        update acct;
        
        Opportunity opp = [select id,sales_rep_o__c from Opportunity where name = 'Test Opportunity' limit 1];
        
        Contact ct = [select id, name, gl_account_variable_1__r.name from contact where 
                      name = 'FirstName LastName' Limit 1];
        
        test.startTest();
            
        Id recId = 
        Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
		
        ApexPages.currentPage().getParameters().put('retURL', '/' + ct.id);
        //ApexPages.currentPage().getParameters().put('oppId', opp.id);
        //
        ApexPages.currentPage().getParameters().put('id', acct.id);
        ApexPages.currentPage().getParameters().put('continue', '/'+opp.id);
        ApexPages.currentPage().getParameters().put('createproducts', 'yes');
        ApexPages.currentPage().getParameters().put('RecordType', recId);
        
        OpportunitySalesRepPageExtension obj1 = new OpportunitySalesRepPageExtension();
        
        obj1.saveOverride();
        obj1.cancel();
        obj1.getSelected();
        obj1.setOptionValues();
        obj1.getAllOptionValues();

        Test.stopTest();
         
    }
    @isTest static void Account3(){
      	
        Account acct = [select id,name,ownerid,sales_rep_o__c,Sales_Rep_Record_Type__c,
                                acctseed__gl_account_variable_1__r.name 
                from Account where name='Test Account' Limit 1];
        
        acct.AcctSeed__GL_Account_Variable_1__c = null;
        
        update acct;
        
        Opportunity opp = [select id,sales_rep_o__c from Opportunity where name = 'Test Opportunity' limit 1];
        
        Contact ct = [select id, name, gl_account_variable_1__r.name from contact where 
                      name = 'FirstName LastName' Limit 1];
        
        ct.GL_Account_Variable_1__c = null;
        
        update ct;
        
        test.startTest();
            
        Id recId = 
        Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
		
        ApexPages.currentPage().getParameters().put('retURL', '/' + acct.id);
        //ApexPages.currentPage().getParameters().put('oppId', opp.id);
        //
        ApexPages.currentPage().getParameters().put('id', acct.id);
        ApexPages.currentPage().getParameters().put('continue', '/'+opp.id);
        ApexPages.currentPage().getParameters().put('createproducts', 'yes');
        ApexPages.currentPage().getParameters().put('RecordType', recId);
        
        OpportunitySalesRepPageExtension obj1 = new OpportunitySalesRepPageExtension();
        
        obj1.saveOverride();
        obj1.cancel();
        obj1.getSelected();
        obj1.setOptionValues();
        obj1.getAllOptionValues();

        Test.stopTest();
         
    }
    @isTest static void Contact(){
      	
        Account acct = [select id,name,ownerid,sales_rep_o__c,Sales_Rep_Record_Type__c,
                                acctseed__gl_account_variable_1__r.name 
                from Account where name='Test Account' Limit 1];
        Opportunity opp = [select id,sales_rep_o__c from Opportunity where name = 'Test Opportunity' limit 1];
        
        Contact ct = [select id, name, gl_account_variable_1__r.name from contact where 
                      name = 'FirstName LastName' Limit 1];
        
        test.startTest();
            
        Id recId = 
        Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
		
        ApexPages.currentPage().getParameters().put('retURL', '/'+ct.id);
        //ApexPages.currentPage().getParameters().put('oppId', opp.id);
        //
        ApexPages.currentPage().getParameters().put('id', '');
        ApexPages.currentPage().getParameters().put('continue', '/'+opp.id);
        ApexPages.currentPage().getParameters().put('createproducts', 'yes');
        ApexPages.currentPage().getParameters().put('RecordType', recId);
        
        OpportunitySalesRepPageExtension obj1 = new OpportunitySalesRepPageExtension();
        
        obj1.saveOverride();
        obj1.cancel();
        obj1.getSelected();
        obj1.setOptionValues();
        obj1.getAllOptionValues();

        Test.stopTest();
         
    }


}
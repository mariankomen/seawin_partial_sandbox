@isTest
public with sharing class SalesRepPageTeamDeselectionExtensionTest {
    
    @testSetup static void createData(){
        
        AcctSeed__Accounting_Variable__c av = MakeData.MakeGL('Seawin USA');

        // create user
        Profile pf = [Select Id from profile where Name = 'System Administrator']; 
        
        String orgId = UserInfo.getOrganizationId(); 
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName = orgId + dateString + RandomId; 
        
        User usr = new User(lastName = 'User', 
                            email = uniqueName + '@test' + orgId + '.org', 
                            Username = uniqueName + '@test' + orgId + '.org', 
                            EmailEncodingKey = 'ISO-8859-1', 
                            Alias = uniqueName.substring(18, 23), 
                            TimeZoneSidKey = 'America/Los_Angeles', 
                            LocaleSidKey = 'en_US', 
                            LanguageLocaleKey = 'en_US', 
                            ProfileId = pf.Id
                           ); 
        insert usr;
        
        String dateString2 = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId2 = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName2 = orgId + dateString2 + RandomId2; 
        
        User usr2 = new User(lastName = 'User2', 
                            email = uniqueName2 + '@test' + orgId + '.org', 
                            Username = uniqueName2 + '@test' + orgId + '.org', 
                            EmailEncodingKey = 'ISO-8859-1', 
                            Alias = uniqueName2.substring(18, 23), 
                            TimeZoneSidKey = 'America/Los_Angeles', 
                            LocaleSidKey = 'en_US', 
                            LanguageLocaleKey = 'en_US', 
                            ProfileId = pf.Id
                           ); 
        insert usr2;
        
        
        List<Sales_Rep__c> srlist = new list<Sales_Rep__c>();

        Sales_Rep__c OldSalesRep = new Sales_Rep__c();  
        OldSalesRep.Name = 'Old Sales Rep';
        OldSalesRep.Active__c = 'No';
        OldSalesRep.Team__c = usr.id + ';' + usr2.id; 
        
        OldSalesRep.GL_Account_Variable_to_Sales_Rep__c = av.id;

        srlist.add(OldSalesRep);
        
        Sales_Rep__c NewSalesRep = new Sales_Rep__c();
        NewSalesRep.Name = 'New Sales Rep';
        NewSalesRep.Active__c = 'Yes';
        NewSalesRep.Team__c = usr2.id;
        NewSalesRep.GL_Account_Variable_to_Sales_Rep__c = av.id;
        
        srlist.add(NewSalesRep);
        
        insert srlist;

        OldSalesRep.Sales_Rep_Shadow__c = NewSalesRep.id;
        update OldSalesRep;
        
        // create account
        Account acct = new Account();      
        acct.Name = 'Test Account';
        acct.Type = 'Customer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = av.Id;
        acct.Sales_Rep_O__c = OldSalesRep.Id;
        insert acct;

        Opportunity opp = new Opportunity();

        opp.Name = 'Test Opportunity';
        opp.GL_Account_Variable_1__c = av.id;
        opp.sales_rep_o__c = OldSalesRep.id;
        opp.closeDate = Date.Today();
        opp.StageName = 'Follow Up';

        insert opp;

        AcctSeed__GL_Account__c bankaccount = MakeData.MakeGLAccount(true, av);
        AcctSeed__Billing_Format__c pdfformat = MakeData.MakePDFFormat('Sales Order');
        AcctSeed__Ledger__c ledger = MakeData.MakeLedger(bankaccount, pdfformat);

        AcctSeedERP__Sales_Order__c so = new AcctSeedERP__Sales_Order__c();
        
        so.AcctSeedERP__Customer__c = acct.id;
        so.AcctSeedERP__Status__c = 'Open';
        so.Stage__c = 'Production';
        so.GL_Account_Variable_1__c = av.Id;
        so.AcctSeedERP__Ledger__c = ledger.id;
        so.Price_Level__c = 'Level 3';

        insert so;
    }
    
    
    @isTest static void BuildAccounts(){
        
        Test.startTest();
        
        Sales_Rep__c sr = [select id, Sales_Rep_Shadow__c, 
        Sales_Rep_Shadow__r.Team__c, User__c, OwnerId from Sales_Rep__c
                           where Name = 'Old Sales Rep' Limit 1];

        User owner = [select id from user where lastname = 'User2' Limit 1];
        
        Apexpages.currentPage().getParameters().put('pageIsFor', 'acc');
        Apexpages.currentPage().getParameters().put('srId', sr.Id);
        
        SalesRepPageTeamDeselectionExtension ext = new SalesRepPageTeamDeselectionExtension();

        ext.selected = owner.id;
        System.Assert(ext.ownerid == null);
        System.Assert(ext.usr != null);
        
        ext.getAllOptionValues();
        ext.setOptionValues();
        ext.getAvailableUsersForTeam(sr.Sales_Rep_Shadow__r.Team__c);
        
        ext.getSelected();

        ext.save();
        
        Exception ex = new MyException();
        ex.setMessage('This is a test exception message.');
        
        ext.showpageerror(ex);
        
        Test.stopTest();
    }

    @isTest static void BuildOpportunities(){
        
        Test.startTest();
        
        Sales_Rep__c sr = [select id, Sales_Rep_Shadow__c, 
        Sales_Rep_Shadow__r.Team__c, User__c, OwnerId from Sales_Rep__c
                           where Name = 'Old Sales Rep' Limit 1];

        User owner = [select id from user where lastname = 'User2' Limit 1];
        
        Apexpages.currentPage().getParameters().put('pageIsFor', 'opp');
        Apexpages.currentPage().getParameters().put('srId', sr.Id);
        
        SalesRepPageTeamDeselectionExtension ext = new SalesRepPageTeamDeselectionExtension();

        ext.selected = owner.id;
        
        ext.getAllOptionValues();
        ext.setOptionValues();
        ext.getAvailableUsersForTeam(sr.Sales_Rep_Shadow__r.Team__c);
        
        ext.getSelected();

        ext.save();
        
        Test.stopTest();
    }

    @isTest static void BuildSalesOrders(){
        
        Test.startTest();
        
        Sales_Rep__c sr = [select id, Sales_Rep_Shadow__c, 
        Sales_Rep_Shadow__r.Team__c, User__c, OwnerId from Sales_Rep__c
                           where Name = 'Old Sales Rep' Limit 1];

        User owner = [select id from user where lastname = 'User2' Limit 1];
        
        Apexpages.currentPage().getParameters().put('pageIsFor', 'so');
        Apexpages.currentPage().getParameters().put('srId', sr.Id);
        
        SalesRepPageTeamDeselectionExtension ext = new SalesRepPageTeamDeselectionExtension();

        ext.selected = owner.id;
        
        ext.getAllOptionValues();
        ext.setOptionValues();
        ext.getAvailableUsersForTeam(sr.Sales_Rep_Shadow__r.Team__c);
        
        ext.getSelected();

        ext.save();
        
        Test.stopTest();
    }
    
    public class MyException extends Exception{

    }
}
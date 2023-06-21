@isTest
public class AccountCreateTest {

    @testSetup static void createData(){
        
        Sales_Rep__c sr = new Sales_Rep__c();
        
        sr.name = 'Test Team';
        sr.Email__c = 'team@test.com';
        sr.Team__c = UserInfo.getUserId();
        
        insert sr;
        
        
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        // create account
        Account acct = new Account();
        acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        acct.BillingStreet = 'The Street';
        acct.BillingCity = 'The City';
        acct.BillingState = 'The State';
        acct.BillingCountry = 'The Country';
        acct.BillingPostalCode = 'The Postal Code';
        insert acct;

    }
    
    @isTest static void JustCreateAccount(){

        ApexPages.currentPage().getParameters().put('retURL', '/001/0');
        //ApexPages.currentPage().getParameters().put('isSelectScreen', 'str');
        //ApexPages.currentPage().getParameters().put('ownerid');
        //ApexPages.currentPage().getParameters().put('salesrepid');

        Sales_Rep__c sr = [select id from sales_rep__c limit 1];
        AcctSeed__Accounting_Variable__c accVar = [select id from AcctSeed__Accounting_Variable__c limit 1];
        
        Account acct = new Account();
        acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        acct.BillingStreet = 'The Street';
        acct.BillingCity = 'The City';
        acct.BillingState = 'The State';
        acct.BillingCountry = 'The Country';
        acct.BillingPostalCode = 'The Postal Code';
        
        Test.startTest();

        ApexPages.StandardController std = new ApexPages.StandardController(acct);
        AccountCreateExtension ext = new AccountCreateExtension(std);
        
        ext.RedirectToSalesRepPage();
        ext.Save();
        ext.SaveAndNew();
        ext.Save_Alert();
        ext.SaveAndNew_Alert();
        
        Test.stopTest();

    }
    @isTest static void CreateAccountWithDetails(){

        Sales_Rep__c sr = [select id from sales_rep__c limit 1];
        AcctSeed__Accounting_Variable__c accVar = [select id from AcctSeed__Accounting_Variable__c limit 1];

        ApexPages.currentPage().getParameters().put('retURL', '/001/0');
        ApexPages.currentPage().getParameters().put('isSelectScreen', 'str');
        ApexPages.currentPage().getParameters().put('ownerid', userinfo.getuserid());
        ApexPages.currentPage().getParameters().put('salesrepid', sr.id);
        
        Account acct = new Account();
        acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'Test Account';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        acct.BillingStreet = 'The New Street';
        acct.BillingCity = 'The New City';
        acct.BillingState = 'The New State';
        acct.BillingCountry = 'The New Country';
        acct.BillingPostalCode = 'The Zip Code';
        
        Test.startTest();
        
        ApexPages.StandardController std = new ApexPages.StandardController(acct);
        AccountCreateExtension ext = new AccountCreateExtension(std);
        
        ext.RedirectToSalesRepPage();
        ext.Save();
        ext.SaveAndNew();
        
        Test.stopTest();

    }
}
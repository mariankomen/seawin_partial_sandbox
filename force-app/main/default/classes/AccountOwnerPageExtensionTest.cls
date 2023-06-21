@isTest
public with sharing class AccountOwnerPageExtensionTest {
    
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
    }
    
    @isTest static void StartProcess(){
      
        Account acc = [select id from Account where name = 'myAccount' limit 1];
        
        test.startTest();
		
        ApexPages.currentPage().getParameters().put('retURL', acc.id);
        ApexPages.currentPage().getParameters().put('accId', acc.id);
        
        AccountOwnerPageExtension obj1 = new AccountOwnerPageExtension();
        
        obj1.saveOverride();
        obj1.cancel();
        obj1.getSelected();
        obj1.setOptionValues();
        obj1.getAllOptionValues();
         
    }

}
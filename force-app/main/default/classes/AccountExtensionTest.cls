@isTest
public class AccountExtensionTest {
    
    
    @testsetup static void createData(){
        
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        // create account
        Account acct = new Account();
        //acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct;
    } 
    
    @isTest static void StartProcess(){
        
        Account acc = [select id from account
                       where name = 'myAccount' limit 1];
        
        test.startTest();
        
        PageReference pageRef = Page.LockedAccountPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController std = new ApexPages.StandardController(acc);
        
        AccountExtension obj = new AccountExtension(std);
        
    }
}
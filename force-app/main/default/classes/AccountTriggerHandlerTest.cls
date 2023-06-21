@isTest
public with sharing class AccountTriggerHandlerTest {
    
    @TestSetup
    static void makeData(){
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'Seawin USA';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;

        Account acct = new Account();
        //acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct;
    }

    @isTest
    public static void handleExecuteDeleteTriggerTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        delete acc;
    }
}
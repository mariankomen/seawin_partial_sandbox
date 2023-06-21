@isTest
private class UpdateBatchableTest {
    @testSetup 
    static void setup() {

        AcctSeed__Accounting_Variable__c av = 
        new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',
        AcctSeed__Type__c = 'GL Account Variable 1');
        insert av;
        
        Account acct = new Account();
        
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__Billing_Terms_Name__c = 'Example terms';
        acct.AcctSeed__GL_Account_Variable_1__c = av.id; 

        insert acct;
    }
    @isTest static void runTests() { 
        
        List<account> acctList = new List<account>([select id, Name from account 
                                                           where name='myAccount' limit 1]);

        acctList[0].name = 'Test Account';
        
        Test.startTest();
        UpdateBatchable ub = new UpdateBatchable(acctList, false);
        Id batchId = Database.executeBatch(ub);
        Test.stopTest();
    }
}
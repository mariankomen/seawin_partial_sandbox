@isTest
public class AutoSalesRepAssignmentHandlerTest {
    @TestSetup static void MakeData(){
        
        AcctSeed__Accounting_Variable__c av = MakeData.MakeGL('Seawin USA');
        
        Sales_Rep__c salesrep = new Sales_Rep__c();
        salesrep.name = 'House Account';
        salesrep.IsTeam__c = true;
        salesrep.Team__c = UserInfo.getUserId();
        
        insert salesrep;
        
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.AcctSeed__GL_Account_Variable_1__c = av.id;
        acct.type = 'Architect';
        
        insert acct;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.closedate = Date.today();
        opp.stagename = 'Negotiation';
        opp.GL_Account_Variable_1__c = av.id;
        
        insert opp;
        
        opp.stagename = 'Follow Up';
        update opp;
        
    }
    
    @isTest static void runTests(){
        
        system.assert([select sales_rep_o__r.name from account limit 1][0].sales_rep_o__r.name == 'House Account');
        system.assert([select sales_rep_o__r.name from opportunity limit 1][0].sales_rep_o__r.name == 'House Account');
        
    }
}
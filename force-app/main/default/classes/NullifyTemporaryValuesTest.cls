@isTest
public class NullifyTemporaryValuesTest {
	
    @TestSetup static void MakeData(){
        
        AcctSeed__Accounting_Variable__c av = MakeData.MakeGL('Seawin USA');
        
        User usr = MakeData.MakeUser('System Administrator');
        
        Sales_rep__c sr = new Sales_rep__c(Name='Test Sales Rep', IsTeam__c=true, Team__c=usr.id);
        insert sr;
        
        Account acct = new Account(Name='Test Account', AcctSeed__GL_Account_Variable_1__c=av.id,
                                  Type='Architect');
        insert acct;
        
        acct.sales_rep_shadow__c = sr.id;
        acct.owner_custom__c = usr.id;
        
        update acct;
        
        Opportunity opp = new Opportunity(Name='Test Opportunity', CloseDate=Date.Today() + 7, 
                                          StageName='Negotiation', GL_Account_Variable_1__c=av.id);
        insert opp;
        
        opp.sales_rep_shadow__c = sr.id;
        opp.owner_custom__c = usr.id;
        
        update opp;
        
        AcctSeed__GL_Account__c glaccount = MakeData.MakeGLAccount(true, av);
        AcctSeed__Billing_Format__c pdfformat = MakeData.MakePDFFormat('Sales Order');
        AcctSeed__Ledger__c ledger = MakeData.MakeLedger(glaccount, pdfformat);
        
        AcctSeedERP__Sales_Order__c so = new AcctSeedERP__Sales_Order__c(AcctSeedERP__Customer__c=acct.id,
                                                                        GL_Account_Variable_1__c=av.id,
                                                                        AcctSeedERP__Ledger__c=ledger.id);
        insert so;
        
        so.sales_rep_shadow__c = sr.id;
        so.owner_custom__c = usr.id;
        
        update so;
    }
    
    @isTest static void AccountTest(){
        
        Account acct = [select id, sales_rep_shadow__c, owner_custom__c from Account Limit 1];
        
        Test.startTest();
        
        system.assert(acct.sales_rep_shadow__c == null);
        system.assert(acct.owner_custom__c == null);
        
        Test.stopTest();
    }
    
    @isTest static void OpportunityTest(){
        
        Opportunity opp = [select id, sales_rep_shadow__c, owner_custom__c from Opportunity Limit 1];
        
        Test.startTest();
        
        system.assert(opp.sales_rep_shadow__c == null);
        system.assert(opp.owner_custom__c == null);
        
        Test.stopTest();
    }
    
    @isTest static void SalesOrderTest(){
        
        AcctSeedERP__Sales_Order__c so = [select id, sales_rep_shadow__c, owner_custom__c from 
                                          AcctSeedERP__Sales_Order__c Limit 1];
        
        Test.startTest();
        
        system.assert(so.sales_rep_shadow__c == null);
        system.assert(so.owner_custom__c == null);
        
        Test.stopTest();
    }
}
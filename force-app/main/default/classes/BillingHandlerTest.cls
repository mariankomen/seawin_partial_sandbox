@isTest
public class BillingHandlerTest {
	
    @TestSetup static void MakeData(){
        
        AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c(
            Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1');
        
        insert av;

        Date d = Date.today();

        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        
        Integer year = d.year();
        String month = d.month() > 9 ? '' + d.month() : '0' + d.month();

        ap.Name = year + '-' + month;
        ap.AcctSeed__Start_Date__c = Date.NewInstance(year, d.month(), 1);
        ap.AcctSeed__End_Date__c = Date.NewInstance(year, d.month(), Date.DaysInMonth(year, d.month()));
        ap.AcctSeed__Status__c = 'Open';
            
        insert ap;
        
        Contact ct_account = new Contact();
        ct_account.lastname = 'Test Contact Account';
        ct_account.GL_Account_Variable_1__c = av.id;

        insert ct_account;

        Account acct = new Account();

        acct.name = 'Test Account';
        acct.AcctSeed__GL_Account_Variable_1__c = av.id;
        acct.type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.Contact_Person__c = ct_account.id;

        insert acct;

        Contact ct_opportunity = new Contact();
        ct_opportunity.lastname = 'Test Contact Opportunity';
        ct_opportunity.GL_Account_Variable_1__c = av.id;

        insert ct_opportunity;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.CloseDate = Date.today() + 7;
        opp.StageName = 'Analysis';
        opp.GL_Account_Variable_1__c = av.id;
        opp.ContactPerson__c = ct_opportunity.id;

        insert opp;

        // ledger creation
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = av.id;
        
        insert aegl;
        
        AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();
        
        abf.Name = 'Test Billing Format';
        abf.AcctSeed__Type__c = 'Billing';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        insert abf;
        
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
        
        ledger.Name = 'myLedger';
        ledger.AcctSeed__Type__c = 'Transactional';
        ledger.AcctSeed__Billing_Activity_Statement_Format__c = abf.id;
        ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = abf.id;
        ledger.AcctSeed__Default_Bank_Account__c = aegl.id;
        ledger.AcctSeed__Default_Billing_Format__c = abf.id; 
        ledger.AcctSeed__Default_Purchase_Order_Format__c = abf.id;
        ledger.AcctSeed__Default_Packing_Slip_Format__c = abf.id;
        
        insert ledger;

        Contact ct_salesorder = new Contact();
        ct_salesorder.lastname = 'Test Contact Sales Order';
        ct_salesorder.GL_Account_Variable_1__c = av.id;

        insert ct_salesorder;
 
        // create a sales order
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c(); 
        
        salesorder.AcctSeedERP__Status__c = 'Open';
       	salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.GL_Account_Variable_1__c = av.id;
        salesorder.Billing_Name__c = ct_salesorder.id;
        

        insert salesorder;
        
    }
    
    @isTest static void salesorder(){

        Account acct = [select id from account where name = 'Test Account' Limit 1];
        AcctSeedERP__Sales_Order__c salesorder = [select id from AcctSeedERP__Sales_Order__c Limit 1];
        Contact ct = [select id from contact where name = 'Test Contact Sales Order' Limit 1];
        AcctSeed__Billing_Format__c abf = [select id from AcctSeed__Billing_Format__c Limit 1];
        AcctSeed__Ledger__c ledger = [select id from AcctSeed__Ledger__c Limit 1];

        AcctSeed__Accounting_Period__c ap = [select id from AcctSeed__Accounting_Period__c Limit 1];

        Test.startTest();

        AcctSeed__Billing__c billing = new AcctSeed__Billing__c();

        billing.AcctSeed__Customer__c = acct.id;
        billing.AcctSeedERP__Sales_Order__c = salesorder.id;
        //billing.AcctSeed__Opportunity__c = opportunity.id; 
        billing.Acctseed__date__c = date.today();
        billing.AcctSeed__status__c = 'Approved';
        billing.AcctSeed__Accounting_Period__c = ap.id;
        billing.AcctSeed__Billing_Format__c = abf.id;
        billing.AcctSeed__Ledger__c = ledger.id;

        insert billing;

        Test.stopTest();

        // Check if the contact has been populated by the new trigger
        system.assertEquals(ct.id, 
        [select AcctSeed__Billing_Contact__c from AcctSeed__Billing__c Limit 1][0].AcctSeed__Billing_Contact__c);
        
    }

    @isTest static void opportunity(){
		
        Account acct = [select id from account where name = 'Test Account' Limit 1];
        Opportunity oppty = [select id from Opportunity where name = 'Test Opportunity' Limit 1];
        Contact ct = [select id from contact where name = 'Test Contact Opportunity' Limit 1];
        AcctSeed__Billing_Format__c abf = [select id from AcctSeed__Billing_Format__c Limit 1];
        AcctSeed__Ledger__c ledger = [select id from AcctSeed__Ledger__c Limit 1];

        AcctSeed__Accounting_Period__c ap = [select id from AcctSeed__Accounting_Period__c Limit 1];

        Test.startTest();

        AcctSeed__Billing__c billing = new AcctSeed__Billing__c();

        // billing.AcctSeedERP__Sales_Order__c = salesorder.id;
        billing.AcctSeed__Opportunity__c = oppty.id;
        billing.AcctSeed__Customer__c = acct.id;
        billing.Acctseed__date__c = date.today();
        billing.AcctSeed__status__c = 'Approved';
        billing.AcctSeed__Accounting_Period__c = ap.id;
        billing.AcctSeed__Billing_Format__c = abf.id;
        billing.AcctSeed__Ledger__c = ledger.id;

        insert billing;

        Test.stopTest();

        // Check if the contact has been populated by the new trigger
        system.assertEquals(ct.id, 
        [select AcctSeed__Billing_Contact__c from AcctSeed__Billing__c Limit 1][0].AcctSeed__Billing_Contact__c);
        
    }

    @isTest static void account(){

        Account acct = [select id from account where name = 'Test Account' Limit 1];
        Contact ct = [select id from contact where name = 'Test Contact Account' Limit 1];
        AcctSeed__Billing_Format__c abf = [select id from AcctSeed__Billing_Format__c Limit 1];
        AcctSeed__Ledger__c ledger = [select id from AcctSeed__Ledger__c Limit 1];

        AcctSeed__Accounting_Period__c ap = [select id from AcctSeed__Accounting_Period__c Limit 1];

        Test.startTest();

        AcctSeed__Billing__c billing = new AcctSeed__Billing__c();

        // billing.AcctSeedERP__Sales_Order__c = salesorder.id;
        // billing.AcctSeed__Opportunity__c = oppty.id;
        billing.AcctSeed__Customer__c = acct.id;
        billing.Acctseed__date__c = date.today();
        billing.AcctSeed__status__c = 'Approved';
        billing.AcctSeed__Accounting_Period__c = ap.id;
        billing.AcctSeed__Billing_Format__c = abf.id;
        billing.AcctSeed__Ledger__c = ledger.id;

        insert billing;

        Test.stopTest();

        // Check if the contact has been populated by the new trigger
        system.assertEquals(ct.id, 
        [select AcctSeed__Billing_Contact__c from AcctSeed__Billing__c Limit 1][0].AcctSeed__Billing_Contact__c);
        
    }
}
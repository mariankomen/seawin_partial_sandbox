@isTest
public class LockedOpportunityExtensionTest {
    
    @TestSetup static void CreateDate(){
     
        AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c();
        
        av.Name = 'Seawin USA';
        av.AcctSeed__Active__c = true;
        av.AcctSeed__Type__c = 'GL Account Variable 1';
        
        insert av;
        
         // create account
        Account acct = new Account();
        
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = av.Id;
        acct.Status__c = 'Rejected';
        insert acct;
        
        // create contact
        Contact cont = new Contact();
        
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.GL_Account_Variable_1__c = av.Id;
        insert cont;
            
            // create opportunity
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Closed Won';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = av.Id;
        opp.Sent_for_Approval__c = true;
        opp.TotalBills__c = 1;
        opp.Referral_Sales_Rep__c = [SELECT Id, IsActive FROM User where IsActive = true limit 1].Id;
        insert opp;
        
        // Create Sales Order
        
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = av.Id;

        
        insert aegl;
        
        AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();
        
        abf.Name = 'newPDF Format';
        abf.AcctSeed__Type__c = 'Purchase Order';
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
        
        // create a sales order
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c(); 
        
        //salesorder.name = 'testSalesOrder';
        salesorder.AcctSeedERP__Customer__c = acct.Id;
        salesorder.AcctSeedERP__Opportunity__c = opp.Id;
        salesorder.Contact__c = cont.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
        salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.GL_Account_Variable_1__c = av.Id;
        
       // insert salesorder;
        
    }
    
    @isTest static void RunTests(){
        
        Account acc =[select id,Status__c from account where name = 'myAccount' limit 1];

        Opportunity opp = [select id,accountid,account.Status__c from opportunity where name='myOpportunity' limit 1];
        update opp;
        
        ApexPages.StandardController std1 = new ApexPages.StandardController(opp);
        LockedOpportunityExtension loe = new LockedOpportunityExtension(std1);
        
        opp.Sent_for_Approval__c = false;
        opp.account.Status__c = 'Active';
        update opp;
        
        ApexPages.StandardController std2 = new ApexPages.StandardController(opp);
        LockedOpportunityExtension obj2 = new LockedOpportunityExtension(std2);
    }
}
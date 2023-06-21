@isTest
public class OpportunityDeleteOverrideTest {
    
    @testsetup static void createData(){

        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        
        ap.Name = '2022-10';
        ap.AcctSeed__Status__c = 'Open';
        ap.AcctSeed__Start_Date__c = Date.newInstance(2022, 10, 1);
        ap.AcctSeed__End_Date__c = Date.newInstance(2022, 10, 30);
        
        insert ap;

        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        Sales_rep__c sr = new Sales_rep__c();
        sr.Active__c = 'Yes';
        sr.Name = 'John Doe';
        sr.User__c = UserInfo.getUserId();
        
        insert sr;

        Account acct = new Account();
        acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct;

         // create account
        Account acct1 = new Account();
        //acct.Sales_Rep_O__c = sr.id;
        acct1.Name = 'myAccount';
        acct1.Type = 'Designer';
        acct1.AcctSeed__Accounting_Type__c = 'Customer';
        acct1.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct1;
		
        // create contact
        Contact cont = new Contact();
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.LeadSource = 'AAOHA 2020';
        cont.GL_Account_Variable_1__c = accVar.Id;
        insert cont;
        
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c  = accVar.Id;
        insert aegl;
        
        // create opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'myOpportunity';
        //opp.Sales_Rep_O__c = sr.id;
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Follow up';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = accVar.Id;
        opp.Run_Validation_Rule__c = true;
        insert opp;
        
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
        salesorder.AcctSeedERP__Customer__c = acct1.Id;
        salesorder.AcctSeedERP__Opportunity__c = opp.Id;
        salesorder.Contact__c = cont.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
       	salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.GL_Account_Variable_1__c = accVar.Id;
        insert salesorder;
        
        AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
        
        bill.AcctSeed__Status__c = 'Approved';
        bill.AcctSeed__PDF_Email_Status__c = 'Unsent';
        bill.AcctSeed__Billing_Format__c = abf.id;
        bill.AcctSeedERP__Sales_Order__c = salesorder.id; 
        bill.AcctSeed__Date__c = Date.Today();
        bill.AcctSeed__Due_Date2__c = Date.Today();
        bill.AcctSeed__Ledger__c = salesorder.AcctSeedERP__Ledger__c;
        bill.AcctSeed__Opportunity__c = salesorder.AcctSeedERP__Opportunity__c;
        bill.AcctSeed__Customer__c = salesorder.AcctSeedERP__Customer__c;
        bill.AcctSeed__Shipping_City__c = salesorder.AcctSeedERP__Shipping_City__c;
        bill.AcctSeed__Shipping_Contact__c = salesorder.Contact__c;
        bill.AcctSeed__Shipping_Country__c = salesorder.AcctSeedERP__Shipping_Country__c;
        bill.AcctSeed__Shipping_PostalCode__c = salesorder.AcctSeedERP__Shipping_PostalCode__c;
        bill.AcctSeed__Shipping_State__c = salesorder.AcctSeedERP__Shipping_State__c;
        bill.AcctSeed__Shipping_Street__c = salesorder.AcctSeedERP__Shipping_Street__c;
        bill.AcctSeed__Billing_Contact__c = salesorder.Contact__c;
        bill.AcctSeed__Billing_Country__c = salesorder.AcctSeedERP__Billing_Country__c;
        bill.AcctSeed__Billing_PostalCode__c = salesorder.AcctSeedERP__Billing_PostalCode__c;
        bill.AcctSeed__Billing_State__c = salesorder.AcctSeedERP__Billing_State__c;
        bill.AcctSeed__Billing_Street__c = salesorder.AcctSeedERP__Billing_Street__c;
        bill.AcctSeed__Billing_City__c = salesorder.AcctSeedERP__Billing_City__c;
        bill.AcctSeed__Customer__c = acct.Id;
        bill.AcctSeed__Accounting_Period__c = ap.Id;
        bill.AcctSeed__Opportunity__c = opp.Id;
        insert bill;
    }
    
    @isTest static void ParentOpportunityNoReturlCase(){
        
        Opportunity opp = [select id,parent_opportunity__c from Opportunity where name = 'myOpportunity' limit 1];
        
        ApexPages.currentPage().getParameters().put('retUrl', '/006/o');
        ApexPages.StandardController std = new ApexPages.StandardController(opp);
        OpportunityDeleteOverrideExtension odo = new OpportunityDeleteOverrideExtension(std);
        
        odo.TryDelete();
        odo.back();
        
        
        
    }
}
@isTest
public class BillingLineResortHandlerTest {
    
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

        Account acct = new Account();

        acct.name = 'Test Account';
        acct.AcctSeed__GL_Account_Variable_1__c = av.id;
        acct.type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';

        insert acct;

        // ledger creation
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = av.id;
        
        insert aegl;
        
        // without bank checked
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        gl.name = 'glaccount 2';
        gl.AcctSeed__Type__c = 'Expense';
        gl.AcctSeed__Sub_Type_1__c = 'Facilities';
        gl.AcctSeed__Sub_Type_2__c = 'Rent';
        gl.AcctSeed__Bank__c = false;
        gl.GL_Account_Variable_1__c = av.id;
        
        insert gl;
        
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
        
        Product2 prod = new Product2();
        
        prod.Name = 'myProduct';
        prod.ProductCode = 'ABC123';
        prod.Description = 'myDescription';
        prod.AcctSeed__Unit_Cost__c = 100;
        prod.IsActive = true;
        prod.Category__c = 'Shower Door';
        prod.Sub_Category__c = 'Single Sliding';
        prod.AcctSeed__Inventory_Type__c = 'Purchased';
        prod.AcctSeed__Expense_GL_Account__c = aegl.id;
        prod.AcctSeed__Inventory_GL_Account__c = aegl.id;
        prod.AcctSeed__Revenue_GL_Account__c = aegl.id;
        prod.AcctSeed__Inventory_Product__c = true;

        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // create standard price book entry
        PricebookEntry pricebentry = new PricebookEntry();
        
        pricebentry.Pricebook2Id = pricebookId;
        pricebentry.Product2Id = prod.Id;
        pricebentry.UnitPrice = 100;
        pricebentry.IsActive = true;
        
        insert pricebentry;
        
        AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
        
        bill.AcctSeed__Status__c = 'Approved';
        bill.AcctSeed__PDF_Email_Status__c = 'Unsent';
        bill.AcctSeed__Billing_Format__c = abf.id;
        bill.AcctSeed__Date__c = Date.Today();
        bill.AcctSeed__Due_Date2__c = Date.Today();
        bill.AcctSeed__Ledger__c = ledger.id;
        bill.AcctSeed__Customer__c = acct.id;
        bill.AcctSeed__Accounting_Period__c = ap.id;

        insert bill;
        
        AcctSeed__Billing_Line__c bline = new AcctSeed__Billing_Line__c();
        bline.AcctSeed__Billing__c = bill.id;
        bline.AcctSeed__Date__c = date.today();
        bline.AcctSeed__Hours_Units__c = 1;
        bline.AcctSeed__Product__c = prod.id;
        bline.AcctSeed__Rate__c = 1;
        bline.Item_Description__c = 'test description';
        bline.AcctSeed__Expense_GL_Account__c = gl.id;
        bline.AcctSeed__Inventory_GL_Account__c = gl.id;
        bline.AcctSeed__Revenue_GL_Account__c = gl.id;
        
        insert bline;
        
    }

    @isTest static void LineDeleteTest(){
        
        acctseed__Billing__c billing = [select id from acctseed__Billing__c limit 1];
       
        // get the sales order lines list
        list<AcctSeed__Billing_Line__c> billinglist = new list<AcctSeed__Billing_Line__c>([
        SELECT Id FROM AcctSeed__Billing_Line__c]);
        
        Test.startTest();
        
        delete billingList;

        Test.stopTest();
    }
    @isTest static void LineUnDeleteTest(){
        acctseed__Billing__c billing = [select id from acctseed__Billing__c limit 1];
       
        // get the sales order lines list
        list<AcctSeed__Billing_Line__c> billinglist = new list<AcctSeed__Billing_Line__c>([
        SELECT Id FROM AcctSeed__Billing_Line__c]);
        
        delete billingList;
        
        Test.startTest();

        undelete billingList;

        Test.stopTest();
    }
}
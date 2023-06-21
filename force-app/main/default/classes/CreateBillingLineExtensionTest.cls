@isTest

public class CreateBillingLineExtensionTest {
    
    @testSetup static void createData(){
        
        AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c(
            Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1');
        
        insert av;

        Account acct = new Account();

        acct.name = 'Test Account';
        acct.AcctSeed__GL_Account_Variable_1__c = av.id;
        acct.type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';

        insert acct;

        Date d = Date.today();

        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        
        Integer year = d.year();
        String month = d.month() > 9 ? '' + d.month() : '0' + d.month();

        ap.Name = year + '-' + month;
        ap.AcctSeed__Start_Date__c = Date.NewInstance(year, d.month(), 1);
        ap.AcctSeed__End_Date__c = Date.NewInstance(year, d.month(), Date.DaysInMonth(year, d.month()));
        ap.AcctSeed__Status__c = 'Open';
            
        insert ap;

        // ledger creation
        AcctSeed__GL_Account__c gl_bank = new AcctSeed__GL_Account__c();
        gl_bank.name = 'bank glaccount';
        gl_bank.AcctSeed__Type__c = 'Expense';
        gl_bank.AcctSeed__Sub_Type_1__c = 'Facilities';
        gl_bank.AcctSeed__Sub_Type_2__c = 'Rent';
        gl_bank.AcctSeed__Bank__c = true;
        gl_bank.GL_Account_Variable_1__c = av.id;
        
        insert gl_bank;

        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        gl.name = 'glaccount';
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
        ledger.AcctSeed__Default_Bank_Account__c = gl_bank.id;
        ledger.AcctSeed__Default_Billing_Format__c = abf.id; 
        ledger.AcctSeed__Default_Purchase_Order_Format__c = abf.id;
        ledger.AcctSeed__Default_Packing_Slip_Format__c = abf.id;
        
        insert ledger;

        Product2 prod = new Product2();
        
        prod.Name = 'myProduct2';
        prod.ProductCode = 'ABC123';
        prod.Description = 'myDescription2';
        prod.AcctSeed__Unit_Cost__c = 100;
        prod.IsActive = true;
        prod.Category__c = 'Shower Door';
        prod.Sub_Category__c = 'Single Sliding';
        prod.AcctSeed__Inventory_Type__c = 'Purchased';
        prod.AcctSeed__Expense_GL_Account__c = gl.id;
        prod.AcctSeed__Inventory_GL_Account__c = gl.id;
        prod.AcctSeed__Revenue_GL_Account__c = gl.id;
        prod.AcctSeed__Inventory_Product__c = true;

        insert prod;
        
        AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
        
        bill.AcctSeed__Status__c = 'Approved';
        bill.AcctSeed__PDF_Email_Status__c = 'Unsent';
        bill.AcctSeed__Billing_Format__c = abf.id;
        bill.AcctSeed__Date__c = Date.Today();
        bill.AcctSeed__Due_Date2__c = Date.Today();
        bill.AcctSeed__Ledger__c = ledger.id;
        bill.AcctSeed__Accounting_Period__c = ap.id;
        bill.AcctSeed__Customer__c = acct.id;
        
        insert bill;
        
        
    }
    
    @isTest static void save(){
        
        AcctSeed__Billing__c bill = [select id from AcctSeed__Billing__c Limit 1];
        
        AcctSeed__GL_Account__c gl = [select id from AcctSeed__GL_Account__c where name = 'glaccount' limit 1];
        
        AcctSeed__Billing_Line__c line = new AcctSeed__Billing_Line__c(AcctSeed__Billing__c=bill.id, AcctSeed__Hours_Units__c = 1,
                                                                      AcctSeed__Rate__c=1,
                                                                      AcctSeed__Inventory_GL_Account__c = gl.id,
        															  AcctSeed__Revenue_GL_Account__c = gl.id,
        															  AcctSeed__Expense_GL_Account__c = gl.id);

        Test.startTest();

        APexPages.StandardController std = new ApexPages.StandardController(line);
        
        CreateBillingLineExtension obj = new CreateBillingLineExtension(std);
        
        obj.Save();
        obj.Cancel();

        Test.stopTest();
    } 
    @isTest static void saveNew(){
        
        AcctSeed__Billing__c bill = [select id from AcctSeed__Billing__c Limit 1];
        
        AcctSeed__GL_Account__c gl = [select id from AcctSeed__GL_Account__c where name = 'glaccount' limit 1];
        
        AcctSeed__Billing_Line__c line = new AcctSeed__Billing_Line__c(AcctSeed__Billing__c=bill.id, AcctSeed__Hours_Units__c = 1,
                                                                      AcctSeed__Rate__c=1,
                                                                      AcctSeed__Inventory_GL_Account__c = gl.id,
        															  AcctSeed__Revenue_GL_Account__c = gl.id,
        															  AcctSeed__Expense_GL_Account__c = gl.id);

        Test.startTest();

        APexPages.StandardController std = new ApexPages.StandardController(line);
        
        CreateBillingLineExtension obj = new CreateBillingLineExtension(std);
        
        obj.SaveAndNew();

        Test.stopTest();
    } 
}
@isTEst
public class FinancialDashboardControllerTest {
    @TestSetup static void createData(){
        

       	User usr = [select id from user where name='House Account' limit 1];
        
        Date d = Date.today();
        
        list<AcctSeed__Accounting_Variable__c> avList = new list<AcctSeed__Accounting_Variable__c>();
        
    	avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin China',AcctSeed__Type__c = 'GL Account Variable 1'));
        
        avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1'));
        insert avList;
        // Accounting Period
        Date dt = date.today();
        
        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        ap.name = dt.year() + '-' + ((dt.month() < 10)?'0' + dt.month():String.ValueOf(dt.month()));
        system.debug(dt.year() + '-' + ((dt.month() < 9)?Integer.ValueOf('0' + dt.month()):dt.month()));
        ap.AcctSeed__Start_Date__c = Date.today() - (dt.day() - 1);
        ap.AcctSeed__End_Date__c = Date.today() + 28;
        ap.AcctSeed__Status__c = 'Open';
        insert ap;
        
        sales_rep__c salesrep = new sales_rep__c();
        
        salesrep.User__c = Userinfo.getUserId();
        salesrep.Active__c = 'Yes';
        salesrep.Name = 'Murtaza Ashraf';
        salesrep.Price_Level_1_12__c = 1;
        salesrep.Price_Level_13_20__c = 2;
        salesrep.Price_Level_21_26__c = 3;
        salesrep.Price_Level_27_30__c = 4;
        salesrep.Monthly_Quota__c = 1000;
        
        insert salesrep;
        
    	// create account

        Account acct = new Account();
        
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__Accounting_Type__c = 'Customer And Vendor';
        acct.AcctSeed__Billing_Terms_Name__c = 'Example terms1';
        acct.AcctSeed__GL_Account_Variable_1__c = avList[1].id;
        acct.Sales_Rep_O__c = salesrep.id;
        acct.Industry = 'Hospitality';
        
        insert acct;
		
        // create contact
        Contact cont = new Contact();
        
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.GL_Account_Variable_1__c = avList[1].id;
        
        insert cont;
        
        list<AcctSeed__GL_Account__c> glList = new list<AcctSeed__GL_Account__c>();
        
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        
        gl.name = 'GL Account First';
        gl.AcctSeed__type__c = 'Balance Sheet';
        gl.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl.AcctSeed__Active__c = true;
        
        glList.add(gl);
		
        // ledger creation
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        
        glList.add(aegl);
        
        insert glList;
        
        // create product
        Product2 prod = new Product2();
        
        prod.Name = 'myProduct';
        prod.ProductCode = 'ABC123';
        prod.Description = 'myDescription';
        prod.AcctSeed__Unit_Cost__c = 100;
        prod.IsActive = true;
        prod.Category__c = 'Shower Door';
        prod.Sub_Category__c = 'Single Sliding';
        prod.AcctSeed__Inventory_Type__c = 'Purchased';
        prod.AcctSeed__Expense_GL_Account__c = glList[0].id;
        prod.AcctSeed__Inventory_GL_Account__c = glList[0].id;
        prod.AcctSeed__Revenue_GL_Account__c = glList[0].id;
        prod.AcctSeed__Inventory_Product__c = true;

        insert prod;

        // get the standard price book id
        Id pricebookId = Test.getStandardPricebookId();
        
        // create standard price book entry
        PricebookEntry pricebentry = new PricebookEntry();
        
        pricebentry.Pricebook2Id = pricebookId;
  		pricebentry.Product2Id = prod.Id;
        pricebentry.UnitPrice = 100;
        pricebentry.IsActive = true;
        
        insert pricebentry;
        
        list<AcctSeed__Billing_Format__c> abfList = new list<AcctSeed__Billing_Format__c>();
    
        AcctSeed__Billing_Format__c pls = new AcctSeed__Billing_Format__c();
        
        pls.Name = 'Packing Slip';
        pls.AcctSeed__Type__c = 'Packing Slip';
        pls.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        pls.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        abfList.add(pls);
        
        AcctSeed__Billing_Format__c ost = new AcctSeed__Billing_Format__c();
        
        ost.Name = 'Outstanding Statement';
        ost.AcctSeed__Type__c = 'Outstanding Statement';
        ost.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        ost.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        abfList.add(ost);
        
        AcctSeed__Billing_Format__c ast = new AcctSeed__Billing_Format__c();
        
        ast.Name = 'Activity Statement';
        ast.AcctSeed__Type__c = 'Activity Statement';
        ast.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        ast.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        abfList.add(ast);
        
        AcctSeed__Billing_Format__c blf = new AcctSeed__Billing_Format__c();
        
        blf.Name = 'Billing Invoice';
        blf.AcctSeed__Type__c = 'Billing';
        blf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        blf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        abfList.add(blf);

        AcctSeed__Billing_Format__c pof = new AcctSeed__Billing_Format__c();
        
        pof.Name = 'Default Purchase Order';
        pof.AcctSeed__Type__c = 'Purchase Order';
        pof.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        pof.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        abfList.add(pof);
        
        insert abfList;

        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
        
        ledger.Name = 'myLedger';
        ledger.AcctSeed__Type__c = 'Transactional';
        ledger.AcctSeed__Billing_Activity_Statement_Format__c = ast.id;
        ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = ost.id;
        ledger.AcctSeed__Default_Bank_Account__c = glList[1].id;
        ledger.AcctSeed__Default_Billing_Format__c = blf.id; 
        ledger.AcctSeed__Default_Purchase_Order_Format__c = pof.id;
        ledger.AcctSeed__Default_Packing_Slip_Format__c = pls.id;
        
        insert ledger;
        
        List<AcctSeed__Billing__c> billList = new List<AcctSeed__Billing__c>();
        
        AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
        
        bill.AcctSeed__Status__c = 'Approved';
        bill.AcctSeed__PDF_Email_Status__c = 'Unsent';
        bill.AcctSeed__Billing_Format__c = blf.id; 
        bill.AcctSeed__Date__c = Date.Today();
        bill.AcctSeed__Due_Date2__c = Date.Today();
        bill.AcctSeed__Ledger__c = ledger.id;
        bill.AcctSeed__Customer__c = acct.id;
        bill.AcctSeed__Shipping_Contact__c = cont.id;
        bill.AcctSeed__Billing_Contact__c = cont.id;
        bill.AcctSeed__Accounting_Period__c = ap.id;

        billList.add(bill);

        // credit memo
        AcctSeed__Billing__c bill2 = new AcctSeed__Billing__c();
        
        bill2.AcctSeed__Status__c = 'Approved';
        bill2.AcctSeed__PDF_Email_Status__c = 'Unsent';
        bill2.AcctSeed__Billing_Format__c = blf.id;
        bill2.AcctSeed__Date__c = Date.Today();
        bill2.AcctSeed__Due_Date2__c = Date.Today();
        bill2.AcctSeed__Ledger__c = ledger.id;
        bill2.AcctSeed__Customer__c = acct.id;
        bill2.AcctSeed__Shipping_Contact__c = cont.id;
        bill2.AcctSeed__Billing_Contact__c = cont.id;
        bill2.AcctSeed__Accounting_Period__c = ap.id;
        
        billList.add(bill2);

        insert billList;
        
        List<AcctSeed__Billing_Line__c> blineList = new List<AcctSeed__Billing_Line__c>();
        
        AcctSeed__Billing_Line__c bline = new AcctSeed__Billing_Line__c();
        bline.AcctSeed__Billing__c = bill.id;
        bline.AcctSeed__Date__c = date.today();
        bline.AcctSeed__Hours_Units__c = 1;
        bline.AcctSeed__Product__c = prod.id;
        bline.AcctSeed__Rate__c = 1;
        bline.Item_Description__c = 'Test';
        
        blineList.add(bline);
        
        AcctSeed__Billing_Line__c bline2 = new AcctSeed__Billing_Line__c();
        bline2.AcctSeed__Billing__c = bill2.id;
        bline2.AcctSeed__Date__c = date.today();
        bline2.AcctSeed__Hours_Units__c = 1;
        bline2.AcctSeed__Product__c = prod.id;
        bline2.AcctSeed__Rate__c = 1;
        bline2.Item_Description__c = 'Test';
        
        blineList.add(bline2);
        
        insert blineList;
    }
    @isTest static void runTest(){
        
        Test.startTest();
        FinancialDashboardController bdc = new FinancialDashboardController();
        
        system.assert(bdc.BillingAgingCategories == null);
        system.assert(bdc.AverageDueDays != null);
        system.assert(bdc.SizeOfBillingAgingMap != null);
        Test.stopTest();
        
        
    }
}
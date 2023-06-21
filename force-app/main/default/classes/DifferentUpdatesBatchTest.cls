@isTest
public with sharing class DifferentUpdatesBatchTest {
    @testSetup static void CreateData() 
 	{
         integer recordSize = 2;
    	AcctSeed__Accounting_Variable__c av = 
            new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA', 
            AcctSeed__Type__c = 'GL Account Variable 1');
        insert av;
        
        Date dt = Date.today();

        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        
        Integer year = dt.year();
        String month = dt.month() > 9 ? '' + dt.month() : '0' + dt.month();

        ap.Name = year + '-' + month;
        ap.AcctSeed__Start_Date__c = Date.NewInstance(year, dt.month(), 1);
        ap.AcctSeed__End_Date__c = Date.NewInstance(year, dt.month(), Date.DaysInMonth(year, dt.month()));
        ap.AcctSeed__Status__c = 'Open';
            
        insert ap;
        
        
        AcctSeed__Accounting_Period__c apGet = [select name, AcctSeed__Start_Date__c, AcctSeed__End_Date__c
                                               ,AcctSeed__Status__c from AcctSeed__Accounting_Period__c where name
                                               =:dt.year() + '-' + ((dt.month() <= 9)?'0' + 
                                                                    dt.month():String.ValueOf(dt.month())) limit 1];
        
        // create account
        Account acct = new Account();        
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = av.id;
        insert acct;
		
        // create contact
        Contact cont = new Contact();
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.GL_Account_Variable_1__c = av.id;
        insert cont;
        
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        
        gl.name = 'GL Account First';
        gl.AcctSeed__type__c = 'Expense';
        gl.AcctSeed__Sub_Type_1__c = 'Facilities';
        gl.AcctSeed__Sub_Type_1__c = 'Rent';
        
        insert gl;
        
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
        prod.AcctSeed__Expense_GL_Account__c = gl.id;
        prod.AcctSeed__Inventory_GL_Account__c = gl.id;
        prod.AcctSeed__Revenue_GL_Account__c = gl.id;
        prod.AcctSeed__Inventory_Product__c = true;

        insert prod;

        Product2 prod2 = new Product2();
        
        prod2.Name = 'myProduct2';
        prod2.ProductCode = 'ABC123';
        prod2.Description = 'myDescription2';
        prod2.AcctSeed__Unit_Cost__c = 100;
        prod2.IsActive = true;
        prod2.Category__c = 'Shower Door';
        prod2.Sub_Category__c = 'Single Sliding';
        prod2.AcctSeed__Inventory_Type__c = 'Purchased';
        prod2.AcctSeed__Expense_GL_Account__c = gl.id;
        prod2.AcctSeed__Inventory_GL_Account__c = gl.id;
        prod2.AcctSeed__Revenue_GL_Account__c = gl.id;
        prod2.AcctSeed__Inventory_Product__c = true;

        insert prod2;
        
        // create opportunity
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Follow up';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = av.id;
        
        insert opp;
		
        Id pricebookId = Test.getStandardPricebookId();
        
        // create standard price book entry
        PricebookEntry pricebentry = new PricebookEntry();
        
        pricebentry.Pricebook2Id = pricebookId;
        pricebentry.Product2Id = prod.Id;
        pricebentry.UnitPrice = 100;
        pricebentry.IsActive = true;
        
        insert pricebentry;

        PricebookEntry pricebentry2 = new PricebookEntry();
        
        pricebentry2.Pricebook2Id = pricebookId;
        pricebentry2.Product2Id = prod2.Id;
        pricebentry2.UnitPrice = 100;
        pricebentry2.IsActive = true;
        
        insert pricebentry2;
        
        // create quote
        Quote qt = new Quote();
        
        qt.OpportunityId = opp.Id;
        //qt.AccountId = acct.Id;
        qt.Name = 'myQuote';
        qt.Quote_Date__c = Date.today();
        
        insert qt;
		
        OpportunityLineItem oli = new OpportunityLineItem();
        
        oli.OpportunityId = opp.Id;
        oli.Product2Id = prod.Id;
        oli.PricebookEntryId = pricebentry2.Id;
        oli.Quantity = 10;
        oli.UnitPrice = 100;
        oli.Description = 'myDescription';
        
        insert oli;
        
        // ledger creation
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = av.id;
        insert aegl;
        
        AcctSeed__GL_Account__c vch = new AcctSeed__GL_Account__c();
        vch.name = '2010-Vouchers Payable';
        vch.AcctSeed__Type__c = 'Balance Sheet';
        vch.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch.AcctSeed__Active__c = true;
        vch.GL_Account_Variable_1__c = av.id;
        
        insert vch;
        
        // ----------------------- Added this portion ------------------ //
        // Because the Custom settings below needs unique GL Accounts
        
        AcctSeed__GL_Account__c vp = new AcctSeed__GL_Account__c();
        vp.name = '2010-Vouchers Payable';
        vp.AcctSeed__Type__c = 'Balance Sheet';
        vp.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vp.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vp.AcctSeed__Active__c = true;
        vp.GL_Account_Variable_1__c = av.id;
        
        insert vp;
        
        AcctSeed__GL_Account__c apgl = new AcctSeed__GL_Account__c();
        apgl.name = '2000-Accounts Payable';
        apgl.AcctSeed__Type__c = 'Balance Sheet';
        apgl.AcctSeed__Sub_Type_1__c = 'Liabilities';
        apgl.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        apgl.AcctSeed__Active__c = true;
        apgl.GL_Account_Variable_1__c = av.id;
        
        insert apgl;

        AcctSeed__GL_Account__c argl = new AcctSeed__GL_Account__c();
        argl.name = '1200-Accounts Receivable';
        argl.AcctSeed__Type__c = 'Balance Sheet';
        argl.AcctSeed__Sub_Type_1__c = 'Assets';
        argl.AcctSeed__Sub_Type_2__c = 'Current Assets';
        argl.AcctSeed__Active__c = true;
        argl.GL_Account_Variable_1__c = av.id;
        
        insert argl;

        AcctSeed__GL_Account__c cye = new AcctSeed__GL_Account__c();
        cye.name = '3060-Current Year Earnings';
        cye.AcctSeed__Type__c = 'Balance Sheet';
        cye.AcctSeed__Sub_Type_1__c = 'Owners Equity';
        cye.AcctSeed__Sub_Type_2__c = 'Equity';
        cye.AcctSeed__Active__c = true;
        cye.GL_Account_Variable_1__c = av.id;
        
        insert cye;
        
        AcctSeed__GL_Account__c re = new AcctSeed__GL_Account__c();
        re.name = '3050-Retained Earnings';
        re.AcctSeed__Type__c = 'Balance Sheet';
        re.AcctSeed__Sub_Type_1__c = 'Owners Equity';
        re.AcctSeed__Sub_Type_2__c = 'Equity';
        re.AcctSeed__Active__c = true;
        re.GL_Account_Variable_1__c = av.id;
        
        insert re;

        AcctSeed__GL_Account__c rgl = new AcctSeed__GL_Account__c();
        rgl.name = '4010-Shower Door Revenue';
        rgl.AcctSeed__Type__c = 'Revenue';
        rgl.AcctSeed__Sub_Type_1__c = 'Product Revenue';
        //r_gl.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        rgl.AcctSeed__Active__c = true;
        rgl.GL_Account_Variable_1__c = av.id;
        
        insert rgl;
        
        AcctSeed__GL_Account__c uc = new AcctSeed__GL_Account__c();
        uc.name = '1060-Unapplied Cash';
        uc.AcctSeed__Type__c = 'Balance Sheet';
        uc.AcctSeed__Sub_Type_1__c = 'Assets';
        uc.AcctSeed__Sub_Type_2__c = 'Cash';
        uc.AcctSeed__Active__c = true;
        uc.GL_Account_Variable_1__c = av.id;
        
        insert uc;

        // ------------------------------------------------------------- // 
        
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
        
        
        AcctSeed__Accounting_Settings__c custm = new AcctSeed__Accounting_Settings__c();
        
        custm.AcctSeed__Vouchers_Payable_GL_Account__c = vp.id;
        custm.AcctSeed__AP_Control_GL_Account__c= apgl.id; 
        custm.AcctSeed__AR_Control_GL_Account__c = argl.id;
        custm.AcctSeed__Current_Year_Earnings_GL_Account__c = cye.id; 
        custm.AcctSeed__Default_Ledger__c = ledger.id; 
        custm.AcctSeed__Retained_Earnings_GL_Account__c =re.id;
        custm.AcctSeed__Revenue_GL_Account__c = rgl.id; 
        custm.AcctSeed__Unapplied_Cash_GL_Account__c =uc.id;
            
            
        insert custm;
        
        // create a sales order
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c(); 
        
        salesorder.AcctSeedERP__Customer__c = acct.Id;
        salesorder.AcctSeedERP__Opportunity__c = opp.Id;
        salesorder.Contact__c = cont.Id;
        //salesorder.AcctSeedERP__Status__c = 'Open';
       	salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.GL_Account_Variable_1__c = av.id;

        insert salesorder;
        
        // create a sales order lines
        AcctSeedERP__Sales_Order_Line__c solines = new AcctSeedERP__Sales_Order_Line__c(); 
        
        solines.AcctSeedERP__Sales_Order__c = salesorder.id;
        solines.AcctSeedERP__Unit_Price__c = 1.1;
        solines.AcctSeedERP_Description__c = 'This is salesorder line item';
        solines.AcctSeedERP__Product__c = prod.id;
        solines.AcctSeedERP__Quantity_Ordered__c = 2;
        
        insert solines;
        
        acctseederp__purchase_order__c po = new acctseederp__purchase_order__c();
        
        po.AcctSeedERP__Order_Date__c = date.today();
        //po.AcctSeedERP__Status__c = 'Open';
        po.AcctSeedERP__Type__c = 'Standard';
        po.AcctSeedERP__Purchase_Order_Format__c = abf.Id;
        po.AcctSeedERP__Ledger__c = ledger.Id;
        po.GL_Account_Variable_1__c = av.id;
        po.Sales_Order__c = salesorder.id;
        po.AcctSeedERP__Vendor__c = acct.Id;
        po.GL_Account_Variable_1__c = av.id;
        
        insert po;
        

        List<acctseederp__purchase_order_line__c> polList = new List<acctseederp__purchase_order_line__c>();
        for(integer i=0; i<recordSize; i++){
            acctseederp__purchase_order_line__c pol = new acctseederp__purchase_order_line__c();
            pol.AcctSeedERP__Product__c = prod.id;
            pol.AcctSeedERP__Quantity__c = 2;
            pol.AcctSeedERP__Purchase_Order__c = po.id;
            pol.AcctSeedERP__Unit_Price__c = 1;
            polList.add(pol);
        }
        insert polList;

        // create inventory balances 1
        AcctSeederp__warehouse__c warehouse = new AcctSeederp__warehouse__c();
        warehouse.Name = 'myWarehouse';
        insert warehouse;
        
        AcctSeedErp__location__c location = new AcctSeedErp__location__c();
        location.Name = 'myLocation';
        location.AcctSeedERP__Warehouse__c = warehouse.id;
        insert location;
        
        acctseederp__inventory_balance__c ib = new acctseederp__inventory_balance__c();
        
        ib.AcctSeedERP__Warehouse__c = warehouse.id;
        ib.AcctSeedERP__Location__c = location.id;
        ib.AcctSeedERP__Product__c = prod.id;
        ib.AcctSeedERP__Ledger__c = ledger.id;
        insert ib;

        
        AcctSeedERP__Purchase_Order_Inventory_Movement__c poim = new AcctSeedERP__Purchase_Order_Inventory_Movement__c();
        poim.AcctSeedERP__GL_Account_Variable_1__c = av.id;
        poim.AcctSeedERP__Inventory_Balance__c = ib.id;
        poim.AcctSeedERP__Quantity__c = 2;
        poim.AcctSeedERP__Purchase_Order_Line__c = polList[0].id;
        poim.AcctSeedERP__Movement_Date__c = date.today();
        poim.AcctSeedERP__Unit_Cost__c = 1;
        insert poim;
        
        AcctSeedERP__Sales_Order_Inventory_Movement__c soim = new AcctSeedERP__Sales_Order_Inventory_Movement__c();
        soim.AcctSeedERP__GL_Account_Variable_1__c = av.id;
        soim.AcctSeedERP__Inventory_Balance__c = ib.id;
        soim.AcctSeedERP__Quantity__c = 1;
        soim.AcctSeedERP__Movement_Date__c = date.today();
        soim.AcctSeedERP__Sales_Order_Line__c = solines.id;
        soim.AcctSeedERP__Unit_Cost__c = 1;
        insert soim;
        
        // create inventory balances 2
        AcctSeederp__warehouse__c warehouse2 = new AcctSeederp__warehouse__c();
        warehouse2.Name = 'myWarehouse2';
        insert warehouse2;
        
        AcctSeedErp__location__c location2 = new AcctSeedErp__location__c();
        location2.Name = 'myLocation2';
        location2.AcctSeedERP__Warehouse__c = warehouse2.id;
        insert location2;
        
        acctseederp__inventory_balance__c ib2 = new acctseederp__inventory_balance__c();
        
        ib2.AcctSeedERP__Warehouse__c = warehouse2.id;
        ib2.AcctSeedERP__Location__c = location2.id;
        ib2.AcctSeedERP__Product__c = prod.id;
        ib2.AcctSeedERP__Ledger__c = ledger.id;
        insert ib2;
        
        // AcctSeedERP__Purchase_Order_Inventory_Movement__c poim2 = new AcctSeedERP__Purchase_Order_Inventory_Movement__c();
        // poim2.AcctSeedERP__GL_Account_Variable_1__c = av.id;
        // poim2.AcctSeedERP__Inventory_Balance__c = ib2.id;
        // poim2.AcctSeedERP__Quantity__c = 2;
        // poim2.AcctSeedERP__Purchase_Order_Line__c = polList[0].id;
        // poim2.AcctSeedERP__Movement_Date__c = date.today();
        // poim2.AcctSeedERP__Unit_Cost__c = 1;
        // insert poim2;
        
        // AcctSeedERP__Sales_Order_Inventory_Movement__c soim2 = new AcctSeedERP__Sales_Order_Inventory_Movement__c();
        // soim2.AcctSeedERP__GL_Account_Variable_1__c = av.id;
        // soim2.AcctSeedERP__Inventory_Balance__c = ib2.id;
        // soim2.AcctSeedERP__Quantity__c = 1;
        // soim2.AcctSeedERP__Movement_Date__c = date.today();
        // soim2.AcctSeedERP__Sales_Order_Line__c = solines.id;
        // soim2.AcctSeedERP__Unit_Cost__c = 1;
        // insert soim2;

    }

    @isTest
    public static void executeTest(){
        Test.startTest();
        DifferentUpdatesBatch k = new DifferentUpdatesBatch();
        Database.executeBatch(k,1);
        Test.stopTest();
    }
}
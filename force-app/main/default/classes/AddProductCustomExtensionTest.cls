@isTest 
public class AddProductCustomExtensionTest 
{
    @testSetup static void CreateData() 
 	{
         integer recordSize = 2;
    	AcctSeed__Accounting_Variable__c av = 
            new AcctSeed__Accounting_Variable__c(Name = 'Seawin Factory', 
            AcctSeed__Type__c = 'GL Account Variable 1');
        insert av;
        
        // Accounting Period
        Date dt = date.today();
        
        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        ap.name = dt.year() + '-' +((dt.month() <= 9)?'0' + dt.month():String.ValueOf(dt.month()));      
        system.debug(dt.year() + '-' + ((dt.month() <= 9)?Integer.ValueOf('0' + dt.month()):dt.month()));
        ap.AcctSeed__Start_Date__c = Date.today() - (dt.day() - 1);
        ap.AcctSeed__End_Date__c = Date.today() + 28;
        ap.AcctSeed__Status__c = 'Open';
        insert ap;
        
        
        AcctSeed__Accounting_Period__c apGet = [select name, AcctSeed__Start_Date__c, AcctSeed__End_Date__c
                                               ,AcctSeed__Status__c from AcctSeed__Accounting_Period__c where name
                                               =:dt.year() + '-' + ((dt.month() <= 9)?'0' + dt.month():String.ValueOf(dt.month())) limit 1];
        
        system.debug(apGet);
        
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
        List<Product2> prodList = new List<Product2>();
        for(integer i=0; i<recordSize; i++){
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
            prod.Type__c = 'Other';

            prodList.add(prod);
        }
        insert prodList;
        
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
        
        // create pricebook2
        Pricebook2 priceb2 = new Pricebook2();
        
        priceb2.Name = 'myPriceBook';
        priceb2.Description = 'myPBDescription';
        priceb2.IsActive = true;
        //priceb2.IsStandard = true;
        
        insert priceb2;
        
        opp.Pricebook2Id = priceb2.Id;
        update opp;
        
        // get the standard price book id
        Id pricebookId = Test.getStandardPricebookId();
        
        // create standard price book entry
        PricebookEntry pricebentry1 = new PricebookEntry();
        
        pricebentry1.Pricebook2Id = pricebookId;
  		pricebentry1.Product2Id = prodList[0].Id;
        pricebentry1.UnitPrice = 100;
        pricebentry1.IsActive = true;
        
        insert pricebentry1;
        
        // create pricebookentry
        PricebookEntry pricebentry2 = new PricebookEntry();
        
        pricebentry2.Pricebook2Id = priceb2.Id;
  		pricebentry2.Product2Id = prodList[0].Id;
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
        
        insert vch;
        
        // ----------------------- Added this portion ------------------ //
        // Because the Custom settings below needs unique GL Accounts
        
        AcctSeed__GL_Account__c vp = new AcctSeed__GL_Account__c();
        vp.name = '2010-Vouchers Payable';
        vp.AcctSeed__Type__c = 'Balance Sheet';
        vp.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vp.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vp.AcctSeed__Active__c = true;
        
        insert vp;
        
        AcctSeed__GL_Account__c apgl = new AcctSeed__GL_Account__c();
        apgl.name = '2000-Accounts Payable';
        apgl.AcctSeed__Type__c = 'Balance Sheet';
        apgl.AcctSeed__Sub_Type_1__c = 'Liabilities';
        apgl.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        apgl.AcctSeed__Active__c = true;
        
        insert apgl;

        AcctSeed__GL_Account__c argl = new AcctSeed__GL_Account__c();
        argl.name = '1200-Accounts Receivable';
        argl.AcctSeed__Type__c = 'Balance Sheet';
        argl.AcctSeed__Sub_Type_1__c = 'Assets';
        argl.AcctSeed__Sub_Type_2__c = 'Current Assets';
        argl.AcctSeed__Active__c = true;
        
        insert argl;

        AcctSeed__GL_Account__c cye = new AcctSeed__GL_Account__c();
        cye.name = '3060-Current Year Earnings';
        cye.AcctSeed__Type__c = 'Balance Sheet';
        cye.AcctSeed__Sub_Type_1__c = 'Owners Equity';
        cye.AcctSeed__Sub_Type_2__c = 'Equity';
        cye.AcctSeed__Active__c = true;
        
        insert cye;
        
        AcctSeed__GL_Account__c re = new AcctSeed__GL_Account__c();
        re.name = '3050-Retained Earnings';
        re.AcctSeed__Type__c = 'Balance Sheet';
        re.AcctSeed__Sub_Type_1__c = 'Owners Equity';
        re.AcctSeed__Sub_Type_2__c = 'Equity';
        re.AcctSeed__Active__c = true;
        
        insert re;

        AcctSeed__GL_Account__c rgl = new AcctSeed__GL_Account__c();
        rgl.name = '4010-Shower Door Revenue';
        rgl.AcctSeed__Type__c = 'Revenue';
        rgl.AcctSeed__Sub_Type_1__c = 'Product Revenue';
        //r_gl.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        rgl.AcctSeed__Active__c = true;
        
        insert rgl;
        
        AcctSeed__GL_Account__c uc = new AcctSeed__GL_Account__c();
        uc.name = '1060-Unapplied Cash';
        uc.AcctSeed__Type__c = 'Balance Sheet';
        uc.AcctSeed__Sub_Type_1__c = 'Assets';
        uc.AcctSeed__Sub_Type_2__c = 'Cash';
        uc.AcctSeed__Active__c = true;
        
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
        solines.AcctSeedERP__Product__c = prodList[0].id;
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
            pol.AcctSeedERP__Product__c = prodList[0].id;
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
        ib.AcctSeedERP__Product__c = prodList[0].id;
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
        ib2.AcctSeedERP__Product__c = prodList[0].id;
        ib2.AcctSeedERP__Ledger__c = ledger.id;
        insert ib2;
        
        AcctSeedERP__Purchase_Order_Inventory_Movement__c poim2 = new AcctSeedERP__Purchase_Order_Inventory_Movement__c();
        poim2.AcctSeedERP__GL_Account_Variable_1__c = av.id;
        poim2.AcctSeedERP__Inventory_Balance__c = ib2.id;
        poim2.AcctSeedERP__Quantity__c = 2;
        poim2.AcctSeedERP__Purchase_Order_Line__c = polList[0].id;
        poim2.AcctSeedERP__Movement_Date__c = date.today();
        poim2.AcctSeedERP__Unit_Cost__c = 1;
        insert poim2;
        
        AcctSeedERP__Sales_Order_Inventory_Movement__c soim2 = new AcctSeedERP__Sales_Order_Inventory_Movement__c();
        soim2.AcctSeedERP__GL_Account_Variable_1__c = av.id;
        soim2.AcctSeedERP__Inventory_Balance__c = ib2.id;
        soim2.AcctSeedERP__Quantity__c = 1;
        soim2.AcctSeedERP__Movement_Date__c = date.today();
        soim2.AcctSeedERP__Sales_Order_Line__c = solines.id;
        soim2.AcctSeedERP__Unit_Cost__c = 1;
        insert soim2;

    }
    
    @isTest static void firstRun(){
        
        OPportunity opp = [select id from Opportunity where name = 'myOpportunity' limit 1];
        
        Quote qt = [select id from Quote where OpportunityId =: opp.id limit 1];
        
        AcctSeedERP__Sales_Order__c salesorder = [select id from AcctSeedERP__Sales_Order__c where
                                         AcctSeedERP__Opportunity__c =:opp.id limit 1];
        
        AcctSeedERP__Purchase_Order__c po = [select id from AcctSeedERP__Purchase_Order__c
                                          where Sales_order__c =:salesorder.id limit 1];
        
        Product2 prod = [select id,name,ProductImageURL__c from product2 where name = 'myProduct' limit 1];
        
        Pricebook2 pb2 = [select id from pricebook2 where name = 'myPriceBook' limit 1];
        
        PricebookEntry pricebentry2 = [select id,unitprice,product2Id,ProductCode,Product2.Size__c,Product2.Name, 
                                       Product2.Allow_Product_Description_Change__c, Product2.Allow_Custom_Image__c,
                                       Product2.Description,Product2.AcctSeed__Unit_Cost__c,Product2.ProductImageURL__c  
                                       from PricebookEntry where pricebook2id=:pb2.id limit 1];
        
        AcctSeedERP__Sales_Order_Line__c solines = [select id from AcctSeedERP__Sales_Order_Line__c where
                                                   AcctSeedERP__Sales_Order__c =:salesorder.id limit 1];
        
        AcctSeedERP__Purchase_Order_Line__c pol = [select id from AcctSeedERP__Purchase_Order_Line__c where
                                                   AcctSeedERP__Purchase_Order__c =:po.id limit 1];
        
        Test.startTest();
        
        PageReference myVfPage = Page.AddProductCustomVFPage;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id', Opp.Id);
        ApexPages.currentPage().getParameters().put('section', 'opo');
        
        AddProductCustomExtension exec = new AddProductCustomExtension();
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id', qt.Id);
        ApexPages.currentPage().getParameters().put('section', 'opq');
        
        AddProductCustomExtension exec2 = new AddProductCustomExtension();
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id', salesorder.Id);
        ApexPages.currentPage().getParameters().put('section', 'sli');
        
        AddProductCustomExtension exec3 = new AddProductCustomExtension();
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id', po.Id);
        ApexPages.currentPage().getParameters().put('section', 'pli');
        
        AddProductCustomExtension exec1 = new AddProductCustomExtension();

        //exec.priceBookCheck();
        exec.gotoCustomMultiLine();
        
        exec1.CancelButton();
        
        exec.QuoteId = null;
        Map<ID, String> prodnameis = new Map<ID, String>(); 
        
        prodnameis.put(prod.Id, prod.Name);
        
        exec.prodNames = prodnameis;
        
        //exec.nextRecords();
        
        Product2 productExample = new Product2();
        
        productExample.Category__c = 'Shower Door';
        productExample.Sub_Category__c = 'Single Sliding';
        
        exec.prod2 = productExample;
        exec.searchByCategories();
        exec.nextRecords();
        
        exec.CancelButton();
        
        Product2 productExample2 = new Product2();
        
        productExample2.Category__c = 'Shower Door';
        
        exec.prod2 = productExample2;
        exec.searchByCategories();
        exec.nextRecords();
        
        exec.searchByName();
        
        exec.searchText = 'myProduct';
        exec.selectedSearchVal = 'Name';
        
        exec.searchByName();
        
        exec.searchText = 'myProduct';
        exec.selectedSearchVal = 'Name';
        exec.nextRecords();
        
        exec.searchByName();
        
        exec.searchText = 'myProduct';
        
        //exec.selectedSearchVal = null;
        exec.nextRecords();

        AddProductCustomExtension.productSelection prodSelect = new AddProductCustomExtension.productSelection(pricebentry2);
        LIST<AddProductCustomExtension.productSelection> prods = new AddProductCustomExtension.productSelection[]{prodSelect};
        //LIST<Product2> prodcts = new LIST<Product2>();
        
        //prodcts.add(prod);
        
        
        exec.prods = prods;
        
        System.assert(exec.prods.size() > 0);
        
        // optional products opportunity
        
        exec.OP = null; 
        exec.section = 'opo';
        
        System.assert(exec.OP.size() > 0);
        LIST<Optional_Products_Opportunity__c> oop = new LIST<Optional_Products_Opportunity__c>();
        
        oop.add(New Optional_Products_Opportunity__c(
                                        Opportunity__c = opp.id,
                                        UnitPrice__c = pricebentry2.UnitPrice,
                                        Product__c = pricebentry2.Product2Id,
            							Quantity__c = 2
                                ));
        
        exec.OP = oop; 
        
        System.assert(exec.OP.size() > 0);
        
        
        
        exec.OPq = null; 
        exec.section = 'opq';
        
        // optional products quote
        System.assert(exec.OPq.size() > 0);
        LIST<Optional_Products_Quote__c> opq = new LIST<Optional_Products_Quote__c>();
        
        opq.add(New Optional_Products_Quote__c(
                                        Quote__c = qt.id,
                                        UnitPrice__c = pricebentry2.UnitPrice,
                                        Product__c = pricebentry2.Product2Id,
            							Quantity__c = 2
                                ));
        
        exec.OPq = opq; 
        
        System.assert(exec.OPq.size() > 0);
        
        
        exec.Oli = null; 
        exec.section = 'oli';
        
        // opportunity line items
        System.assert(exec.Oli.size() > 0);
        
        LIST<OpportunityLineItem> oli = new LIST<OpportunityLineItem>();
        
        oli.add(New OpportunityLineItem(
                                        OpportunityId = Opp.Id,
                                        UnitPrice = pricebentry2.UnitPrice,
                                        Product2Id = pricebentry2.Product2Id,
            							Quantity = 2
                                ));
        
        exec.Oli = oli; 
        
        System.assert(exec.Oli.size() > 0);
        
        
        exec.Qli = null; 
        exec.section = 'qli';
        
        // quote line items
        System.assert(exec.Qli.size() > 0);
        
        LIST<QuoteLineItem> qli = new LIST<QuoteLineItem>();
        
        qli.add(New QuoteLineItem(
                                        QuoteId = Opp.Id,
                                        UnitPrice = pricebentry2.UnitPrice,
                                        Product2Id = pricebentry2.Product2Id,
            							Quantity = 2
                                ));
        
        exec.Qli = qli; 
        
        System.assert(exec.Qli.size() > 0);
        

        exec.Sli = null; 
        exec.section = 'sli';
        // sales order line items
        System.assert(exec.Sli.size() > 0);
        // sales order lines
        LIST<acctseederp__sales_order_line__c> sli = new LIST<acctseederp__sales_order_line__c>();
        
        sli.add(solines);
        
        exec.Sli = sli; 
        
        System.assert(exec.Sli.size() > 0);
        
        //coverage for alternateImages method 
        ApexPages.currentPage().getParameters().put('prodID', pricebentry2.Product2Id);
        exec.alternateImages();
        
        // purchase order line items
        
        exec.Pli = null; 
        exec.section = 'pli';
        
        System.assert(exec.Pli.size() > 0);
         // purchase order lines
        LIST<acctseederp__purchase_order_line__c> pli = new LIST<acctseederp__purchase_order_line__c>();
        
        pli.add(pol);
        
        exec.Pli = pli; 
        
        System.assert(exec.Pli.size() > 0);



        
        
        system.assert(exec.SearchValList.size() > 0);
        
        // pagination tests
        //exec.headerText = '';
        exec.counter = 0;
        exec.list_size = 10;
        exec.total_size = 3;
        exec.getTotal_size();
        exec.getPageNumber();
        exec.getTotalPages();
        exec.headerText = '';
        
        exec.End();
        exec.disableNext = false;
        exec.Beginning();
        exec.disablePrevious = false;
        exec.Next();
        exec.Previous();
        
        //exec.headerText = '';
                
        exec.section = 'oli';
        exec.saveOP();
        exec.section = 'qli';
        exec.saveOP();
        exec.section = 'opo';
        exec.saveOP();
        exec.section = 'opq';
        exec.saveOP();
        exec.section = 'sli';
        exec.saveOP();
        exec.section = 'pli';
        exec.saveOP();
        
        exec.gotoParent();
        
        exec.section = 'oli';
        exec.saveMoreOP();
        exec.section = 'qli';
        exec.saveMoreOP();
        exec.section = 'opo';
        exec.saveMoreOP();
        exec.section = 'opq';
        exec.saveMoreOP();
        exec.section = 'sli';
        exec.saveMoreOP();
        exec.section = 'pli';
        exec.saveMoreOP();
        
        exec.gotoParentMore();
        
        exec.getStrTabName();
        
        exec.IfSingleProduct();
        ApexPages.currentPage().getParameters().put('id', null);
        exec.IfIdEmpty();
        //ApexPages.StandardController sc = new ApexPages.StandardController(Opp);
        //AssociateECPController ac = new AssociateECPController(sc);
    }
    
    @isTest static void secondRun(){
        
        OPportunity opp = [select id from Opportunity where name = 'myOpportunity' limit 1];
        
        Test.startTest();
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id', Opp.Id);
        ApexPages.currentPage().getParameters().put('section', 'opo');
        ApexPages.currentPage().getParameters().put('Sort', 'Product Name');
        
        AddProductCustomExtension execSort = new AddProductCustomExtension();
        execSort.ProductNameSortUp = true;
        execSort.checkSort();
        execSort.sortProcess = 'DESC';
        execSort.checkSort();
        
        ApexPages.currentPage().getParameters().put('Sort', 'Product Code');
        execSort.ProductCodeSortUp = true;
        execSort.checkSort();
        execSort.sortProcess = 'DESC';
        execSort.checkSort();
        
        ApexPages.currentPage().getParameters().put('Sort', 'Size');
        execSort.SizeSortUp = true;
        execSort.checkSort();
        execSort.sortProcess = 'DESC';
        execSort.checkSort();
        
        ApexPages.currentPage().getParameters().put('Sort', 'Unit Cost');
        execSort.UnitCostSortUp = true;
        execSort.checkSort();
        execSort.sortProcess = 'DESC';
        execSort.checkSort();
        
        Test.stopTest();
    }
    
}
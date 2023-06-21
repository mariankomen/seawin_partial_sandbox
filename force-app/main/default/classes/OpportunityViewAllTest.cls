@isTest
public with sharing class OpportunityViewAllTest {
    
    @testSetup static void CreateData(){
        
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'Seawin USA';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        Account acct = new Account();
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct;
        
        Contact cont = new Contact();
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.GL_Account_Variable_1__c = accVar.Id;
        insert cont;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        list<AcctSeed__Accounting_Variable__c> avList = new list<AcctSeed__Accounting_Variable__c>();
    	avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin China',AcctSeed__Type__c = 'GL Account Variable 1'));
        avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1'));
        insert avList;
        
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
        
        sales_rep__c salesrep = new sales_rep__c();
        salesrep.User__c = Userinfo.getUserId();
        salesrep.Active__c = 'Yes';
        salesrep.Name = 'New User';
        salesrep.Price_Level_1_12__c = 1;
        salesrep.Price_Level_13_20__c = 2;
        salesrep.Price_Level_21_26__c = 3;
        salesrep.Price_Level_27_30__c = 4;
        insert salesrep;

        Opportunity opp = new Opportunity();
        opp.Name = 'myOpportunity';
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Closed Won';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = accVar.id;
        opp.RecordTypeId = RecordTypeIdOpportunity;
        opp.Pricebook2Id = pricebookId;        
        opp.Sales_Rep_O__c = salesrep.id;
        insert opp;
        
        Quote qt = new Quote();
        qt.OpportunityId = opp.Id;
        qt.Name = 'myQuote';
        qt.Quote_Date__c = Date.today();
        qt.Pricebook2Id = pricebookId;
        insert qt;
        
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        
        gl.name = 'GL Account First';
        gl.AcctSeed__type__c = 'Balance Sheet';
        gl.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl.AcctSeed__Active__c = true;
        insert gl;
        
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
        
        PricebookEntry pricebentry = new PricebookEntry();
        pricebentry.Pricebook2Id = pricebookId;
  		pricebentry.Product2Id = prod.Id;
        pricebentry.UnitPrice = 100;
        pricebentry.IsActive = true;
        insert pricebentry;
        
        quotelineitem qlis = new quotelineitem();
        qlis.QuoteId = qt.id;
        qlis.Product2Id = prod.id;
        qlis.Quantity = 1;
        qlis.UnitPrice = 1;
        qlis.PricebookEntryId = pricebentry.id;
        insert qlis;

        Optional_Products_Opportunity__c opo = new Optional_Products_Opportunity__c();
        
        opo.Opportunity__c = opp.Id;
        opo.Description__c = 'myDescription';
        opo.Item_Description__c = 'myItemDescription';
        opo.Product__c = prod.Id;
        opo.Quantity__c = 2;
        opo.UnitPrice__c = 10;
        opo.PriceBookEntryId__c = pricebentry.id;
        
        insert opo;

        OpportunityLineItem oli = new OpportunityLineItem();
        
        oli.OpportunityId = opp.Id;
        oli.Product2Id = prod.Id;
        oli.PricebookEntryId = pricebentry.Id;
        oli.Quantity = 10;
        oli.UnitPrice = 100;
        oli.Description = 'myDescription';
        
        insert oli;

        Account acct2 = new Account();
        acct2.Name = 'Sales Represantative';
        acct2.Type = 'Designer';
        acct2.AcctSeed__Accounting_Type__c = 'Sales Represantative';
        acct2.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        acct2.Price_Level_1_12__c = 1;
        acct2.Price_Level_13_20__c = 1;
        acct2.Price_Level_21_26__c = 1;
        acct2.Price_Level_27_30__c = 1;

        insert acct2;

        AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();

        abf.Name = 'newPDF Format';
        abf.AcctSeed__Type__c = 'Purchase Order';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';

        insert abf;
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = accVar.Id;

        insert aegl;
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

        Id RecordTypeIdSO = Schema.SObjectType.AcctSeedERP__Sales_Order__c.getRecordTypeInfosByName()
        .get('Seawin USA Hospitality')
        .getRecordTypeId();

        // create a sales order
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c();

        //salesorder.name = 'testSalesOrder';
        salesorder.RecordTypeId = RecordTypeIdSO;
        salesorder.AcctSeedERP__Customer__c = acct.Id;
        salesorder.AcctSeedERP__Opportunity__c = opp.Id;
        salesorder.Manufacturer_Rep__c = acct2.id;
        salesorder.Contact__c = cont.Id;
        salesorder.Price_Level__c = 'Level 3';
        salesorder.AcctSeedERP__Status__c = 'Open';
        salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.GL_Account_Variable_1__c = accVar.Id;
        salesorder.Commission_Rate_Sales_Rep__c = 1;
        salesorder.Commission_Rate_Referral_Sales_Rep__c = 1;
        salesorder.Commission_Rate_Manufacturer_Rep__c = 1;
        insert salesorder;

        // create a sales order
        AcctSeedERP__Sales_Order_Line__c soline = new AcctSeedERP__Sales_Order_Line__c();

        soline.AcctSeedERP__Sales_Order__c = salesorder.id;
        soline.AcctSeedERP__Unit_Price__c = 100;
        soline.AcctSeedERP_Description__c = 'This is salesorder line item';
        soline.AcctSeedERP__Product__c = prod.id;
        soline.AcctSeedERP__Quantity_Ordered__c = 1;

        insert soline;

        acctseederp__purchase_order__c po = new acctseederp__purchase_order__c();
        
        po.AcctSeedERP__Order_Date__c = date.today();
        //po.AcctSeedERP__Status__c = 'Open';
        po.AcctSeedERP__Type__c = 'Standard';
        po.AcctSeedERP__Purchase_Order_Format__c = abf.Id;
        po.AcctSeedERP__Ledger__c = ledger.Id;
        po.GL_Account_Variable_1__c = accVar.id;
        po.Sales_Order__c = salesorder.id;
        po.AcctSeedERP__Vendor__c = acct.Id;
        
        insert po;
        

        List<acctseederp__purchase_order_line__c> polList = new List<acctseederp__purchase_order_line__c>();
        for(integer i=0; i<3; i++){
            acctseederp__purchase_order_line__c pol = new acctseederp__purchase_order_line__c();
            pol.AcctSeedERP__Product__c = prod.id;
            pol.AcctSeedERP__Quantity__c = 2;
            pol.AcctSeedERP__Purchase_Order__c = po.id;
            pol.AcctSeedERP__Unit_Price__c = 1;
            polList.add(pol);
        }
        insert polList;
    }

    @isTest
    public static void viewAllTestOpportunity(){
        Opportunity opp = [select id,Name from Opportunity where name='myOpportunity' limit 1];
        Quote quote = [select id,Name from Quote where OpportunityId =: opp.id limit 1];
        QuoteLineItem qli = [select id from QuoteLineItem where QuoteId =: quote.id limit 1];
        
        test.startTest();
		        
        PageReference pageRef = Page.OpportunityProductsViewAll;
        Test.setCurrentPage(pageRef);
		
        ApexPages.currentPage().getParameters().put('recordId', opp.id);
        ApexPages.currentPage().getParameters().put('optional', 'false');
        
        OpportunityViewAll ctrl = new OpportunityViewAll();
        // ctrl.fetchOpportunityProducts();
        ctrl.back();

    }
    @isTest
    public static void viewAllTestOptionalOpportunity(){
        Opportunity opp = [select id,Name from Opportunity where name='myOpportunity' limit 1];
        
        test.startTest();
		        
        PageReference pageRef = Page.OpportunityProductsViewAll;
        Test.setCurrentPage(pageRef);
		
        ApexPages.currentPage().getParameters().put('recordId', opp.id);
        ApexPages.currentPage().getParameters().put('optional', 'true');
        
        OpportunityViewAll ctrl = new OpportunityViewAll();
        // ctrl.fetchOpportunityProducts();
        ctrl.back();

    }
    @isTest
    public static void viewAllTestOptionalSO(){
        AcctSeedERP__Sales_Order__c so = [select id,Name from AcctSeedERP__Sales_Order__c limit 1];
        
        test.startTest();
		        
        PageReference pageRef = Page.OpportunityProductsViewAll;
        Test.setCurrentPage(pageRef);
		
        ApexPages.currentPage().getParameters().put('recordId', so.id);
        ApexPages.currentPage().getParameters().put('optional', 'false');
        
        OpportunityViewAll ctrl = new OpportunityViewAll();
        // ctrl.fetchOpportunityProducts();
        ctrl.back();

    }
    @isTest
    public static void viewAllTestOptionalPO(){
        acctseederp__purchase_order__c po = [select id,Name from acctseederp__purchase_order__c limit 1];
        
        test.startTest();
		        
        PageReference pageRef = Page.OpportunityProductsViewAll;
        Test.setCurrentPage(pageRef);
		
        ApexPages.currentPage().getParameters().put('recordId', po.id);
        ApexPages.currentPage().getParameters().put('optional', 'false');
        
        OpportunityViewAll ctrl = new OpportunityViewAll();
        // ctrl.fetchOpportunityProducts();
        ctrl.back();

    }

    
}
@isTest
public class DeAllocateSOLinesControllerTest {
    
    @testSetup static void createData(){
       AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c(Name = 'Seawin Factory', 
                                                                                                   AcctSeed__Type__c = 'GL Account Variable 1');
        insert av;
        // Profile pf = [Select Id from profile where Name = 'System Administrator']; 
        Profile pf = [Select Id from profile where Name = 'Sales Rep'];
         
        String orgId = UserInfo.getOrganizationId(); 
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName = orgId + dateString + RandomId; 
        
        User uu1 = new User(firstname = 'ABC', 
                             lastName = 'XYZ', 
                             email = uniqueName + '@test' + orgId + '.org', 
                             Username = uniqueName + '@test' + orgId + '.org', 
                             EmailEncodingKey = 'ISO-8859-1', 
                             Alias = uniqueName.substring(18, 23), 
                             TimeZoneSidKey = 'America/Los_Angeles', 
                             LocaleSidKey = 'en_US', 
                             LanguageLocaleKey = 'en_US', 
                             ProfileId = pf.Id
                            ); 

        insert uu1;
        
        Sales_rep__c sr = new Sales_rep__c();
        sr.Active__c = 'Yes';
        sr.Name = 'John Doe';
        sr.User__c = uu1.id;
        
        insert sr;
        
        uu1.Sales_Rep_Id__c = sr.id;
        
        update uu1;
        
        // create account
        Account acct = new Account();
        
        acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        
        insert acct;
		
        // create contact
        Contact cont = new Contact();
        
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        
        insert cont;
        
        AcctSeed__GL_Account__c cyeGL = new AcctSeed__GL_Account__c();
        cyeGL.name = 'current year GL Acc';
        cyeGL.AcctSeed__Type__c = 'Balance Sheet';
        cyeGL.AcctSeed__Sub_Type_1__c = 'Assets';
        cyeGL.AcctSeed__Sub_Type_2__c = 'Cash';
        cyeGL.AcctSeed__Bank__c = true;
        insert cyeGL;
        
        AcctSeed__GL_Account__c reGL = new AcctSeed__GL_Account__c();
        reGL.name = 'Retained earnings GL Acc';
        reGL.AcctSeed__Type__c = 'Balance Sheet';
        reGL.AcctSeed__Sub_Type_1__c = 'Assets';
        reGL.AcctSeed__Sub_Type_2__c = 'Cash';
        reGL.AcctSeed__Bank__c = true;
        insert reGL;
        
        AcctSeed__GL_Account__c rvGL = new AcctSeed__GL_Account__c();
        rvGL.name = 'Revenue GL Acc';
        rvGL.AcctSeed__Type__c = 'Balance Sheet';
        rvGL.AcctSeed__Sub_Type_1__c = 'Assets';
        rvGL.AcctSeed__Sub_Type_2__c = 'Cash';
        rvGL.AcctSeed__Bank__c = true;
        insert rvGL;
        
        AcctSeed__GL_Account__c arcGL = new AcctSeed__GL_Account__c();
        arcGL.name = 'AR Control GL Acc';
        arcGL.AcctSeed__Type__c = 'Balance Sheet';
        arcGL.AcctSeed__Sub_Type_1__c = 'Assets';
        arcGL.AcctSeed__Sub_Type_2__c = 'Cash';
        arcGL.AcctSeed__Bank__c = true;
        insert arcGL;
        
        AcctSeed__GL_Account__c apGL = new AcctSeed__GL_Account__c();
        apGL.name = 'AP Control GL Acc';
        apGL.AcctSeed__Type__c = 'Balance Sheet';
        apGL.AcctSeed__Sub_Type_1__c = 'Assets';
        apGL.AcctSeed__Sub_Type_2__c = 'Cash';
        apGL.AcctSeed__Bank__c = true;
        insert apGL;
        
        AcctSeed__GL_Account__c uARGL = new AcctSeed__GL_Account__c();
        uARGL.name = 'Unapplied A/R GL Acc';
        uARGL.AcctSeed__Type__c = 'Balance Sheet';
        uARGL.AcctSeed__Sub_Type_1__c = 'Assets';
        uARGL.AcctSeed__Sub_Type_2__c = 'Cash';
        insert uARGL;
        
        // create product
        Product2 prod = new Product2();
        
        prod.Name = 'myProduct';
        prod.ProductCode = 'ABC123';
        prod.AcctSeed__Unit_Cost__c = 100;
        prod.IsActive = true;
        prod.AcctSeed__Inventory_Type__c = 'Purchased';
        prod.AcctSeed__Inventory_Product__c = true;
        prod.AcctSeed__Expense_GL_Account__c = cyeGL.id;
        prod.AcctSeed__Inventory_GL_Account__c = cyeGL.id;
        prod.AcctSeed__Revenue_GL_Account__c = cyeGL.id;
        
        insert prod;
        
        // create opportunity
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.Sales_Rep_O__c = sr.id;
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Follow up';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        
        insert opp;
        
        // create pricebook2
        Pricebook2 priceb2 = new Pricebook2();
        
        priceb2.Name = 'myPriceBook';
        priceb2.Description = 'myPBDescription';
        priceb2.IsActive = true;
        //priceb2.IsStandard = true;
        
        insert priceb2;
        
        // insert to standard price book
        Id pricebookId = Test.getStandardPricebookId();
        
        // create standard price book entry
        PricebookEntry pricebentry1 = new PricebookEntry();
        
        pricebentry1.Pricebook2Id = pricebookId;
  		pricebentry1.Product2Id = prod.Id;
        pricebentry1.UnitPrice = 100;
        pricebentry1.IsActive = true;
        
        insert pricebentry1;
        
        // create pricebookentry
        PricebookEntry pricebentry2 = new PricebookEntry();
        
        pricebentry2.Pricebook2Id = priceb2.Id;
  		pricebentry2.Product2Id = prod.Id;
        pricebentry2.UnitPrice = 100;
        pricebentry2.IsActive = true;
        
        insert pricebentry2;
        
        // create opportunity line item
        
        OpportunityLineItem oli = new OpportunityLineItem();
        
        oli.OpportunityId = opp.Id;
        oli.Product2Id = prod.Id;
        oli.PricebookEntryId = pricebentry2.Id;
        oli.Quantity = 10;
        oli.UnitPrice = 100;
        oli.Description = 'myDescription';
        
        insert oli;
        
        AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();
        
        abf.Name = 'newPDF Format';
        abf.AcctSeed__Type__c = 'Purchase Order';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        insert abf;
        
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
        
        ledger.Name = 'Actual';
        ledger.AcctSeed__Type__c = 'Transactional';
        ledger.AcctSeed__Default_Bank_Account__c = cyeGL.id;
        ledger.AcctSeed__Billing_Activity_Statement_Format__c = abf.id;
        ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = abf.id;
        ledger.AcctSeed__Default_Billing_Format__c = abf.id;
        ledger.AcctSeed__Default_Packing_Slip_Format__c = abf.id;
        ledger.AcctSeed__Default_Purchase_Order_Format__c = abf.id;
        
        insert ledger;
        
        // create a sales order
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c(); 
        
        //salesorder.name = 'testSalesOrder';
        salesorder.AcctSeedERP__Customer__c = acct.Id;
        salesorder.AcctSeedERP__Opportunity__c = opp.Id;
        salesorder.Contact__c = cont.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
       	salesorder.AcctSeedERP__Ledger__c = ledger.id;

        insert salesorder;
        
        // create a sales order
        List<AcctSeedERP__Sales_Order_Line__c> solineList = new List<AcctSeedERP__Sales_Order_Line__c>();
        
        AcctSeedERP__Sales_Order_Line__c solines = new AcctSeedERP__Sales_Order_Line__c(); 
        
        solines.AcctSeedERP__Sales_Order__c = salesorder.id;
        solines.AcctSeedERP__Unit_Price__c = 1;
        solines.AcctSeedERP_Description__c = 'This is salesorder line item';
        solines.AcctSeedERP__Product__c = prod.id;
        solines.AcctSeedERP__Quantity_Ordered__c = 1;
        
        insert solines;
        
        acctseederp__purchase_order__c po = new acctseederp__purchase_order__c();
        
        po.AcctSeedERP__Order_Date__c = date.today();
        po.AcctSeedERP__Status__c = 'Open';
        po.AcctSeedERP__Type__c = 'Standard';
        po.AcctSeedERP__Purchase_Order_Format__c = abf.Id;
        po.AcctSeedERP__Ledger__c = ledger.Id;
        po.Sales_Order__c = salesorder.id;
        po.AcctSeedERP__Vendor__c = acct.id;
        insert po;
        
        acctseederp__purchase_order_line__c pol = new acctseederp__purchase_order_line__c();
        
        pol.AcctSeedERP__Product__c = prod.id;
        pol.AcctSeedERP__Quantity__c = 1;
        pol.AcctSeedERP__Purchase_Order__c = po.id;
        pol.AcctSeedERP__Unit_Price__c = 1;
        
        insert pol;
        
        // accounting period
       	AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        
        Date dates = date.today();
        
        Integer monthDays = date.daysInMonth(dates.year(), dates.month());
        
        ap.Name = dates.year() + '-0' + dates.month();
        ap.AcctSeed__Status__c = 'Open';
        ap.AcctSeed__Start_Date__c = Date.newInstance(dates.year(), dates.month(), dates.day());
        ap.AcctSeed__End_Date__c = Date.newInstance(dates.year(), dates.month(), monthDays);
        
        insert ap;
        
        system.debug(ap);
		
        AcctSeed__GL_Account__c vch = new AcctSeed__GL_Account__c();
        vch.name = '2010-Vouchers Payable';
        vch.AcctSeed__Type__c = 'Balance Sheet';
        vch.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch.AcctSeed__Active__c = true;
        
        insert vch;
        
        // Account Settings
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
        ib.AcctSeedERP__Ledger__c = ledger.id; // this was missing
        insert ib;

        AcctSeed__Accounting_Settings__c custm = new AcctSeed__Accounting_Settings__c();
        custm.AcctSeed__Default_Ledger__c = ledger.id;
        custm.AcctSeed__Revenue_GL_Account__c = rvGL.id; 
        custm.AcctSeed__AR_Control_GL_Account__c = arcGL.id;
        custm.AcctSeed__Vouchers_Payable_GL_Account__c = vch.id;
        custm.AcctSeed__Current_Year_Earnings_GL_Account__c = cyeGL.id; 
        custm.AcctSeed__AP_Control_GL_Account__c= apGL.id;
        custm.AcctSeed__Retained_Earnings_GL_Account__c =reGL.id;
        custm.AcctSeed__Unapplied_Cash_GL_Account__c =uARGL.id;
		insert custm;
            
		AcctSeedERP__Purchase_Order_Inventory_Movement__c poim = new AcctSeedERP__Purchase_Order_Inventory_Movement__c();
		poim.AcctSeedERP__GL_Account_Variable_1__c = av.id;
		poim.AcctSeedERP__Inventory_Balance__c = ib.id;
        poim.AcctSeedERP__Quantity__c = 2;
        poim.AcctSeedERP__Purchase_Order_Line__c = pol.id;
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
        

    }
    
    @isTest static void starttheTest(){
        Opportunity opp = [select id from opportunity where name='myOpportunity' limit 1];
        
        acctseederp__sales_order__c so = [select id,name from acctseederp__sales_order__c 
                                          where acctseederp__opportunity__c =:opp.id limit 1];
        
        acctseederp__sales_order_Line__c sol = [select id from acctseederp__sales_order_Line__c  
                                          where acctseederp__sales_order__c =:so.id limit 1];
        
        
        
        PageReference pageRef = Page.DeAllocateSOLinesPage;
        Test.setCurrentPage(pageRef);
		
        ApexPages.currentPage().getParameters().put('id', so.Id);
        ApexPages.currentPage().getParameters().put('name', so.name);
        ApexPages.currentPage().getParameters().put('id0', sol.Id);
        ApexPages.currentPage().getParameters().put('count', '1');
     
     	DeAllocateSOLinesController dasc = new DeAllocateSOLinesController();
        
        dasc.deleteInventoryMovements();
        dasc.DoRedirect();

    }
}
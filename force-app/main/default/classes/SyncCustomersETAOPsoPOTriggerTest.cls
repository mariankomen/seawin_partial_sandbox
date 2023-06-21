@isTest
public class SyncCustomersETAOPsoPOTriggerTest {
    
    @testsetup static void CreateData() 
 	{
        
        list<AcctSeed__Accounting_Variable__c> avList = new list<AcctSeed__Accounting_Variable__c>();
        
    	avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin China',AcctSeed__Type__c = 'GL Account Variable 1'));
        
        avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1'));
        insert avList;
        
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
        
        Id RecordTypeIdSO = Schema.SObjectType.AcctSeedERP__Sales_Order__c.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();

        // Accounting Period
        Date dt = date.today();
        
        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        ap.name = dt.year() + '-' + ((dt.month() < 10)?'0' + dt.month():String.ValueOf(dt.month()));
        system.debug(dt.year() + '-' + ((dt.month() < 9)?Integer.ValueOf('0' + dt.month()):dt.month()));
        ap.AcctSeed__Start_Date__c = Date.today() - (dt.day() - 1);
        ap.AcctSeed__End_Date__c = Date.today() + 28;
        ap.AcctSeed__Status__c = 'Open';
        insert ap;
        
    	// create account
        
        Account acct = new Account();
        
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__Billing_Terms_Name__c = 'Example terms';
        acct.AcctSeed__GL_Account_Variable_1__c = avList[1].id;
        
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
        
        AcctSeed__GL_Account__c vch = new AcctSeed__GL_Account__c();
        vch.name = '2010-Vouchers Payable';
        vch.AcctSeed__Type__c = 'Balance Sheet';
        vch.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch.AcctSeed__Active__c = true;
        
        glList.add(vch);
        
        AcctSeed__GL_Account__c vch1 = new AcctSeed__GL_Account__c();
        vch1.name = '2010-Vouchers Payable1';
        vch1.AcctSeed__Type__c = 'Balance Sheet';
        vch1.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch1.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch1.AcctSeed__Active__c = true;
        
        glList.add(vch1);
        
        AcctSeed__GL_Account__c vch2 = new AcctSeed__GL_Account__c();
        vch2.name = '2010-Vouchers Payable2';
        vch2.AcctSeed__Type__c = 'Balance Sheet';
        vch2.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch2.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch2.AcctSeed__Active__c = true;
        
        glList.add(vch2);
        
        AcctSeed__GL_Account__c vch3 = new AcctSeed__GL_Account__c();
        vch3.name = '2010-Vouchers Payable3';
        vch3.AcctSeed__Type__c = 'Balance Sheet';
        vch3.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch3.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch3.AcctSeed__Active__c = true;
        
        glList.add(vch3);
        
        AcctSeed__GL_Account__c gl1 = new AcctSeed__GL_Account__c();
        gl1.name = '2010-Vouchers Payable1';
        gl1.AcctSeed__Type__c = 'Balance Sheet';
        gl1.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl1.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl1.AcctSeed__Active__c = true;
        
        glList.add(gl1);
        
        AcctSeed__GL_Account__c gl2 = new AcctSeed__GL_Account__c();
        gl2.name = '2010-Vouchers Payable2';
        gl2.AcctSeed__Type__c = 'Balance Sheet';
        gl2.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl2.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl2.AcctSeed__Active__c = true;
        
        glList.add(gl2);
        
        AcctSeed__GL_Account__c gl3 = new AcctSeed__GL_Account__c();
        gl3.name = '2010-Vouchers Payable3';
        gl3.AcctSeed__Type__c = 'Balance Sheet';
        gl3.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl3.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl3.AcctSeed__Active__c = true;
        
        glList.add(gl3);
        
        AcctSeed__GL_Account__c gl4 = new AcctSeed__GL_Account__c();
        gl4.name = '2010-Vouchers Payable4';
        gl4.AcctSeed__Type__c = 'Balance Sheet';
        gl4.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl4.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl4.AcctSeed__Active__c = true;
        
        glList.add(gl4);
        
        insert glList;
        
        sales_rep__c salesrep = new sales_rep__c();
        
        salesrep.User__c = Userinfo.getUserId();
        salesrep.Active__c = 'Yes';
        salesrep.Name = 'New User';
        salesrep.Price_Level_1_12__c = 1;
        salesrep.Price_Level_13_20__c = 2;
        salesrep.Price_Level_21_26__c = 3;
        salesrep.Price_Level_27_30__c = 4;
        
        insert salesrep;
        
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
        
        // create opportunity
        
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Closed Won';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = avList[0].id;
        opp.RecordTypeId = RecordTypeIdOpportunity;
        opp.Pricebook2Id = pricebookId;
        //opp.IsApproved__c= false;
        opp.Sales_Rep_O__c = salesrep.id;
        
        insert opp;
        
        list<opportunitylineitem> l1List = new list<opportunitylineitem>();
        
        opportunitylineitem l1 = new opportunitylineitem();
        
        l1.Quantity = 2;
        l1.UnitPrice = 2;
        l1.Product2Id = prod.id;
        l1.PricebookEntryId = pricebentry.id;
        l1.OpportunityId = opp.id;
        
        insert l1;

        
        // create quote
        Quote qt = new Quote();
        
        qt.OpportunityId = opp.Id;
        //qt.AccountId = acct.Id;
        qt.Name = 'myQuote';
        qt.Quote_Date__c = Date.today();
        qt.Pricebook2Id = pricebookId;
        
        insert qt;
        
        //----------------------- Quote Line Items

        quotelineitem qlis = new quotelineitem();
        
        qlis.QuoteId = qt.id;
        qlis.Product2Id = prod.id;
        qlis.Quantity = 1;
        qlis.UnitPrice = 1;
        qlis.PricebookEntryId = pricebentry.id;

        insert qlis;
        
        list<AcctSeed__Billing_Format__c> abfList = new list<AcctSeed__Billing_Format__c>();
        
        AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();
        
        abf.Name = 'newPDF Format';
        abf.AcctSeed__Type__c = 'Purchase Order';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        abfList.add(abf);

        AcctSeed__Billing_Format__c abf2 = new AcctSeed__Billing_Format__c();
        
        abf2.Name = 'Default Purchase Order';
        abf2.AcctSeed__Type__c = 'Purchase Order';
        abf2.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf2.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        abfList.add(abf2);
        
        insert abfList;

        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
        
        ledger.Name = 'myLedger';
        ledger.AcctSeed__Type__c = 'Transactional';
        ledger.AcctSeed__Billing_Activity_Statement_Format__c = abfList[0].id;
        ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = abfList[0].id;
        ledger.AcctSeed__Default_Bank_Account__c = glList[1].id;
        ledger.AcctSeed__Default_Billing_Format__c = abfList[0].id; 
        ledger.AcctSeed__Default_Purchase_Order_Format__c = abfList[0].id;
        ledger.AcctSeed__Default_Packing_Slip_Format__c = abfList[0].id;
        
        insert ledger;
        
        // create a sales order
        
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c(); 
        
        salesorder.AcctSeedERP__Customer__c = acct.Id;
        salesorder.AcctSeedERP__Opportunity__c = opp.Id;
        salesorder.Contact__c = cont.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
       	salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.GL_Account_Variable_1__c = avList[0].id;
        salesorder.Stage__c = 'Production';
        salesorder.RecordTypeId = RecordTypeIdSO;
        salesorder.Sales_Rep_O__c = salesrep.id;

        insert salesorder;
        
        // create a sales order lines
        AcctSeedERP__Sales_Order_Line__c solines = new AcctSeedERP__Sales_Order_Line__c(); 
        
        solines.AcctSeedERP__Sales_Order__c = salesorder.id;
        solines.AcctSeedERP__Unit_Price__c = 1.1;
        solines.AcctSeedERP_Description__c = 'This is salesorder line item';
        solines.AcctSeedERP__Product__c = prod.id;
        solines.AcctSeedERP__Quantity_Ordered__c = 2;
        
        insert solines;
        // -----------------------
        
        AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
        
        bill.AcctSeed__Status__c = 'Approved';
        bill.AcctSeed__PDF_Email_Status__c = 'Unsent';
        bill.AcctSeed__Billing_Format__c = abfList[0].id;
        bill.AcctSeedERP__Sales_Order__c = salesorder.id; 
        bill.AcctSeed__Date__c = Date.Today();
        bill.AcctSeed__Due_Date2__c = Date.Today();
        bill.AcctSeed__Ledger__c = ledger.id;
        bill.AcctSeed__Opportunity__c = opp.id;
        bill.AcctSeed__Customer__c = acct.id;
        bill.AcctSeed__Accounting_Period__c = ap.id;

        insert bill;
        
        AcctSeed__Billing_Line__c bline = new AcctSeed__Billing_Line__c();
        bline.AcctSeed__Billing__c = bill.id;
        bline.AcctSeed__Date__c = date.today();
        bline.AcctSeed__Hours_Units__c = 1;
        bline.AcctSeed__Product__c = prod.id;
        bline.AcctSeedERP__Sales_Order_Line__c = solines.id;
        bline.AcctSeed__Rate__c = solines.AcctSeedERP__Unit_Price__c;
        bline.Item_Description__c = solines.Item_Description__c;
        
        insert bline;
        
        acctseederp__purchase_order__c po = new acctseederp__purchase_order__c();
        
        po.AcctSeedERP__Order_Date__c = date.today();
        po.AcctSeedERP__Status__c = 'Open';
        po.AcctSeedERP__Type__c = 'Drop Shipment';
        po.Stage__c = 'In Production';
        po.AcctSeedERP__Purchase_Order_Format__c = abfList[0].Id;
        po.AcctSeedERP__Ledger__c = ledger.Id;
        po.GL_Account_Variable_1__c = avList[0].id;
        po.Sales_Order__c = salesorder.id;
        po.AcctSeedERP__Vendor_Contact__c = cont.id;
        po.AcctSeedERP__Vendor__c = acct.id;
        
        insert po;
        
        acctseederp__purchase_order_line__c pol = new acctseederp__purchase_order_line__c();
        
        pol.AcctSeedERP__Product__c = prod.id;
        pol.AcctSeedERP__Quantity__c = 4;
        pol.AcctSeedERP__Purchase_Order__c = po.id;
        pol.AcctSeedERP__Unit_Price__c = 1;
        
        insert pol;
        
    }
    
    @isTest static void ProcessOpportunityETA(){
        Opportunity opp = [select id, deliver_by__c from 
                           opportunity where name='myOpportunity' limit 1];
        
        opp.deliver_by__c = date.today();
        opp.Run_Validation_Rule__c = true;
        
        
        update opp;
        
        

    }

    @isTest static void ProcessSOETA(){
        Opportunity opp = [select id, ContactPerson__c from opportunity where name='myOpportunity' limit 1];
        
        acctseederp__sales_order__c so = [select id, customer_s_eta__c from acctseederp__sales_order__c 
                                          where acctseederp__opportunity__c =:opp.id limit 1];
        
        
        so.customer_s_eta__c = date.today() + 1;
        
        update so;
        
        

    }
    @isTest static void ProcessPOETA(){
        Opportunity opp = [select id, ContactPerson__c from opportunity where name='myOpportunity' limit 1];
        
        acctseederp__sales_order__c so = [select id, Contact__c from acctseederp__sales_order__c 
                                          where acctseederp__opportunity__c =:opp.id limit 1];
        
        
        acctseederp__purchase_order__c po = [select id, Customer_s_eta__c from acctseederp__purchase_order__c 
                                          where sales_order__c =:so.id limit 1];
        
        po.Customer_s_ETA__c = date.today() + 2;
        
        update po;
        

    }

}
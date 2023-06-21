@isTest
public class InStockQuantityHandlerTest {
    
    @TestSetup static void MakeData(){
        
        Id KitRecordTypeId = 
            Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Kit').getRecordTypeId();
        Id ProductRecordTypeId = 
            Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId();
        
        AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c();
        av.Name = 'GL acc var1';
        av.AcctSeed__Type__c = 'GL Account Variable 1';
        insert av;
        
        // create account
        Account acct = new Account();
        //acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = av.Id;
        insert acct;
        
        // create contact
        Contact cont = new Contact();
        
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.GL_Account_Variable_1__c = av.Id;
        insert cont;
        
        list<AcctSeed__GL_Account__c> glList = new list<AcctSeed__GL_Account__c>();
        
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        
        gl.name = 'GL Account First';
        gl.AcctSeed__type__c = 'Balance Sheet';
        gl.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl.AcctSeed__Active__c = true;
        gl.GL_Account_Variable_1__c = av.id;
        
        glList.add(gl);
        
        
        // ledger creation
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = av.id;
        
        glList.add(aegl);
        
        AcctSeed__GL_Account__c vch = new AcctSeed__GL_Account__c();
        vch.name = '2010-Vouchers Payable';
        vch.AcctSeed__Type__c = 'Balance Sheet';
        vch.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch.AcctSeed__Active__c = true;
        vch.GL_Account_Variable_1__c = av.id;
        
        glList.add(vch);
        
        AcctSeed__GL_Account__c vch1 = new AcctSeed__GL_Account__c();
        vch1.name = '2010-Vouchers Payable1';
        vch1.AcctSeed__Type__c = 'Balance Sheet';
        vch1.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch1.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch1.AcctSeed__Active__c = true;
        vch1.GL_Account_Variable_1__c = av.id;
        
        glList.add(vch1);
        
        AcctSeed__GL_Account__c vch2 = new AcctSeed__GL_Account__c();
        vch2.name = '2010-Vouchers Payable2';
        vch2.AcctSeed__Type__c = 'Balance Sheet';
        vch2.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch2.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch2.AcctSeed__Active__c = true;
        vch.GL_Account_Variable_1__c = av.id;
        
        glList.add(vch2);
        
        AcctSeed__GL_Account__c vch3 = new AcctSeed__GL_Account__c();
        vch3.name = '2010-Vouchers Payable3';
        vch3.AcctSeed__Type__c = 'Balance Sheet';
        vch3.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch3.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch3.AcctSeed__Active__c = true;
        vch3.GL_Account_Variable_1__c = av.id;
        
        glList.add(vch3);
        
        AcctSeed__GL_Account__c gl1 = new AcctSeed__GL_Account__c();
        gl1.name = '2010-Vouchers Payable1';
        gl1.AcctSeed__Type__c = 'Balance Sheet';
        gl1.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl1.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl1.AcctSeed__Active__c = true;
        gl1.GL_Account_Variable_1__c = av.id;
        
        glList.add(gl1);
        
        AcctSeed__GL_Account__c gl2 = new AcctSeed__GL_Account__c();
        gl2.name = '2010-Vouchers Payable2';
        gl2.AcctSeed__Type__c = 'Balance Sheet';
        gl2.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl2.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl2.AcctSeed__Active__c = true;
        gl2.GL_Account_Variable_1__c = av.id;
        
        glList.add(gl2);
        
        AcctSeed__GL_Account__c gl3 = new AcctSeed__GL_Account__c();
        gl3.name = '2010-Vouchers Payable3';
        gl3.AcctSeed__Type__c = 'Balance Sheet';
        gl3.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl3.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl3.AcctSeed__Active__c = true;
        gl3.GL_Account_Variable_1__c = av.id;
        
        glList.add(gl3);
        
        AcctSeed__GL_Account__c gl4 = new AcctSeed__GL_Account__c();
        gl4.name = '2010-Vouchers Payable4';
        gl4.AcctSeed__Type__c = 'Balance Sheet';
        gl4.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl4.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl4.AcctSeed__Active__c = true;
        gl4.GL_Account_Variable_1__c = av.id;
        
        glList.add(gl4);
        
        AcctSeed__GL_Account__c gl5 = new AcctSeed__GL_Account__c();
        gl5.Name = 'GL Revenue Account Example';
        gl5.AcctSeed__Active__c = true;
        gl5.AcctSeed__Type__c = 'Revenue';
        gl5.AcctSeed__Sub_Type_1__c = 'Product Revenue';
        gl5.AcctSeed__Sub_Type_2__c = 'Product Family 1';
        gl5.AcctSeed__Bank__c = false;
        gl5.GL_Account_Variable_1__c = av.id;
        
        glList.add(gl5);
        
        insert glList;
        
        // create product
        Product2 prod = new Product2();
        
        prod.Name = 'myProduct';
        prod.ProductCode = 'ABC123';
        prod.AcctSeed__Unit_Cost__c = 100;
        prod.IsActive = true;
        prod.AcctSeed__Inventory_Type__c = 'Purchased';
        prod.recordtypeid = ProductRecordTypeId;
        prod.AcctSeed__Expense_GL_Account__c = gl5.id;
        prod.AcctSeed__Inventory_GL_Account__c = gl5.id;
        prod.AcctSeed__Revenue_GL_Account__c = gl5.id;
        prod.AcctSeed__Inventory_Product__c = true;
        insert prod;
        
        // create product
        Product2 kit = new Product2();
        
        kit.Name = 'myKitProduct';
        kit.ProductCode = 'ABC123';
        kit.AcctSeed__Unit_Cost__c = 100;
        kit.IsActive = true;
        kit.AcctSeed__Inventory_Type__c = 'Kit';
        kit.recordtypeid = KitRecordTypeId;
        kit.AcctSeed__Expense_GL_Account__c = gl5.id;
        kit.AcctSeed__Inventory_GL_Account__c = gl5.id;
        kit.AcctSeed__Revenue_GL_Account__c = gl5.id;
        insert kit;
        
        Product2 kitproduct = new Product2();
        
        kitproduct.Name = 'myProduct';
        kitproduct.ProductCode = 'ABC123';
        kitproduct.AcctSeed__Unit_Cost__c = 100;
        kitproduct.IsActive = true;
        kitproduct.AcctSeed__Inventory_Type__c = 'Purchased';
        kitproduct.recordtypeid = ProductRecordTypeId;
        kitproduct.AcctSeed__Expense_GL_Account__c = gl5.id;
        kitproduct.AcctSeed__Inventory_GL_Account__c = gl5.id;
        kitproduct.AcctSeed__Revenue_GL_Account__c = gl5.id;
        kitproduct.AcctSeed__Inventory_Product__c = true;
        insert kitproduct;
        
        AcctSeed__Product_Part__c pp = new Acctseed__Product_Part__c();
        
        pp.Kit_Product__c = kit.id;
        pp.Kit_Children__c = kitproduct.id;
        pp.AcctSeed__Quantity__c = 1;
        
        insert pp;
        
        // create opportunity
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Closed Won';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = av.Id;
        insert opp;
        
        // create quote
        Quote qt = new Quote();
        qt.Name = 'myQuote';
        qt.OpportunityId = opp.id;
        qt.Quote_Date__c = Date.today();
        qt.Status = 'Presented';
        
        insert qt;
        
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
        
        pricebentry2.Pricebook2Id = pricebookId;
        pricebentry2.Product2Id = kit.Id;
        pricebentry2.UnitPrice = 100;
        pricebentry2.IsActive = true;
        
        insert pricebentry2;
        
        PricebookEntry pricebentry3 = new PricebookEntry();
        
        pricebentry3.Pricebook2Id = pricebookId;
        pricebentry3.Product2Id = kitproduct.Id;
        pricebentry3.UnitPrice = 100;
        pricebentry3.IsActive = true;
        
        insert pricebentry3;
        
        // create opportunity line item
        
        OpportunityLineItem oli = new OpportunityLineItem();
        
        oli.OpportunityId = opp.Id;
        oli.Product2Id = prod.Id;
        oli.PricebookEntryId = pricebentry1.Id;
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
        
        custm.AcctSeed__Vouchers_Payable_GL_Account__c = glList[3].id;
        custm.AcctSeed__AP_Control_GL_Account__c= glList[6].id; 
        custm.AcctSeed__AR_Control_GL_Account__c = glList[4].id;
        custm.AcctSeed__Current_Year_Earnings_GL_Account__c = glList[7].id; 
        custm.AcctSeed__Default_Ledger__c = ledger.id; 
        custm.AcctSeed__Retained_Earnings_GL_Account__c = glList[8].id;
        custm.AcctSeed__Revenue_GL_Account__c = glList[5].id; 
        custm.AcctSeed__Unapplied_Cash_GL_Account__c = glList[9].id;
        
        insert custm;
               
        Date dt = date.today();
        
        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        ap.name = dt.year() + '-' + ((dt.month() < 10)?'0' + dt.month():String.ValueOf(dt.month()));
        system.debug(dt.year() + '-' + ((dt.month() < 9)?Integer.ValueOf('0' + dt.month()):dt.month()));
        ap.AcctSeed__Start_Date__c = Date.today() - (dt.day() - 1);
        ap.AcctSeed__End_Date__c = Date.today() + 28;
        ap.AcctSeed__Status__c = 'Open';
        insert ap;
        
        AcctSeed__Billing_Format__c packingslipformat = new AcctSeed__Billing_Format__c();
        
        packingslipformat.Name = 'Packing Slip Default';
        packingslipformat.AcctSeed__Type__c = 'Packing Slip';
        packingslipformat.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        packingslipformat.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        insert packingslipformat;
		
        /*------------------------------------------------------------- */
        /*--------------------- For Product --------------------------- */
        /*------------------------------------------------------------- */
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c(); 
        
        //salesorder.name = 'testSalesOrder';
        salesorder.AcctSeedERP__Customer__c = acct.Id;
        salesorder.AcctSeedERP__Opportunity__c = opp.Id;
        salesorder.Contact__c = cont.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
        salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.GL_Account_Variable_1__c = av.Id;
        
        insert salesorder;
        
        AcctSeedERP__Sales_Order_Line__c sol = new AcctSeedERP__Sales_Order_Line__c(); 
        
        sol.AcctSeedERP__Sales_Order__c = salesorder.id;
        sol.AcctSeedERP__Unit_Price__c = 1;
        sol.AcctSeedERP_Description__c = 'This is salesorder line item';
        sol.AcctSeedERP__Product__c = prod.id;
        sol.AcctSeedERP__Quantity_Ordered__c = 1;
        
        insert sol;
        
        acctseederp__purchase_order__c po = new acctseederp__purchase_order__c();
        
        po.AcctSeedERP__Order_Date__c = date.today();
        po.AcctSeedERP__Status__c = 'Open';
        po.AcctSeedERP__Type__c = 'Standard';
        po.AcctSeedERP__Purchase_Order_Format__c = abf.Id;
        po.AcctSeedERP__Ledger__c = ledger.Id;
        po.Sales_Order__c = salesorder.id;
        po.AcctSeedERP__Vendor__c = acct.id;
        po.GL_Account_Variable_1__c = av.Id;
        insert po;
        
        acctseederp__purchase_order_line__c pol = new acctseederp__purchase_order_line__c();
        
        pol.AcctSeedERP__Product__c = prod.id;
        pol.AcctSeedERP__Quantity__c = 5;
        pol.AcctSeedERP__Purchase_Order__c = po.id;
        pol.AcctSeedERP__Unit_Price__c = 1;
        
        insert pol;
               
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
        /*
        AcctSeedERP__Purchase_Order_Inventory_Movement__c poim = 
            new AcctSeedERP__Purchase_Order_Inventory_Movement__c();
        poim.AcctSeedERP__GL_Account_Variable_1__c = av.id;
        poim.AcctSeedERP__Inventory_Balance__c = ib.id;
        poim.AcctSeedERP__Quantity__c = 1;
        poim.AcctSeedERP__Purchase_Order_Line__c = pol.id;
        poim.AcctSeedERP__Movement_Date__c = date.today();
        poim.AcctSeedERP__Unit_Cost__c = 1;
        
        insert poim;*/
        AcctSeedERP__Inbound_Inventory_Movement__c iim = new AcctSeedERP__Inbound_Inventory_Movement__c();
        iim.AcctSeedERP__GL_Account_Variable_1__c = av.id;
        iim.AcctSeedERP__Quantity__c = 1;
        iim.AcctSeedERP__Type__c = 'Accounting';
        iim.AcctSeedERP__Credit_GL_Account__c = gl5.id;
        iim.AcctSeedERP__Debit_GL_Account__c = aegl.id;
        iim.AcctSeedERP__Inventory_Balance__c = ib.id;
        iim.AcctSeedERP__Movement_Date__c = date.today();
        iim.AcctSeedERP__Unit_Cost__c = 1;
        
        insert iim;

        AcctSeedERP__Sales_Order_Inventory_Movement__c soim = new AcctSeedERP__Sales_Order_Inventory_Movement__c();
        soim.AcctSeedERP__GL_Account_Variable_1__c = av.id;
        soim.AcctSeedERP__Inventory_Balance__c = ib.id;
        soim.AcctSeedERP__Quantity__c = 1;
        soim.AcctSeedERP__Movement_Date__c = date.today();
        soim.AcctSeedERP__Sales_Order_Line__c = sol.id;
        soim.AcctSeedERP__Unit_Cost__c = 1;
        
        insert soim;

        AcctSeedERP__Shipment__c shipment = new AcctSeedERP__Shipment__c();
        
        shipment.AcctSeedERP__Sales_Order__c = salesorder.id;
        shipment.AcctSeedERP__Shipment_Date__c = Date.today();
        shipment.AcctSeedERP__Status__c = 'Scheduled';
        shipment.AcctSeedERP__Packing_Slip_Format__c = packingslipformat.id;
        
        insert shipment;
        
        AcctSeedERP__Shipment_Line__c shipmentline = new AcctSeedERP__Shipment_Line__c();
        
        shipmentline.AcctSeedERP__Sales_Order_Line__c = sol.id;
        shipmentline.AcctSeedERP__Shipment__c = shipment.id;
        shipmentline.AcctSeedERP__Quantity_Shipped__c = 1;
        
        insert shipmentline;
        
        /*------------------------------------------------------------- */
        /*--------------------- For Kit --------------------------- */
        /*------------------------------------------------------------- */
        AcctSeedERP__Sales_Order__c salesorder2 = new AcctSeedERP__Sales_Order__c(); 
        
        //salesorder.name = 'testSalesOrder';
        salesorder2.AcctSeedERP__Customer__c = acct.Id;
        salesorder2.AcctSeedERP__Opportunity__c = opp.Id;
        salesorder2.Contact__c = cont.Id;
        salesorder2.AcctSeedERP__Status__c = 'Open';
        salesorder2.AcctSeedERP__Ledger__c = ledger.id;
        salesorder2.GL_Account_Variable_1__c = av.Id;
        
        insert salesorder2;
        
        AcctSeedERP__Sales_Order_Line__c sol2 = new AcctSeedERP__Sales_Order_Line__c(); 
        
        sol2.AcctSeedERP__Sales_Order__c = salesorder2.id;
        sol2.AcctSeedERP__Unit_Price__c = 1;
        sol2.AcctSeedERP_Description__c = 'This is salesorder line item';
        sol2.AcctSeedERP__Product__c = kit.id;
        sol2.AcctSeedERP__Quantity_Ordered__c = 1;
        
        insert sol2;
        
    }
    
    @isTest static void runTests(){
        
        
    }

}
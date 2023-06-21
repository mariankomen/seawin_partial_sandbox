@isTest
public class RollupPOLineOnSOLineTest {
    
    @testSetup static void createData(){
       
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        // create account
        Account acct = new Account();
        //acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct;
        
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = accVar.Id;
        insert aegl;
        
        // Gl account with bank unchecked
        AcctSeed__GL_Account__c ga = new AcctSeed__GL_Account__c();
        ga.Name = 'GL Account Test';
        ga.AcctSeed__Active__c = true;
        ga.AcctSeed__Type__c = 'Revenue';
        ga.AcctSeed__Sub_Type_1__c = 'Product Revenue';
        ga.AcctSeed__Sub_Type_2__c = 'Product Family 1';
        ga.AcctSeed__Bank__c = false;
        
        insert ga;
        
        // create product
        Product2 prod = new Product2();
        
        prod.Name = 'myProduct';
        prod.ProductCode = 'ABC123';
        prod.AcctSeed__Unit_Cost__c = 100;
        prod.IsActive = true;
        prod.AcctSeed__Inventory_Type__c = 'Purchased';
        prod.AcctSeed__Expense_GL_Account__c = ga.id;
        prod.AcctSeed__Inventory_GL_Account__c = ga.id;
        prod.AcctSeed__Revenue_GL_Account__c = ga.id;
        insert prod;
        
        // insert to standard price book
        Id pricebookId = Test.getStandardPricebookId();
     
        
        // create pricebookentry
        PricebookEntry pricebentry = new PricebookEntry();
        
        pricebentry.Pricebook2Id = pricebookId;
        pricebentry.Product2Id = prod.Id;
        pricebentry.UnitPrice = 100;
        pricebentry.IsActive = true;
        
        insert pricebentry;
        
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

        salesorder.AcctSeedERP__Status__c = 'Open';
        salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.GL_Account_Variable_1__c = accVar.Id;
        
        insert salesorder;
        
        
        // create a sales order
        List<AcctSeedERP__Sales_Order_Line__c> solineList = new List<AcctSeedERP__Sales_Order_Line__c>();
        
        AcctSeedERP__Sales_Order_Line__c soline = new AcctSeedERP__Sales_Order_Line__c(); 
        
        soline.AcctSeedERP__Sales_Order__c = salesorder.id;
        soline.AcctSeedERP__Unit_Price__c = 1;
        soline.AcctSeedERP_Description__c = 'This is salesorder line item';
        soline.AcctSeedERP__Product__c = prod.id;
        soline.AcctSeedERP__Quantity_Ordered__c = 1;
        
		insert soline;
        
        Date d = Date.today();

        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        
        Integer year = d.year();
        String month = d.month() > 9 ? '' + d.month() : '0' + d.month();

        ap.Name = year + '-' + month;
        ap.AcctSeed__Start_Date__c = Date.NewInstance(year, d.month(), 1);
        ap.AcctSeed__End_Date__c = Date.NewInstance(year, d.month(), Date.DaysInMonth(year, d.month()));
        ap.AcctSeed__Status__c = 'Open';
            
        insert ap;
        
        acctseederp__purchase_order__c po = new acctseederp__purchase_order__c();
        
        po.AcctSeedERP__Order_Date__c = date.today();
        po.AcctSeedERP__Status__c = 'Open';
        po.AcctSeedERP__Type__c = 'Standard';
        po.AcctSeedERP__Purchase_Order_Format__c = abf.Id;
        po.AcctSeedERP__Ledger__c = ledger.Id;
        po.Sales_Order__c = salesorder.id;
        po.AcctSeedERP__Vendor__c = acct.id;
        po.GL_Account_Variable_1__c = accVar.Id;
        insert po;
        
        acctseederp__purchase_order_line__c pol = new acctseederp__purchase_order_line__c();
        
        pol.AcctSeedERP__Product__c = prod.id;
        pol.AcctSeedERP__Quantity__c = 1;
        pol.AcctSeedERP__Purchase_Order__c = po.id;
        pol.AcctSeedERP__Unit_Price__c = 1;
        pol.Sales_Order_Line__c = soline.id;
        
        insert pol;

    }
    
    @isTest static void StarttheProcess(){
        
        // get the purchase order lines list
        list<acctseederp__purchase_order_line__c> plines = new list<acctseederp__purchase_order_line__c>([select id 
                                                    from acctseederp__purchase_order_line__c]);
        
        test.startTest();
        
        delete plines;
        
        test.stopTest();
        
		
    }
}
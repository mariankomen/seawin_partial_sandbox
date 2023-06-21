@isTest
public class PurchaseOrderPageExtensionTest {
    
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
        prod.AcctSeed__Inventory_Product__c = true;
        prod.Type__c = 'Product';
        insert prod;
        
        // insert to standard price book
        Id pricebookId = Test.getStandardPricebookId();
        
        // create standard price book entry
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
        po.AcctSeedERP__Vendor__c = acct.id;
        po.GL_Account_Variable_1__c = accVar.Id;
        po.In_Transit_Message_Show__c = true;
        insert po;
        
        acctseederp__purchase_order_line__c pol = new acctseederp__purchase_order_line__c();
        
        pol.AcctSeedERP__Product__c = prod.id;
        pol.AcctSeedERP__Quantity__c = 1;
        pol.AcctSeedERP__Purchase_Order__c = po.id;
        pol.AcctSeedERP__Unit_Price__c = 1;
        
        insert pol;

        AcctSeedERP__Warehouse__c wh = new AcctSeedERP__Warehouse__c();
        wh.name = 'Test WH';
        insert wh;
        
        AcctSeedERP__Location__c loc = new AcctSeedERP__Location__c();
        loc.Name = 'test loc';
        loc.AcctSeedERP__Warehouse__c = wh.id;
        insert loc;

        AcctSeedERP__Inventory_Balance__c invBal = new AcctSeedERP__Inventory_Balance__c();
        invBal.AcctSeedERP__Location__c = loc.Id;
        invBal.AcctSeedERP__Warehouse__c = wh.Id;
        invBal.AcctSeedERP__Product__c = prod.Id;
        insert invBal;
        
        AcctSeedERP__Purchase_Order_Inventory_Movement__c pomovemnt = new AcctSeedERP__Purchase_Order_Inventory_Movement__c();
        pomovemnt.AcctSeedERP__Movement_Date__c = d.addDays(-5);
        pomovemnt.AcctSeedERP__Quantity__c = 2;
        pomovemnt.AcctSeedERP__GL_Account_Variable_1__c = accVar.id;
        pomovemnt.AcctSeedERP__Inventory_Balance__c = invBal.Id;
        pomovemnt.AcctSeedERP__Purchase_Order_Line__c = pol.Id;
        pomovemnt.AcctSeedERP__Unit_Cost__c = 123;
        insert pomovemnt;
        
    }
    
    @isTest static void runTests(){
        
        AcctSeedERP__Purchase_Order__c po = [select id, name, AcctSeedERP__Status__c, Status_Helper__c,
        In_Transit_Message_Show__c from
        AcctSeedERP__Purchase_Order__c Limit 1];
        
        po.Status_Helper__c = 'Open'; 

        Test.startTest();

        update po;
        
        APexPages.StandardController std = new ApexPages.StandardController(po);
        
        PurchaseOrderPageExtension ext = new PurchaseOrderPageExtension(std);
        
        ext.hideChangeMessage();
        ext.removeHelperValue();
        ext.hideIntransitMessage();
        ext.MarkInTransit();

        Test.stopTest();
        
    }    

}
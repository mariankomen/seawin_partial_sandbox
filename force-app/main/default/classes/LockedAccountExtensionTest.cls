@isTest
public class LockedAccountExtensionTest {
    
    @testSetup static void createData(){
        
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'Seawin USA';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        Account acct = new Account(); 
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        acct.Status__c = 'Active';
        insert acct;      
        
        // create product
        Product2 prod = new Product2();
        
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = accVar.Id;
        insert aegl;
        
        prod.Name = 'myProduct';
        prod.ProductCode = 'ABC123';
        prod.AcctSeed__Unit_Cost__c = 100;
        prod.IsActive = true;
        prod.AcctSeed__Inventory_Type__c = 'Purchased';
        prod.AcctSeed__Expense_GL_Account__c = aegl.id;
        prod.AcctSeed__Inventory_GL_Account__c = aegl.id;
        prod.AcctSeed__Revenue_GL_Account__c = aegl.id;
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
        
        // create a sales order
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c(); 
        
        salesorder.AcctSeedERP__Customer__c = acct.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
        salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.GL_Account_Variable_1__c = accVar.Id;
        insert salesorder;
        
        // create a sales order
        
        AcctSeedERP__Sales_Order_Line__c sol = new AcctSeedERP__Sales_Order_Line__c(); 
        
        sol.AcctSeedERP__Sales_Order__c = salesorder.id;
        sol.AcctSeedERP__Unit_Price__c = 1;
        sol.AcctSeedERP_Description__c = 'This is salesorder line item';
        sol.AcctSeedERP__Product__c = prod.id;
        sol.AcctSeedERP__Quantity_Ordered__c = 1;
        
        insert sol;
        
    }
    
    @isTest static void OnlySalesOrder(){
        
        Account acc = [select id from Account where name = 'myAccount' Limit 1];

        ApexPages.StandardController std = new ApexPages.StandardController(acc);
        LockedAccountExtension ext = new LockedAccountExtension(std);
    }
    @isTest static void Pending(){
        
        Account acc = [select id from Account where name = 'myAccount' Limit 1];
        acc.Status__c = 'Pending';
        update acc;

        ApexPages.StandardController std = new ApexPages.StandardController(acc);
        LockedAccountExtension ext = new LockedAccountExtension(std);
    }
    @isTest static void Rejected(){
        
        Account acc = [select id from Account where name = 'myAccount' Limit 1];
        acc.Status__c = 'Rejected';
        update acc;

        ApexPages.StandardController std = new ApexPages.StandardController(acc);
        LockedAccountExtension ext = new LockedAccountExtension(std);
    }
    @isTest static void InActive(){
        
        Account acc = [select id from Account where name = 'myAccount' Limit 1];
        acc.Status__c = 'In Active';
        update acc;
        
        ApexPages.StandardController std = new ApexPages.StandardController(acc);
        LockedAccountExtension ext = new LockedAccountExtension(std);
    }
    @isTest static void Hold(){
        
        Account acc = [select id from Account where name = 'myAccount' Limit 1];
        acc.Status__c = 'Hold';
        update acc;
        
        ApexPages.StandardController std = new ApexPages.StandardController(acc);
        LockedAccountExtension ext = new LockedAccountExtension(std);
    }
}
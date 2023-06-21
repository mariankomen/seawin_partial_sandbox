@isTest
public class SalesOrderPDFManagerTest {
    
    @testSetup static void createSortOrderData(){
        
        AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c(
            Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1');
        
        insert av;
        
        // create account
        Account acct = new Account();
        
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = av.id;
        
        insert acct;
        
        Contact ct = new Contact();
        
        ct.LastName = 'myLastName';
        ct.AccountId = acct.Id;
        
        insert ct;
        
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = av.id;
        
        insert aegl;
        
        // create product
        Product2 prod = new Product2();
        
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
        
        // create pricebookentry
        PricebookEntry pricebentry = new PricebookEntry();
        
        pricebentry.Pricebook2Id = pricebookId;
  		pricebentry.Product2Id = prod.Id;
        pricebentry.UnitPrice = 100;
        pricebentry.IsActive = true;
        
        insert pricebentry;
        
        AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();
        
        abf.Name = 'newPDF Format';
        abf.AcctSeed__Type__c = 'Sales Order';
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
        
        //salesorder.name = 'testSalesOrder';
        salesorder.AcctSeedERP__Customer__c = acct.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
       	salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.Sales_Order_Format__c = abf.id;
        salesorder.GL_Account_Variable_1__c = av.id;
        salesorder.contact__c = ct.id;

        insert salesorder;
        
        // create a sales order
        
        AcctSeedERP__Sales_Order_Line__c sol = new AcctSeedERP__Sales_Order_Line__c(); 
        
        sol.AcctSeedERP__Sales_Order__c = salesorder.id;
        sol.AcctSeedERP__Unit_Price__c = 1.1;
        sol.AcctSeedERP_Description__c = 'This is salesorder line item';
        sol.AcctSeedERP__Product__c = prod.id;
        sol.AcctSeedERP__Quantity_Ordered__c = 1;
        
        insert sol;

    }
    
    @isTest static void SalesOrderManager(){

         acctseederp__sales_order__c so = [select id,contact__c,acctseederp__customer__c, 
                                          Sales_Order_Format__r.AcctSeed__Default_Email_Template__c  
                                          from acctseederp__sales_order__c limit 1];
        
        Test.startTest();
        
        PageReference pageRef = Page.SalesOrderPDFManager;
        Test.setCurrentPage(pageRef);
		
        ApexPages.currentPage().getParameters().put('id', so.id);

        ApexPages.StandardController std = new ApexPages.StandardController(so);
        
        SalesOrderPDFManager ext = new SalesOrderPDFManager(std);
        
        System.Assert(ext.communityUrl != null);
        
        ext.getOrgWideEmailSelectOptions();
        
        ext.saveAttach();
        
        ext.saveAndEmail();
        
        //so.Contact__c = null;
        
        ext.saveAndEmail();
        
        Test.stopTest();

    }
}
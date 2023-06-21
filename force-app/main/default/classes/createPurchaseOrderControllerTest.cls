@isTest
public class createPurchaseOrderControllerTest {
    
    static testmethod void testMethod1() {
        test.startTest();      
        
        AcctSeed__Accounting_Variable__c accountingVariable = new AcctSeed__Accounting_Variable__c(Name = 'Test Accounting Variable', 
                                                                                                   AcctSeed__Type__c = 'GL Account Variable 1');
        insert accountingVariable;
        
        List<Account> accList = new List<Account>();        
        accList.add(new Account(Name = 'Test Account', AcctSeed__GL_Account_Variable_1__c = accountingVariable.Id, 
                                Industry = 'Hospitality', AcctSeed__Accounting_Type__c = 'Customer', 
                                BillingCountry = 'United States', BillingCIty = 'Birmingham', BillingState='AL'));
        
        accList.add(new Account(Name = 'Vendor Account', AcctSeed__GL_Account_Variable_1__c = accountingVariable.Id, 
                                Industry = 'Manufacturing', AcctSeed__Accounting_Type__c = 'Vendor', 
                                BillingCountry = 'United States', BillingCIty = 'Birmingham', BillingState='AL'));        
        insert accList;
        
        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(LastName = 'test Contact', Email='testcontact@mail.com', AccountId = accList[0].Id));
        contactList.add(new Contact(LastName = 'vendor Contact', Email='testcontact@mail.com', AccountId = accList[1].Id));        
        insert contactList;
        
        Opportunity opp = new Opportunity(Name='Test Opportunity', AccountId = accList[0].Id,
                                          ContactPerson__c = contactList[0].Id, StageName = 'Closed Won', Probability = 100, CloseDate = Date.newInstance(2018,10,10),
                                          ForecastCategoryName = 'Closed');
        
        insert opp;
        //create Ledger
        AcctSeed__Ledger__c ledger = createLedger();        
        
        //Creating a test Sales Order
        AcctSeedERP__Sales_Order__c testSalesOrder = new AcctSeedERP__Sales_Order__c();
        testSalesOrder.AcctSeedERP__Ledger__c = ledger.Id;
        testSalesOrder.AcctSeedERP__Opportunity__c = opp.Id;
        testSalesOrder.AcctSeedERP__Customer__c = accList[0].Id;
        testSalesOrder.AcctSeedERP__Status__c = 'Open';
        
        insert testSalesOrder;
        
        List<AcctSeed__GL_Account__c> glAccountList = new List<AcctSeed__GL_Account__c>();
        glAccountList.add(new AcctSeed__GL_Account__c(Name = 'Inventory GL Account Test', AcctSeed__Type__c = 'Balance Sheet',
                                                      AcctSeed__Sub_Type_1__c = 'Assets', AcctSeed__Sub_Type_2__c = 'Current Assets'));
        glAccountList.add(new AcctSeed__GL_Account__c(Name = 'Revenue GL Account Test', AcctSeed__Type__c = 'Revenue',
                                                      AcctSeed__Sub_Type_1__c = 'Product Revenue', AcctSeed__Sub_Type_2__c = 'Product Family 1'));
        glAccountList.add(new AcctSeed__GL_Account__c(Name = 'Expense GL Account Test', AcctSeed__Type__c = 'Expense',
                                                      AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold', AcctSeed__Sub_Type_2__c = 'Materials'));
        insert glAccountList;        
        
        
        //creating a new product
        Product2 testProduct = new Product2(Name = 'Test Product', ProductCode = 'SKZ00013', IsActive = true, Category__c = 'Custom',
                                            AcctSeed__Inventory_Type__c = 'Purchased', AcctSeedERP__Default_Vendor__c = accList[1].Id,
                                            AcctSeed__Unit_Cost__c = 45, AcctSeed__Inventory_Product__c = true, AcctSeed__Inventory_GL_Account__c = glAccountList[0].Id,
                                            AcctSeed__Revenue_GL_Account__c = glAccountList[1].Id, AcctSeed__Expense_GL_Account__c = glAccountList[2].Id);
        insert testProduct;
        
        //define the standart price for the product
        //Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where Where Id IsStandard = true LIMIT 1];
        
        PriceBook2 pb2=new PriceBook2(Name = 'test', IsActive = true);      	
        insert pb2;                
        PricebookEntry pbe = createPricebookEntry(test.getStandardPricebookId(),pb2,testProduct);
        
        
        
        //testSalesOrder
        AcctSeedERP__Sales_Order_Line__c salesOrderLine = new AcctSeedERP__Sales_Order_Line__c();
        salesOrderLine.AcctSeedERP__Sales_Order__c = testSalesOrder.Id;        
        salesOrderLine.AcctSeedERP__Unit_Price__c = 100;
        salesOrderLine.AcctSeedERP__Quantity_Ordered__c = 2;
        salesOrderLine.AcctSeedERP__Product__c = testProduct.Id;
        
        insert salesOrderLine;
        
        /*OpportunityLineItem oppLineItem = new OpportunityLineItem(PricebookEntryId = pbe.Id, OpportunityId = opp.Id, Product2Id = testProduct.Id, Quantity = 2, UnitPrice = 100,
		Item_Description__c = 'Test OpplineItem');

		insert oppLineItem;*/
        PageReference pageRef = new PageReference('/apex/createPurchaseOrder?id='+ testSalesOrder.Id + '&count=1&id0='+ salesOrderLine.Id);
        Test.setCurrentPage(pageRef);
        createPurchaseOrderController controller = new createPurchaseOrderController();
       
        controller.draft();
        controller.back();
        controller.create();
        
        test.stopTest();
    }
    /***************************************************
	* 				Create Ledger
	* ************************************************/
    public static AcctSeed__Ledger__c createLedger() {
        AcctSeed__Ledger__c ledger = null;
        
        
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        
        insert aegl;
        
        AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();
        
        abf.Name = 'Default Purchase Order';
        abf.AcctSeed__Type__c = 'Default Purchase Order';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        insert abf;
        
        ledger = new AcctSeed__Ledger__c();
        
        ledger.Name = 'myLedger';
        ledger.AcctSeed__Type__c = 'Transactional';
        ledger.AcctSeed__Billing_Activity_Statement_Format__c = abf.id;
        ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = abf.id;
        ledger.AcctSeed__Default_Bank_Account__c = aegl.id;
        ledger.AcctSeed__Default_Billing_Format__c = abf.id; 
        ledger.AcctSeed__Default_Purchase_Order_Format__c = abf.id;
        ledger.AcctSeed__Default_Packing_Slip_Format__c = abf.id;
        
        
        insert ledger;
        
        return ledger;
        
    }
    public static PricebookEntry createPricebookEntry (Id standardId, Pricebook2 newPricebook, Product2 prod) {
        System.debug('***** starting one');
        PricebookEntry one = new PricebookEntry();
        one.pricebook2Id = standardId;
        one.product2id = prod.id;
        one.unitprice = 1249.0;
        one.isactive = true;
        insert one;
        System.debug('***** one complete, ret next');
        PricebookEntry ret = new PricebookEntry();
        ret.pricebook2Id = newPricebook.id;
        ret.product2id = prod.id;
        ret.unitprice = 1250.0;
        ret.isactive = true;
        insert ret;
        return ret;
    }
}
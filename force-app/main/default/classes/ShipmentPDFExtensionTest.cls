@isTest
public class ShipmentPDFExtensionTest {
    
    @testSetup static void createData(){
        
        // create accounting period
        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        
        ap.name = '2019-01';
        ap.AcctSeed__Start_Date__c = date.newInstance(2019, 1, 1);
        ap.AcctSeed__End_Date__c = date.newInstance(2019, 12, 1);
        ap.AcctSeed__Status__c = 'Open';
        
        insert ap;
        
       
        Profile pf = [Select Id from profile where Name = 'System Administrator']; 
        //Profile pf = [Select Id from profile where Name = 'Sales Rep'];
         
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
        
        
        
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        accVar.Shipping_Header__c = 'test header';
        accVar.Shipping_Footer__c = 'test footer';
        accVar.Shipping_Terms__c = 'test terms';
        insert accVar;
        
           // create account
        Account acct = new Account();
        //acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct;

        
        // create account
        Account otherCustomer = new Account();
        
        //otherCustomer.Sales_Rep_O__c = sr.id;
        otherCustomer.Name = 'myAccount';
        otherCustomer.Type = 'Customer';
        otherCustomer.AcctSeed__Accounting_Type__c = 'Customer';
        otherCustomer.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        
        insert otherCustomer;
		
        // create contact
        Contact cont = new Contact();
        
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        
        insert cont;
        
        // create contact
        Contact otherContact = new Contact();
        
        otherContact.LastName = 'myLastName';
        otherContact.AccountId = acct.Id;
        
        insert otherContact;
        
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = accVar.Id;
        
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
        prod.AcctSeed__Inventory_Product__c = true;
        prod.Type__c = 'other';
        
        insert prod;
        
        // create opportunity
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        //opp.Sales_Rep_O__c = sr.id;
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Follow up';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = accVar.Id;

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
        abf.AcctSeed__Type__c = 'Sales Order';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        insert abf;
        
        AcctSeed__Billing_Format__c packingslipformat = new AcctSeed__Billing_Format__c();
        
        packingslipformat.Name = 'Default Packing Slip';
        packingslipformat.AcctSeed__Type__c = 'Packing Slip';
        packingslipformat.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        packingslipformat.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        insert packingslipformat;
        
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
        
        // create warehouse
        AcctSeedERP__Warehouse__c warehouse = new AcctSeedERP__Warehouse__c();
        
        warehouse.Name = 'test warehouse';
        
        insert warehouse;
        
        // create location
        AcctSeedERP__Location__c location = new AcctSeedERP__Location__c();
        
        location.Name = 'test location';
        location.AcctSeedERP__Warehouse__c = warehouse.id;
        
        insert location;
        
        // create inventory balance 
        
        AcctSeedERP__Inventory_Balance__c ib = new AcctSeedERP__Inventory_Balance__c();
        
        ib.AcctSeedERP__Warehouse__c = warehouse.id;
        ib.AcctSeedERP__Location__c = location.id;
        ib.AcctSeedERP__Product__c = prod.id;
        
        insert ib;
             
        // create a sales order
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c(); 
        
        //salesorder.name = 'testSalesOrder';
        salesorder.AcctSeedERP__Customer__c = acct.Id;
        salesorder.AcctSeedERP__Opportunity__c = opp.Id;
        salesorder.Contact__c = cont.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
       	salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.Sales_Order_Format__c = abf.id;
        salesorder.Shipping_Account__c = otherCustomer.id;
        salesorder.Shipping_Name__c = otherContact.id;
        salesorder.GL_Account_Variable_1__c = accVar.Id;

        insert salesorder;
        
        // create a sales order
        List<AcctSeedERP__Sales_Order_Line__c> solineList = new List<AcctSeedERP__Sales_Order_Line__c>();
        
        AcctSeedERP__Sales_Order_Line__c solines = new AcctSeedERP__Sales_Order_Line__c(); 
        
        solines.AcctSeedERP__Sales_Order__c = salesorder.id;
        solines.AcctSeedERP__Unit_Price__c = 1.1;
        solines.AcctSeedERP_Description__c = 'This is salesorder line item';
        solines.AcctSeedERP__Product__c = prod.id;
        solines.AcctSeedERP__Quantity_Ordered__c = 100;
        
        solineList.add(solines);
        
        AcctSeedERP__Sales_Order_Line__c solines1 = new AcctSeedERP__Sales_Order_Line__c(); 
        
        solines1.AcctSeedERP__Sales_Order__c = salesorder.id;
        solines1.AcctSeedERP__Unit_Price__c = 1.1;
        solines1.AcctSeedERP_Description__c = 'This is salesorder line item 2';
        solines1.AcctSeedERP__Product__c = prod.id;
        solines1.AcctSeedERP__Quantity_Ordered__c = 1;
 
        solineList.add(solines1);
        
        insert solineList;
        
        // create GL Accounts
        // credit
        AcctSeed__GL_Account__c credit = new AcctSeed__GL_Account__c();
        
        credit.AcctSeed__Active__c = true;
        credit.Name = 'Credit GL Account';
        credit.AcctSeed__Type__c = 'Revenue';
        credit.AcctSeed__Sub_Type_1__c = 'Product Revenue';
        credit.AcctSeed__Sub_Type_2__c = 'Product Family 1';
        
        insert credit;
        
        // debit
        AcctSeed__GL_Account__c debit = new AcctSeed__GL_Account__c();
        
        debit.AcctSeed__Active__c = true;
        debit.Name = 'Debit GL Account';
        debit.AcctSeed__Type__c = 'Expense';
        debit.AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold';
        debit.AcctSeed__Sub_Type_2__c = 'Materials';
        
        insert debit;
        
        
        // create inbound inventory movement
        AcctSeedERP__Inbound_Inventory_Movement__c iim = new AcctSeedERP__Inbound_Inventory_Movement__c();
        
        iim.AcctSeedERP__Credit_GL_Account__c = credit.id;
        iim.AcctSeedERP__Debit_GL_Account__c = debit.id;
        iim.AcctSeedERP__Inventory_Balance__c = ib.id;
        iim.AcctSeedERP__Movement_Date__c = date.newInstance(2019, 1, 1);
        iim.AcctSeedERP__Quantity__c = 1000;
        iim.AcctSeedERP__Unit_Cost__c = 1;
        iim.AcctSeedERP__Ledger__c = ledger.id;
        iim.AcctSeedERP__Type__c = 'Accounting';
        
        insert iim;
        
        // create invetory movement
        AcctSeedERP__Sales_Order_Inventory_Movement__c soiv = new AcctSeedERP__Sales_Order_Inventory_Movement__c();
        
        soiv.AcctSeedERP__Inventory_Balance__c = ib.id;
        soiv.AcctSeedERP__Sales_Order_Line__c = solines.id;
        soiv.AcctSeedERP__Quantity__c = 100;
        soiv.AcctSeedERP__Movement_Date__c = date.newInstance(2019, 1, 1);
        soiv.AcctSeedERP__Unit_Cost__c = 1;
        soiv.AcctSeedERP__Ledger__c = ledger.id;
        
        insert soiv;
        
        AcctSeedERP__Shipment__c shipment = new AcctSeedERP__Shipment__c();
        
       	shipment.AcctSeedERP__Shipment_Date__c = date.today();
        shipment.AcctSeedERP__Sales_Order__c = salesorder.id;
        shipment.AcctSeedERP__Status__c = 'Scheduled';
        shipment.AcctSeedERP__Packing_Slip_Format__c = packingslipformat.id;
        
        insert shipment;
        
        AcctSeedERP__Shipment_Line__c shipmentLines = new AcctSeedERP__Shipment_Line__c();
        
        shipmentLines.AcctSeedERP__Shipment__c = shipment.id;
        shipmentLines.AcctSeedERP__Sales_Order_Line__c = solines.id;
        shipmentLines.AcctSeedERP__Quantity_Shipped__c = 1;
        
        insert shipmentLines;
        
        
        

    }
    
    @isTest static void ShipmentPDFMethod(){
        Opportunity opp = [select id from opportunity where name='myOpportunity' limit 1];
        
        acctseederp__sales_order__c so = null;
        AcctSeedERP__Shipment__c shipment = null;
        
         so = [select id,contact__c,acctseederp__customer__c, 
                                          Sales_Order_Format__r.AcctSeed__Default_Email_Template__c  
                                          from acctseederp__sales_order__c                                          
                                          where acctseederp__opportunity__c =:opp.id limit 1];
        
        shipment = [SELECT Id, Name, AcctSeedERP__Sales_Order__c, AcctSeedERP__Packing_Slip_Format__c, 
                    AcctSeedERP__Shipment_Date__c, GL_Account_Variable_1__c, AcctSeedERP__Status__c 
                    FROM AcctSeedERP__Shipment__c
                    WHERE AcctSeedERP__Sales_Order__c =: so.id limit 1];
		
        
        PageReference pageRef = Page.ShipmentPDFCustom;
        Test.setCurrentPage(pageRef);
		
        ApexPages.currentPage().getParameters().put('id', so.id);
        
        ApexPages.StandardController std = new ApexPages.StandardController(shipment);
        
        ShipmentPDFExtension sls = new ShipmentPDFExtension(std);
        
        

    }
}
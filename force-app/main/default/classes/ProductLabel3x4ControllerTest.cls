/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-11-2023
 * @last modified by  : Marian Lyzhychka
**/
@isTest
public with sharing class ProductLabel3x4ControllerTest {
    @TestSetup
    static void makeData(){
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'Seawin USA';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        // create account
        Account acct = new Account();
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct;
        
        // create contact
        Contact cont = new Contact();
        
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.GL_Account_Variable_1__c = accVar.Id;
        insert cont;
        
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
        prod.Description = 'myProductmyProductmyProductmy\nProductm\n\n\n\n\n\n\nyProductmyProductmyProductmyProductmyProductmyProductmyProductmyProductmyProduct';
        prod.ProductCode = 'ABC123';
        prod.AcctSeed__Unit_Cost__c = 100;
        prod.IsActive = true;
        prod.AcctSeed__Inventory_Product__c = true;
        prod.AcctSeed__Inventory_Type__c = 'Purchased';
        prod.AcctSeed__Expense_GL_Account__c = ga.id;
        prod.AcctSeed__Inventory_GL_Account__c = ga.id;
        prod.AcctSeed__Revenue_GL_Account__c = ga.id;
        prod.Type__c = 'Product';
        insert prod;
        
        // create opportunity
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Closed Won';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = accVar.Id;
        insert opp;
        
        // create quote
        Quote qt = new Quote();
        qt.Name = 'myQuote';
        qt.OpportunityId = opp.id;
        qt.Quote_Date__c = Date.today();
        qt.Status = 'Presented';
        
        insert qt;
        
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
        salesorder.AcctSeedERP__Opportunity__c = opp.Id;
        salesorder.Contact__c = cont.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
        salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.AcctSeedERP__Shipping_City__c='Rawalpindi';
        salesorder.AcctSeedERP__Shipping_Country__c='Pakistan';
        salesorder.AcctSeedERP__Shipping_PostalCode__c='46000';
        salesorder.AcctSeedERP__Shipping_State__c='Punjab';
        salesorder.AcctSeedERP__Shipping_Street__c='Satellite Town';
        salesorder.AcctSeedERP__Billing_Country__c='Afghanistan';
        salesorder.AcctSeedERP__Billing_PostalCode__c='12345';
        salesorder.AcctSeedERP__Billing_State__c='Kabul';
        salesorder.AcctSeedERP__Billing_Street__c='Lake view';
        salesorder.AcctSeedERP__Billing_City__c='Kabul';
        salesorder.GL_Account_Variable_1__c = accVar.Id;
        salesorder.PO_Date__c = system.today();
        
        insert salesorder;
        
        
        // create a sales order
        List<AcctSeedERP__Sales_Order_Line__c> solineList = new List<AcctSeedERP__Sales_Order_Line__c>();
        
        AcctSeedERP__Sales_Order_Line__c solines = new AcctSeedERP__Sales_Order_Line__c(); 
        
        solines.AcctSeedERP__Sales_Order__c = salesorder.id;
        solines.AcctSeedERP__Unit_Price__c = 1.1;
        solines.AcctSeedERP_Description__c = 'This is salesorder line item';
        solines.AcctSeedERP__Product__c = prod.id;
        solines.AcctSeedERP__Quantity_Ordered__c = 1;
        
        solineList.add(solines);
        
        AcctSeedERP__Sales_Order_Line__c solines1 = new AcctSeedERP__Sales_Order_Line__c(); 
        
        solines1.AcctSeedERP__Sales_Order__c = salesorder.id;
        solines1.AcctSeedERP__Unit_Price__c = 1.1;
        solines1.AcctSeedERP_Description__c = 'This is salesorder line item 2';
        solines1.AcctSeedERP__Product__c = prod.id;
        solines1.AcctSeedERP__Quantity_Ordered__c = 1;
        
        solineList.add(solines1);
        
        insert solineList;
        
        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        
        ap.Name = '2019-01';
        ap.AcctSeed__Status__c = 'Open';
        ap.AcctSeed__Start_Date__c = Date.newInstance(2019, 1, 1);
        ap.AcctSeed__End_Date__c = Date.newInstance(2020, 12, 1);
        
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
        insert pol;
        
        PO_Shipment__c poShipmnt = new PO_Shipment__c();
        poShipmnt.Purchase_Order__c = po.Id;
        poShipmnt.Status__c = 'Shipped';
        insert poShipmnt;
        
        PO_Shipment_Line__c poShpmntLine = new PO_Shipment_Line__c();
        poShpmntLine.PO_Shipment__c = poShipmnt.id;
        //poShpmntLine.Purchase_Order_Line__c = pol.Id;
        insert poShpmntLine;

        AcctSeed__Billing_Format__c packingSlipFormat = new AcctSeed__Billing_Format__c();
        
        packingSlipFormat.Name = 'Default Packing Slip';
        packingSlipFormat.AcctSeed__Type__c = 'Packing Slip';
        packingSlipFormat.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        packingSlipFormat.AcctSeed__Default_Email_Template__c = 'Shipment_Email_Template';
        
        insert packingSlipFormat;
        
        AcctSeedERP__Shipment__c shipment = new AcctSeedERP__Shipment__c();
        
        shipment.AcctSeedERP__Sales_Order__c = salesorder.id;
        shipment.AcctSeedERP__Shipment_Date__c = Date.today();
        shipment.AcctSeedERP__Packing_Slip_Format__c = packingSlipFormat.id;
        
        insert shipment;

        AcctSeedERP__Shipment_Line__c shipmentline = new AcctSeedERP__Shipment_Line__c();
        
        shipmentline.AcctSeedERP__Sales_Order_Line__c = solines1.id;
        shipmentline.AcctSeedERP__Shipment__c = shipment.id;
        shipmentline.AcctSeedERP__Quantity_Shipped__c = 1;
        
        insert shipmentline;
    }

    @isTest
    public static void createLabelsControllerPOSHIPTest(){
        PO_Shipment__c ship = [SELECT Id FROM PO_Shipment__c LIMIT 1];
        PO_Shipment_Line__c shipLine = [SELECT Id FROM PO_Shipment_Line__c LIMIT 1];
        ApexPages.currentPage().getParameters().put('recordId', ship.Id);

        String payload = '[{"selectedTemplate":"Label 4x3 Hardware","productId":"01t8W000005BbuYQAS","lineId":"a1GEY00000066gq2AA","copiesCount":1}]';
        List<ProductLabel3x4Controller.IterableItem> lines = (List<ProductLabel3x4Controller.IterableItem>)JSON.deserialize(payload, List<ProductLabel3x4Controller.IterableItem>.class);
        lines[0].lineId = shipLine.Id;

        ApexPages.currentPage().getParameters().put('shortSObjectName', 'POSHIP');
        ApexPages.currentPage().getParameters().put('data', JSON.serialize(lines));

        ProductLabel3x4Controller c = new ProductLabel3x4Controller();
    }

    @isTest
    public static void createLabelsControllerSOTest(){
        AcctSeedERP__Sales_Order__c ship = [SELECT Id FROM AcctSeedERP__Sales_Order__c LIMIT 1];
        AcctSeedERP__Sales_Order_Line__c shipLine = [SELECT Id FROM AcctSeedERP__Sales_Order_Line__c LIMIT 1];
        ApexPages.currentPage().getParameters().put('recordId', ship.Id);

        String payload = '[{"selectedTemplate":"Label 4x3 Hardware","productId":"01t8W000005BbuYQAS","lineId":"a1GEY00000066gq2AA","copiesCount":1}]';
        List<ProductLabel3x4Controller.IterableItem> lines = (List<ProductLabel3x4Controller.IterableItem>)JSON.deserialize(payload, List<ProductLabel3x4Controller.IterableItem>.class);
        lines[0].lineId = shipLine.Id;

        ApexPages.currentPage().getParameters().put('shortSObjectName', 'SO');
        ApexPages.currentPage().getParameters().put('data', JSON.serialize(lines));

        ProductLabel3x4Controller c = new ProductLabel3x4Controller();
    }
    @isTest
    public static void createLabelsControllerProductTest(){
        Product2 ship = [SELECT Id FROM Product2 LIMIT 1];
        ApexPages.currentPage().getParameters().put('recordId', ship.Id);
        String payload = '[{"selectedTemplate":"Label 4x3 Hardware","productId":"01t8W000005BbuYQAS","lineId":"a1GEY00000066gq2AA","copiesCount":1}]';
        List<ProductLabel3x4Controller.IterableItem> lines = (List<ProductLabel3x4Controller.IterableItem>)JSON.deserialize(payload, List<ProductLabel3x4Controller.IterableItem>.class);
        lines[0].lineId = ship.Id;


        ApexPages.currentPage().getParameters().put('shortSObjectName', 'PRODUCT');
        ApexPages.currentPage().getParameters().put('data', JSON.serialize(lines));
        ProductLabel3x4Controller c = new ProductLabel3x4Controller();

    }
    @isTest
    public static void createLabelsControllerShippTest(){
        AcctSeedERP__Shipment__c ship = [SELECT Id FROM AcctSeedERP__Shipment__c LIMIT 1];
        AcctSeedERP__Shipment_Line__c shipLine = [SELECT Id FROM AcctSeedERP__Shipment_Line__c LIMIT 1];

        ApexPages.currentPage().getParameters().put('recordId', ship.Id);
        String payload = '[{"selectedTemplate":"Label 4x3 Hardware","productId":"01t8W000005BbuYQAS","lineId":"a1GEY00000066gq2AA","copiesCount":1}]';
        List<ProductLabel3x4Controller.IterableItem> lines = (List<ProductLabel3x4Controller.IterableItem>)JSON.deserialize(payload, List<ProductLabel3x4Controller.IterableItem>.class);
        lines[0].lineId = shipLine.Id;


        ApexPages.currentPage().getParameters().put('shortSObjectName', 'SHIP');
        ApexPages.currentPage().getParameters().put('data', JSON.serialize(lines));
        ProductLabel3x4Controller c = new ProductLabel3x4Controller();
    }
}
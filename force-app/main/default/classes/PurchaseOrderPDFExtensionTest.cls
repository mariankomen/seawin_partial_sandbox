@isTest
public class PurchaseOrderPDFExtensionTest {
    
    @testSetup static void createData(){
        
		AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        accVar.Purchase_Order_Header__c = 'test header';
        accVar.Purchase_Order_Footer__c = 'test footer';
        accVar.Purchase_Order_Terms__c = 'test terms';
        insert accVar;
        
           // create account
        Account acct = new Account();
        //acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct;
		
        // create contact
        Contact cont = new Contact();
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.LeadSource = 'AAOHA 2020';
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
        //prod.Type__c = 'Other';
        
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
        opp.Run_Validation_Rule__c = true;
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
        PricebookEntry pricebentry = new PricebookEntry();
        
        pricebentry.Pricebook2Id = pricebookId;
        pricebentry.Product2Id = prod.Id;
        pricebentry.UnitPrice = 100;
        pricebentry.IsActive = true;
        
        insert pricebentry;
        
        // create opportunity line item
        
        OpportunityLineItem oli = new OpportunityLineItem();
        
        oli.OpportunityId = opp.Id;
        oli.Product2Id = prod.Id;
        oli.PricebookEntryId = pricebentry.Id;
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
        salesorder.GL_Account_Variable_1__c = accVar.Id;
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
        
        insert solineList;
        
         list<acctseederp__purchase_order__c> poList = new list<acctseederp__purchase_order__c>();
        
        acctseederp__purchase_order__c po = new acctseederp__purchase_order__c();
        
        po.AcctSeedERP__Order_Date__c = date.today();
        po.AcctSeedERP__Status__c = 'Open';
        po.AcctSeedERP__Type__c = 'Drop Shipment';
        po.Stage__c = 'Production';
        po.AcctSeedERP__Purchase_Order_Format__c = abf.Id;
        po.AcctSeedERP__Ledger__c = ledger.Id;
        po.GL_Account_Variable_1__c = accVar.id;
        po.Sales_Order__c = salesorder.id;
        po.AcctSeedERP__Vendor_Contact__c = cont.id;
        po.AcctSeedERP__Vendor__c = acct.id;
        
        poList.add(po);
        
        acctseederp__purchase_order__c po2 = new acctseederp__purchase_order__c();
        
        po2.AcctSeedERP__Order_Date__c = date.today();
        po2.AcctSeedERP__Status__c = 'Open';
        po2.AcctSeedERP__Type__c = 'Standard';
        po2.Stage__c = 'Production';
        po2.AcctSeedERP__Purchase_Order_Format__c = abf.Id;
        po2.AcctSeedERP__Ledger__c = ledger.Id;
        po2.GL_Account_Variable_1__c = accVar.id;
        po2.Sales_Order__c = salesorder.id;
        
        poList.add(po2);
        
        insert poList;
        
        list<acctseederp__purchase_order_line__c> polList = new list<acctseederp__purchase_order_line__c>();
        
        acctseederp__purchase_order_line__c pol = new acctseederp__purchase_order_line__c();
        
        pol.AcctSeedERP__Product__c = prod.id;
        pol.AcctSeedERP__Quantity__c = 4;
        pol.AcctSeedERP__Purchase_Order__c = poList[0].id;
        pol.AcctSeedERP__Unit_Price__c = 1;
        
        polList.add(pol);
        
        //-------------------------
        
        
        acctseederp__purchase_order_line__c pol2 = new acctseederp__purchase_order_line__c();
        
        pol2.AcctSeedERP__Product__c = prod.id;
        pol2.AcctSeedERP__Quantity__c = 2;
        pol2.AcctSeedERP__Purchase_Order__c = poList[1].id;
        pol2.AcctSeedERP__Unit_Price__c = 1;
        
        polList.add(pol2);
        
        insert polList;
        
       // solineList.AcctSeedERP__Purchase_Order_Line__c = polList[0].id;
        
        //update solineList;
        
    }
    
    @isTest static void PurchaseOrderController(){
        Opportunity opp = [select id from opportunity where name='myOpportunity' limit 1];
        acctseederp__sales_order__c so = null;
         so = [select id,contact__c,acctseederp__customer__c, 
                                          Sales_Order_Format__r.AcctSeed__Default_Email_Template__c  
                                          from acctseederp__sales_order__c                                          
                                          where acctseederp__opportunity__c =:opp.id limit 1];
        acctseederp__purchase_order__c po = null;
        po = [SELECT Id, Name, AcctSeedERP__Comment__c, AcctSeedERP__Order_Date__c, AcctSeedERP__Purchase_Order_Format__c, 
              AcctSeedERP__Shipping_City__c, AcctSeedERP__Shipping_Company__c, AcctSeedERP__Shipping_Contact__c, 
              AcctSeedERP__Shipping_Country__c, AcctSeedERP__Shipping_Postal_Code__c, AcctSeedERP__Shipping_State__c, 
              AcctSeedERP__Shipping_Street__c, AcctSeedERP__Status__c, AcctSeedERP__Type__c, AcctSeedERP__Vendor_City__c, 
              AcctSeedERP__Vendor_Contact__c, AcctSeedERP__Vendor_Country__c, AcctSeedERP__Vendor_Postal_Code__c, 
              AcctSeedERP__Vendor_State__c, AcctSeedERP__Vendor_Street__c, AcctSeedERP__Vendor__c, AcctSeedERP__Line_Count__c, 
              AcctSeedERP__Total__c, AcctSeedERP__Ledger__c, Customer_s_ETA__c, Sales_Order__c, Shipped_Date__c, 
              Expected_Delivery__c, Stage__c, Paid_Amount__c, Paid_Amount_Formula__c, Balance__c, Unreceived_Quantity__c, 
              Number_Of_Lines__c, GL_Account_Variable_1__c, Opportunity_Readonly__c, Project__c, Order_ETA__c FROM 
              AcctSeedERP__Purchase_Order__c
             where sales_order__c=:so.id limit 1];
        
        
        PageReference pageRef = Page.PurchaseOrderPDFInvoice;
        Test.setCurrentPage(pageRef);
		
        ApexPages.currentPage().getParameters().put('id', po.id);
        
        Apexpages.StandardController std = new ApexPages.StandardController(po);
        
        PurchaseOrderPDFExtension sls = new PurchaseOrderPDFExtension(std);
        

    }
}
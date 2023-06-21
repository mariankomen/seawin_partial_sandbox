@isTest 
public class MassEditSalesOrderScreenTest 
{
    @testsetup static void createdAta(){
        
          //Profile pf = [Select Id from profile where Name = 'China Inside Sales Rep']; 
        //Profile pf = [Select Id from profile where Name = 'System Administrator']; 
        //Profile pf = [Select Id from profile where Name = 'Sales Rep'];
         
        String orgId = UserInfo.getOrganizationId(); 
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName = orgId + dateString + RandomId; 
        
        //User uu1 = new User(firstname = 'ABC', 
          //                   lastName = 'XYZ', 
            //                 email = uniqueName + '@test' + orgId + '.org', 
              //               Username = uniqueName + '@test' + orgId + '.org', 
                //             EmailEncodingKey = 'ISO-8859-1', 
                  //           Alias = uniqueName.substring(18, 23), 
                    //         TimeZoneSidKey = 'America/Los_Angeles', 
                      //       LocaleSidKey = 'en_US', 
                        //     LanguageLocaleKey = 'en_US', 
                          //   ProfileId = pf.Id
                            //); 

        //insert uu1;
        
        //Sales_rep__c sr = new Sales_rep__c();
        //sr.Active__c = 'Yes';
        //sr.Name = 'John Doe';
        //sr.User__c = uu1.id;
        
        //insert sr;
        
        //uu1.Sales_Rep_Id__c = sr.id;
        
        //update uu1;
        
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
		
        // create contact
        Contact cont = new Contact();
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.LeadSource = 'AAOHA 2020';
        cont.GL_Account_Variable_1__c = accVar.Id;
        insert cont;
        
        Contact cont2 = new Contact();
        cont2.LastName = 'myLastName2';
        cont2.AccountId = acct.Id;
        cont2.LeadSource = 'Customer Event';
        cont2.GL_Account_Variable_1__c = accVar.Id;
        insert cont2;        
        
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

        AcctSeed__Accounting_Variable__c glav = new AcctSeed__Accounting_Variable__c(
          Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1');
      
        insert glav;
        AcctSeed__GL_Account__c gla = new AcctSeed__GL_Account__c();
        gla.name = '2010-Vouchers Payable';
        gla.AcctSeed__Type__c = 'Balance Sheet';
        gla.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gla.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gla.AcctSeed__Active__c = true;
        gla.AcctSeed__Bank__c = true;
        gla.GL_Account_Variable_1__c = glav.id;
        
        insert gla;

        Product2 kit = new Product2();
        
        kit.Name = 'myProduct';
        kit.ProductCode = 'ABC123';
        kit.Description = 'myDescription';
        kit.AcctSeed__Unit_Cost__c = 100;
        kit.IsActive = true;
        kit.Category__c = 'Shower Door';
        kit.Sub_Category__c = 'Single Sliding';
        kit.AcctSeed__Inventory_Type__c = 'Kit';
        kit.AcctSeed__Expense_GL_Account__c = gla.id;
        kit.AcctSeed__Inventory_GL_Account__c = gla.id;
        kit.AcctSeed__Revenue_GL_Account__c = gla.id;
        kit.AcctSeed__Inventory_Product__c = false;
        
        insert kit;


        AcctSeed__Product_Part__c part = new AcctSeed__Product_Part__c();
        
        part.AcctSeed__Quantity__c = 1;
        part.Kit_Children__c = prod.id;
        part.Kit_Product__c = kit.id;
        
        insert part;
       
    }
    @isTest static void MassEditLines() 
 	{
        opportunity opp = [select id, name from opportunity where name='myOpportunity' limit 1];
        
        acctseederp__sales_order__c so = [select id, name from AcctseedERP__Sales_Order__c where 
                                          AcctSeedERP__opportunity__c =:opp.id limit 1];
        
        acctseederp__sales_order_line__c sol = [select id from acctseederp__sales_order_line__c
                                                  where acctseederp__sales_order__c =:so.id limit 1];
        
        list<acctseederp__sales_order_line__c> soList = new list<acctseederp__sales_order_line__c>{sol};
        
        product2 prod = [select id from product2 where name ='myProduct' limit 1];
        
        test.startTest();
        
        PageReference pageRef = Page.MassEditSalesOrderScreenPage;//Observe how we set the Page here
        Test.setCurrentPage(pageRef);
        


        AcctSeedERP__Sales_Order_Line__c soliness = new AcctSeedERP__Sales_Order_Line__c(); 
        
        soliness.AcctSeedERP__Sales_Order__c = so.id;
        soliness.AcctSeedERP__Unit_Price__c = 1.1;
        soliness.AcctSeedERP_Description__c = 'This is salesorder line item';
        soliness.AcctSeedERP__Product__c = prod.id;
        soliness.AcctSeedERP__Quantity_Ordered__c = 0;
        
        insert soliness;
        // with sales order lines
        ApexPages.currentPage().getParameters().put('id', so.id);
        ApexPages.StandardSetController stdset = new ApexPages.StandardSetController(soList);
        MassEditSalesOrderScreenExtension exts = new MassEditSalesOrderScreenExtension(stdset);
        ApexPages.currentPage().getParameters().put('solId', sol.id);
        
        exts.no();
        exts.solid = sol.id;
        exts.UpdateLine();
        
        exts.trashIt();
        MassEditSalesOrderScreenExtension.childrenWrapper wrapp = new MassEditSalesOrderScreenExtension.childrenWrapper(so.id,so.id,1);
        
        
        
        ApexPages.currentPage().getParameters().put('solId', soliness.id);
        exts.newQuantity = soliness.Id;
        exts.handleQuantity();
        exts.helpTest();
        exts.UpdateLine();
        // exts.yes();
        exts.handleQuantity();
        exts.back();
        
        exts.trashIt();

        test.stopTest();

    }
    
}
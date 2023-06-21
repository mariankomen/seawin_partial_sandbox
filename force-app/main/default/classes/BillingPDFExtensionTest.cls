@isTest
public class BillingPDFExtensionTest {
    
    @testSetup static void createBillingData(){
        
        list<AcctSeed__Accounting_Variable__c> avList = new list<AcctSeed__Accounting_Variable__c>();
        
        avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin China',
                                                        AcctSeed__Type__c = 'GL Account Variable 1', 
                                                        Billing_Header__c = 'test header', 
                                                        Billing_Footer__c = 'test footer', 
                                                        Billing_Terms__c = 'test terms',
                                                       company_name__c = 'Seawin China'));
        
        avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1',
                                                        Billing_Header__c = 'test header', Billing_Footer__c = 'test footer', 
                                                        Billing_Terms__c = 'test terms',
                                                       company_name__c = 'Seawin USA'));
        insert avList;
        
         Profile pf = [Select Id from profile where Name = 'System Administrator']; 
        //Profile pf = [Select Id from profile where Name = 'Sales Rep'];
        
        String orgId = UserInfo.getOrganizationId(); 
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
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
        
        // create account
        Account acct = new Account();
        
        acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = avList[1].id;
        acct.AcctSeed__Billing_Terms_Name__c = 'Test Billing Terms';
        
        insert acct;
        
        // create contact
        Contact cont = new Contact();
        
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.GL_Account_Variable_1__c = avList[1].id;
        
        insert cont;
        
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = avList[0].id;
        
        insert aegl;
        
        // Gl account with bank unchecked
        AcctSeed__GL_Account__c ga = new AcctSeed__GL_Account__c();
        ga.Name = 'GL Account Test';
        ga.AcctSeed__Active__c = true;
        ga.AcctSeed__Type__c = 'Revenue';
        ga.AcctSeed__Sub_Type_1__c = 'Product Revenue';
        ga.AcctSeed__Sub_Type_2__c = 'Product Family 1';
        ga.AcctSeed__Bank__c = false;
        ga.GL_Account_Variable_1__c = avList[0].id;
        
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
        prod.Type__c = 'other';
        
        insert prod;
        
        // create opportunity
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.Sales_Rep_O__c = sr.id;
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Closed Won';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = avList[1].id;
        
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
        
        abf.Name = 'myFormat';
        abf.AcctSeed__Type__c = 'Billing';
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
        //salesorder.AcctSeedERP__Opportunity__c = opp.Id;
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
        salesorder.GL_Account_Variable_1__c = avList[1].id;
        
        
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
        
        Date d = Date.today();

        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        
        Integer year = d.year();
        String month = d.month() > 9 ? '' + d.month() : '0' + d.month();

        ap.Name = year + '-' + month;
        ap.AcctSeed__Start_Date__c = Date.NewInstance(year, d.month(), 1);
        ap.AcctSeed__End_Date__c = Date.NewInstance(year, d.month(), Date.DaysInMonth(year, d.month()));
        ap.AcctSeed__Status__c = 'Open';
            
        insert ap;
        
        
        
        AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c();
        
        av.Name = 'GL Account Variable Test';
        av.AcctSeed__Active__c = true;
        av.AcctSeed__Type__c = 'GL Account Variable 1';
        
        insert av;
        
        AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
        
        bill.AcctSeed__Status__c = 'Approved';
        bill.AcctSeed__PDF_Email_Status__c = 'Unsent';
        bill.AcctSeed__Billing_Format__c = abf.id;
        bill.AcctSeedERP__Sales_Order__c = salesorder.id; 
        bill.AcctSeed__Date__c = Date.Today();
        bill.AcctSeed__Due_Date2__c = Date.Today();
        bill.AcctSeed__Ledger__c = salesorder.AcctSeedERP__Ledger__c;
        bill.AcctSeed__Opportunity__c = salesorder.AcctSeedERP__Opportunity__c;
        bill.AcctSeed__Customer__c = salesorder.AcctSeedERP__Customer__c;
        bill.AcctSeed__Accounting_Period__c = ap.id;

        insert bill;
        
        AcctSeed__Billing_Line__c bline = new AcctSeed__Billing_Line__c();
        bline.AcctSeed__Billing__c = bill.id;
        bline.AcctSeed__Date__c = date.today();
        bline.AcctSeed__Hours_Units__c = 1;
        bline.AcctSeed__Product__c = solines.AcctSeedERP__Product__c;
        bline.AcctSeedERP__Sales_Order_Line__c = solines.id;
        bline.AcctSeed__Rate__c = solines.AcctSeedERP__Unit_Price__c;
        bline.Item_Description__c = solines.Item_Description__c;
        
        insert bline;
        
        // second billing
        AcctSeed__Billing__c bill2 = new AcctSeed__Billing__c();
        
        bill2.AcctSeed__Status__c = 'Approved';
        bill2.AcctSeed__PDF_Email_Status__c = 'Unsent';
        bill2.AcctSeed__Billing_Format__c = abf.id;
        //bill2.AcctSeedERP__Sales_Order__c = salesorder.id; 
        bill2.AcctSeed__Date__c = Date.Today();
        bill2.AcctSeed__Due_Date2__c = Date.Today();
        bill2.AcctSeed__Ledger__c = salesorder.AcctSeedERP__Ledger__c;
        bill2.AcctSeed__Opportunity__c = salesorder.AcctSeedERP__Opportunity__c;
        bill2.AcctSeed__Customer__c = salesorder.AcctSeedERP__Customer__c;
        bill2.AcctSeed__Accounting_Period__c = ap.id;

        insert bill2;
        
        AcctSeed__Billing_Line__c bline2 = new AcctSeed__Billing_Line__c();
        bline2.AcctSeed__Billing__c = bill2.id;
        bline2.AcctSeed__Date__c = date.today();
        bline2.AcctSeed__Hours_Units__c = 1;
        bline2.AcctSeed__Product__c = solines.AcctSeedERP__Product__c;
        bline2.AcctSeedERP__Sales_Order_Line__c = solines.id;
        bline2.AcctSeed__Rate__c = solines.AcctSeedERP__Unit_Price__c;
        bline2.Item_Description__c = solines.Item_Description__c;
        
        insert bline2;



        AcctSeed__Accounting_Variable__c accVar_r = new AcctSeed__Accounting_Variable__c();
        accVar_r.Name = 'Seawin USA';
        accVar_r.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar_r;

        Account acct_t = new Account();
        //acct.Sales_Rep_O__c = sr.id;
        acct_t.Name = 'myAccount';
        acct_t.Type = 'Designer';
        acct_t.AcctSeed__Accounting_Type__c = 'Customer';
        acct_t.AcctSeed__GL_Account_Variable_1__c = accVar_r.Id;
        insert acct_t;

        // AcctSeed__Cash_Receipt__c cr = new AcctSeed__Cash_Receipt__c();
        
        // cr.AcctSeed__Receipt_Date__c = Date.today();
        // cr.AcctSeed__Account__c = acct_t.id;
        // cr.AcctSeed__Amount__c = 30;
        // cr.AcctSeed__Payment_Reference__c = 'Reference Test';
        // cr.AcctSeed__GL_Account_Variable_1__c = accVar_r.id;
        
        // insert cr;
        
        // AcctSeed__Billing_Cash_Receipt__c br = new AcctSeed__Billing_Cash_Receipt__c();
        
        // br.AcctSeed__Applied_Amount__c = 30;
        // br.AcctSeed__Billing__c = bill.id;
        // br.AcctSeed__Cash_Receipt__c = cr.id;
        // //br.AcctSeed__Period_Applied__c = ap.id;
        
        // insert br;
    }
    
    @isTest static void With_SalesOrder(){
        AcctSeed__Accounting_Variable__c av = [select id from AcctSeed__Accounting_Variable__c
                                               where name='Seawin USA' limit 1];
        Account accts = [select id from account where name='myAccount' limit 1];
        
        acctseederp__sales_order__c so = [select id from acctseederp__sales_order__c 
                                          where acctseederp__customer__c =:accts.id limit 1];
        
        Account acct = new Account();
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__Accounting_Type__c = 'Other';
        acct.AcctSeed__GL_Account_Variable_1__c = av.id;
        insert acct;
        
        AcctSeed__Billing_Format__c format = [select id from AcctSeed__Billing_Format__c where
                                             name='myFormat' limit 1];
        
        Acctseed__Ledger__c ledger = [select id from AcctSeed__Ledger__c where name='myLedger' limit 1];
        
        AcctSeed__Billing__c billl = new AcctSeed__Billing__c();
        
        billl.AcctSeed__Status__c = 'Approved';
        billl.AcctSeed__Date__c = Date.Today();
        billl.AcctSeed__Customer__c = acct.Id;
        billl.AcctSeed__Billing_Format__c = format.id;
        billl.AcctSeed__Ledger__c = ledger.id;
        insert billl;
        
		acctseed__billing__c bill = [select id from acctseed__billing__c where AcctSeedErP__sales_Order__c != null limit 1];
        
        Test.startTest();
        PageReference pageRef = Page.BillingInvoicePDF;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdset = new ApexPages.StandardController(bill);
        BillingPDFExtension cbf = new BillingPDFExtension(stdset);
        
        Test.stopTest();
		  
    }
    @isTest static void Without_SalesOrder(){
        AcctSeed__Accounting_Variable__c av = [select id from AcctSeed__Accounting_Variable__c
                                               where name='Seawin USA' limit 1];
        Account accts = [select id from account where name='myAccount' limit 1];
        
        acctseederp__sales_order__c so = [select id from acctseederp__sales_order__c 
                                          where acctseederp__customer__c =:accts.id limit 1];
        
        Account acct = new Account();
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__Accounting_Type__c = 'Other';
        acct.AcctSeed__GL_Account_Variable_1__c = av.id;
        insert acct;
        
        AcctSeed__Billing_Format__c format = [select id from AcctSeed__Billing_Format__c where
                                             name='myFormat' limit 1];
        
        Acctseed__Ledger__c ledger = [select id from AcctSeed__Ledger__c where name='myLedger' limit 1];
        
        AcctSeed__Billing__c billl = new AcctSeed__Billing__c();
        
        billl.AcctSeed__Status__c = 'Approved';
        billl.AcctSeed__Date__c = Date.Today();
        billl.AcctSeed__Customer__c = acct.Id;
        billl.AcctSeed__Billing_Format__c = format.id;
        billl.AcctSeed__Ledger__c = ledger.id;
        insert billl;
        
		acctseed__billing__c bill = [select id from acctseed__billing__c where AcctSeedErP__sales_Order__c = null limit 1];
        
        Test.startTest();
        PageReference pageRef = Page.BillingInvoicePDF;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdset = new ApexPages.StandardController(bill);
        BillingPDFExtension cbf = new BillingPDFExtension(stdset);
        
        Test.stopTest();
		  
    }
}
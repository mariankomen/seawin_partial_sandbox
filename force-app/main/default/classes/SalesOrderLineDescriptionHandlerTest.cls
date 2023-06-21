@isTest
public class SalesOrderLineDescriptionHandlerTest {
    
    @testSetup static void createData(){
        
        // Profile pf = [Select Id from profile where Name = 'System Administrator']; 
        Profile pf = [Select Id from profile where Name = 'Sales Rep'];
        
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
        
        // create account
        Account acct = new Account();
        
        acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        
        insert acct;
        
        // create contact
        Contact cont = new Contact();
        
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        
        insert cont;
        
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        
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
        
        // create opportunity
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.Sales_Rep_O__c = sr.id;
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Closed Won';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        
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
        
        Date dates = date.today();
        
        Integer monthDays = date.daysInMonth(dates.year(), dates.month());
        
        ap.Name = dates.year() + '-0' + dates.month();
        ap.AcctSeed__Status__c = 'Open';
        ap.AcctSeed__Start_Date__c = Date.newInstance(dates.year(), dates.month(), dates.day());
        ap.AcctSeed__End_Date__c = Date.newInstance(dates.year(), dates.month(), monthDays);
        
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
        bill.AcctSeed__Shipping_City__c = salesorder.AcctSeedERP__Shipping_City__c;
        bill.AcctSeed__Shipping_Contact__c = salesorder.Contact__c;
        bill.AcctSeed__Shipping_Country__c = salesorder.AcctSeedERP__Shipping_Country__c;
        bill.AcctSeed__Shipping_PostalCode__c = salesorder.AcctSeedERP__Shipping_PostalCode__c;
        bill.AcctSeed__Shipping_State__c = salesorder.AcctSeedERP__Shipping_State__c;
        bill.AcctSeed__Shipping_Street__c = salesorder.AcctSeedERP__Shipping_Street__c;
        bill.AcctSeed__Billing_Contact__c = salesorder.Contact__c;
        bill.AcctSeed__Billing_Country__c = salesorder.AcctSeedERP__Billing_Country__c;
        bill.AcctSeed__Billing_PostalCode__c = salesorder.AcctSeedERP__Billing_PostalCode__c;
        bill.AcctSeed__Billing_State__c = salesorder.AcctSeedERP__Billing_State__c;
        bill.AcctSeed__Billing_Street__c = salesorder.AcctSeedERP__Billing_Street__c;
        bill.AcctSeed__Billing_City__c = salesorder.AcctSeedERP__Billing_City__c;
        bill.AcctSeed__Accounting_Period__c = ap.id;

        insert bill;
        
        AcctSeed__Billing_Line__c bline = new AcctSeed__Billing_Line__c();
        bline.AcctSeed__Billing__c = bill.id;
        bline.AcctSeed__Date__c = date.today();
        bline.AcctSeed__Hours_Units__c = 1;
        bline.AcctSeed__Product__c = solines.AcctSeedERP__Product__c;
        bline.AcctSeedERP__Sales_Order_Line__c = solines.id;
        bline.AcctSeed__Rate__c = solines.AcctSeedERP__Unit_Price__c;
        bline.Item_Description__c = 'billing line item description first';
        
        insert bline;
        
        // second billing
        AcctSeed__Billing__c bill2 = new AcctSeed__Billing__c();
        
        bill2.AcctSeed__Status__c = 'Approved';
        bill2.AcctSeed__PDF_Email_Status__c = 'Unsent';
        bill2.AcctSeed__Billing_Format__c = abf.id;
        bill2.AcctSeedERP__Sales_Order__c = salesorder.id; 
        bill2.AcctSeed__Date__c = Date.Today();
        bill2.AcctSeed__Due_Date2__c = Date.Today();
        bill2.AcctSeed__Ledger__c = salesorder.AcctSeedERP__Ledger__c;
        bill2.AcctSeed__Opportunity__c = salesorder.AcctSeedERP__Opportunity__c;
        bill2.AcctSeed__Customer__c = salesorder.AcctSeedERP__Customer__c;
        bill2.AcctSeed__Shipping_City__c = salesorder.AcctSeedERP__Shipping_City__c;
        bill2.AcctSeed__Shipping_Contact__c = salesorder.Contact__c;
        bill2.AcctSeed__Shipping_Country__c = salesorder.AcctSeedERP__Shipping_Country__c;
        bill2.AcctSeed__Shipping_PostalCode__c = salesorder.AcctSeedERP__Shipping_PostalCode__c;
        bill2.AcctSeed__Shipping_State__c = salesorder.AcctSeedERP__Shipping_State__c;
        bill2.AcctSeed__Shipping_Street__c = salesorder.AcctSeedERP__Shipping_Street__c;
        bill2.AcctSeed__Billing_Contact__c = salesorder.Contact__c;
        bill2.AcctSeed__Billing_Country__c = salesorder.AcctSeedERP__Billing_Country__c;
        bill2.AcctSeed__Billing_PostalCode__c = salesorder.AcctSeedERP__Billing_PostalCode__c;
        bill2.AcctSeed__Billing_State__c = salesorder.AcctSeedERP__Billing_State__c;
        bill2.AcctSeed__Billing_Street__c = salesorder.AcctSeedERP__Billing_Street__c;
        bill2.AcctSeed__Billing_City__c = salesorder.AcctSeedERP__Billing_City__c;
        bill2.AcctSeed__Accounting_Period__c = ap.id;

        insert bill2;
        
        AcctSeed__Billing_Line__c bline2 = new AcctSeed__Billing_Line__c();
        bline2.AcctSeed__Billing__c = bill2.id;
        bline2.AcctSeed__Date__c = date.today();
        bline2.AcctSeed__Hours_Units__c = 1;
        bline2.AcctSeed__Product__c = solines.AcctSeedERP__Product__c;
        bline2.AcctSeedERP__Sales_Order_Line__c = solines.id;
        bline2.AcctSeed__Rate__c = solines.AcctSeedERP__Unit_Price__c;
        bline2.Item_Description__c = 'billing line item description second.';
        
        insert bline2;
        
    }
    
    @isTest static void TestProcess(){
        Opportunity opp = [select id from opportunity where name='myOpportunity' limit 1];
        
        acctseederp__sales_order__c so = [select id from acctseederp__sales_order__c 
                                          where acctseederp__opportunity__c =:opp.id limit 1];
        
        // get the sales order lines list
        list<acctseederp__sales_order_line__c> solinelist = new list<acctseederp__sales_order_line__c>([SELECT Id, Name, AcctSeedERP__Sales_Order__c,
                                                        AcctSeedERP__Product__r.Name,
                                                        Item_Description__c,
                                                        AcctSeedERP__Comment__c, AcctSeedERP__GL_Account_Variable_1__c, 
                                                        AcctSeedERP__GL_Account_Variable_2__c, 
                                                        AcctSeedERP__GL_Account_Variable_3__c, 
                                                        AcctSeedERP__GL_Account_Variable_4__c, 
                                                        AcctSeedERP__Opportunity_Product_Id__c, 
                                                        AcctSeedERP__Product__c, 
                                                        AcctSeedERP__Purchase_Order_Line__c, 
                                                        AcctSeedERP__Quantity_Manufactured__c, 
                                                        AcctSeedERP__Quantity_Needed__c, 
                                                        AcctSeedERP__Quantity_Ordered_Manufacturing__c, 
                                                        AcctSeedERP__Quantity_Ordered_Supplier__c, 
                                                        AcctSeedERP__Quantity_Ordered__c, 
                                                        AcctSeedERP__Quantity_Received_Supplier__c, 
                                                        AcctSeedERP__Total__c, AcctSeedERP__Unit_Price__c, 
                                                        AcctSeedERP__Quantity_Allocated__c, 
                                                        AcctSeedERP__Quantity_Shipped__c, 
                                                        AcctSeedERP_Description__c, Size__c, 
                                                        SortOrder__c, ProductCode__c, IsAllocated__c, 
                                                        QuantityFormula__c, Quantity_Allocated_Formula__c, 
                                                        Quantity_Shipped_Formula__c, Total_Price__c, 
                                                        Sales_Price__c, Quantity_Needed_Formula__c, 
                                                        CreatedDate FROM AcctSeedERP__Sales_Order_Line__c where 
                                                        AcctSeedERP__Sales_Order__c =: so.id]);
        
        
        for(acctseederp__sales_order_line__c sline : solinelist){
            
            sline.item_description__c = 'new item line description';
            
        }
        
        
        update solinelist;
        
        map<id, acctseederp__sales_order_line__c> SOLMap = new map<id, acctseederp__sales_order_line__c>(solinelist);
        
        // get all the related billing lines
        
        list<AcctSeed__Billing_Line__c> blines = [select item_Description__c, size__c,AcctSeedERP__Sales_Order_Line__c
                                                      from AcctSeed__Billing_Line__c
                                                     where AcctSeedERP__Sales_Order_Line__c in:SOLMap.keyset()];
        
        for(AcctSeed__Billing_Line__c bline : blines){
            
            system.assert(bline.Item_Description__c == 'new item line description'); 
        }
    }
}
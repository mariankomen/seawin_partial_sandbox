@isTest
public with sharing class CommissionsPDFControllerTest {
    
    @TestSetup
    static void makeData(){
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
                            ProfileId = pf.Id,
                            Receive_Commission__c = 'After each payment',
                            Ref_Rep_Price_Level_1_12__c = 4
                           ); 
        
        insert uu1;

        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        
        gl.name = 'GL Account First';
        gl.AcctSeed__type__c = 'Expense';
        gl.AcctSeed__Sub_Type_1__c = 'Facilities';
        gl.AcctSeed__Sub_Type_1__c = 'Rent';
        
        insert gl;

        AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();
        
        abf.Name = 'newPDF Format';
        abf.AcctSeed__Type__c = 'Purchase Order';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        insert abf;

        List<Product2> prodList = new List<Product2>();
        for(integer i=0; i<5; i++){
            Product2 prod = new Product2();
        
            prod.Name = 'myProduct';
            prod.ProductCode = 'ABC123';
            prod.Description = 'myDescription';
            prod.AcctSeed__Unit_Cost__c = 100;
            prod.IsActive = true;
            prod.Category__c = 'Shower Door';
            prod.Sub_Category__c = 'Single Sliding';
            prod.AcctSeed__Inventory_Type__c = 'Purchased';
            prod.AcctSeed__Expense_GL_Account__c = gl.id;
            prod.AcctSeed__Inventory_GL_Account__c = gl.id;
            prod.AcctSeed__Revenue_GL_Account__c = gl.id;
            prod.AcctSeed__Inventory_Product__c = true;
            prod.Commissionable_Product__c = true;
            prod.Type__c = 'Other';

            prodList.add(prod);
        }
        insert prodList;

        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'Seawin USA';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;

        Sales_rep__c sr = new Sales_rep__c();
        sr.Active__c = 'Yes';
        sr.Name = 'John Doe';
        sr.User__c = uu1.id;
        sr.Receive_Commission__c = 'After each payment';
        
        insert sr;
        
        uu1.Sales_Rep_Id__c = sr.id;
        
        update uu1;
        
       // create account
        Account acct = new Account();
        
        acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.BillingStreet = 'street';
        acct.BillingCity = 'city';
        acct.BillingState = 'state';
        acct.BillingPostalCode = 'postalcode';
        acct.BillingCountry = 'country';
        
        insert acct;

        AcctSeed__GL_Account__c expenceAcc = new AcctSeed__GL_Account__c();
        expenceAcc.name = 'glaccount';
        expenceAcc.AcctSeed__Type__c = 'Expense';
        expenceAcc.AcctSeed__Sub_Type_1__c = 'Facilities';
        expenceAcc.AcctSeed__Sub_Type_2__c = 'Rent';
        expenceAcc.AcctSeed__Bank__c = true;
        expenceAcc.GL_Account_Variable_1__c = accVar.id;
        

        insert expenceAcc;

        Account acct2 = new Account();
        acct2.Name = 'Manufacturer Representative';
        acct2.Sales_Rep_O__c = sr.id;
        acct2.Type = 'Designer';
        acct2.AcctSeed__Accounting_Type__c = 'Manufacture Representative';
        acct2.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        acct2.Price_Level_1_12__c = 1;
        acct2.Price_Level_13_20__c = 1;
        acct2.Price_Level_21_26__c = 1;
        acct2.Price_Level_27_30__c = 1;
        acct2.AcctSeed__Default_Expense_GL_Account__c = expenceAcc.Id;
        acct2.Receive_Commission__c = 'After each payment';
        insert acct2;

        Account acct3 = new Account();
        acct3.Name = 'Specified Representative';
        acct3.Sales_Rep_O__c = sr.id;
        acct3.Type = 'Designer';
        acct3.AcctSeed__Accounting_Type__c = 'Specified Representative';
        acct3.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        acct3.Price_Level_1_12__c = 1;
        acct3.Price_Level_13_20__c = 1;
        acct3.Price_Level_21_26__c = 1;
        acct3.Price_Level_27_30__c = 1;
        acct3.Receive_Commission__c = 'After each payment';
        insert acct3;

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
        ga.GL_Account_Variable_1__c = accVar.Id;
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
        prod.Commissionable_Product__c = true;
        
        insert prod;
        
        // create opportunity
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.Referral_Sales_Rep__c = uu1.id;
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Closed Won';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = accVar.Id;
        opp.Price_Level__c = 'Level 1';
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

        AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
        
        bill.AcctSeed__Status__c = 'Approved';
        bill.AcctSeed__PDF_Email_Status__c = 'Unsent';
        bill.AcctSeed__Billing_Format__c = abf.id;
        // bill.AcctSeedERP__Sales_Order__c = salesorder.id; 
        bill.AcctSeed__Date__c = Date.Today();
        bill.AcctSeed__Due_Date2__c = Date.Today();
        bill.AcctSeed__Ledger__c = ledger.Id;
        bill.AcctSeed__Opportunity__c = opp.Id;
        bill.AcctSeed__Customer__c = acct.Id;
        bill.AcctSeed__Accounting_Period__c = ap.id;

        insert bill;

        // create a sales order
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c(); 
        

        salesorder.AcctSeedERP__Customer__c = acct.Id;
        // salesorder.AcctSeedERP__Opportunity__c = opp.Id;
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
        salesorder.Referral_Sales_Rep__c = uu1.Id;
        
        insert salesorder;

        AcctSeedERP__Sales_Order_Line__c solines = new AcctSeedERP__Sales_Order_Line__c(); 
        
        solines.AcctSeedERP__Sales_Order__c = salesorder.id;
        solines.AcctSeedERP__Unit_Price__c = 1.1;
        solines.AcctSeedERP_Description__c = 'This is salesorder line item';
        solines.AcctSeedERP__Product__c = prodList[0].id;
        solines.AcctSeedERP__Quantity_Ordered__c = 2;
        
        insert solines;

        Sales_Order_Commissions__c commissions = new Sales_Order_Commissions__c();
      
        commissions.Owner__c = UserInfo.getuserId();
        commissions.Sales_Order__c = salesorder.id;
        commissions.Commission_Amount__c = 50;
        
        
        insert commissions;
        Sales_Order_Commissions__c commissions1 = new Sales_Order_Commissions__c();
      
        commissions1.Owner__c = UserInfo.getuserId();
        commissions1.Sales_Order__c = salesorder.id;
        commissions1.Commission_Amount__c = 50;
        commissions1.Manufacturer_Rep__c = acct2.Id;
        commissions1.Commission_Paid__c = 0;
        
        insert commissions1;
        Sales_Order_Commissions__c commissions2 = new Sales_Order_Commissions__c();
      
        commissions2.Owner__c = UserInfo.getuserId();
        commissions2.Sales_Order__c = salesorder.id;
        commissions2.Commission_Amount__c = 50;
        commissions2.Specified_Rep__c = acct3.Id;
        commissions2.Commission_Paid__c = 0;
        
        
        insert commissions2;
        Sales_Order_Commissions__c commissions3 = new Sales_Order_Commissions__c();
      
        commissions3.Owner__c = UserInfo.getuserId();
        commissions3.Sales_Order__c = salesorder.id;
        commissions3.Commission_Amount__c = 50;
        commissions3.Sales_Rep_Company_Name__c = acct3.Id;
        commissions3.Commission_Paid__c = 0;
        
        
        insert commissions3;

        Sales_Order_Commissions__c commissions4 = new Sales_Order_Commissions__c();
      
        commissions4.Owner__c = uu1.Id;
        commissions4.Sales_Order__c = salesorder.id;
        commissions4.Commission_Amount__c = 50;
        commissions4.Referral_Sales_Rep__c = uu1.Id;
        commissions4.Commission_Paid__c = 0;
        
        
        insert commissions4;

    }

    @isTest
    public static void commissionPDFCtrlTest(){
        User u = [SELECT Id FROM User WHERE FirstName = 'ABC'];
        // AcctSeedERP__Sales_Order__c so = [SELECT Id, 
        //                                         Commission_Rate_Sales_Rep__c, 
        //                                         commission_rate_manufacturer_rep__c, 
        //                                         commission_rate_referral_sales_rep__c, 
        //                                         commission_rate_specified_rep__c 
        //                                 FROM AcctSeedERP__Sales_Order__c 
        //                                 WHERE AcctSeedERP__Billing_Country__c='Afghanistan' LIMIT 1];
        // so.Commission_Rate_Sales_Rep__c = null;                                
        // so.commission_rate_manufacturer_rep__c = null;                                
        // so.commission_rate_referral_sales_rep__c = null;                                
        // so.commission_rate_specified_rep__c = null;   
        // update so;                            
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', u.Id);
        CommissionsPDFController ctrl = new CommissionsPDFController();


        String dec6 = ctrl.pdf_date;
        Test.stopTest();
    }
}
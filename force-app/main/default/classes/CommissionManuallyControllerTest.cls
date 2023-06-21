@isTest
public with sharing class CommissionManuallyControllerTest {
    
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
                            ProfileId = pf.Id
                           ); 
        
        insert uu1;

        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'Seawin USA';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;

        Sales_rep__c sr = new Sales_rep__c();
        sr.Active__c = 'Yes';
        sr.Name = 'John Doe';
        sr.User__c = uu1.id;
        sr.Team__c = String.valueOf(uu1.Id);
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
        acct.AcctSeed__Accounting_Type__c = 'Sales Represantative';
        
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
        opp.GL_Account_Variable_1__c = accVar.Id;
        opp.OwnerId = uu1.Id;
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
        
        insert salesorder;
        Sales_Order_Commissions__c commissions = new Sales_Order_Commissions__c();
      
        commissions.Owner__c = UserInfo.getuserId();
        commissions.Sales_Order__c = salesorder.id;
        commissions.Commission_Amount__c = 50;
        
        
        insert commissions;
    }

    @isTest
    public static void CommissionManuallyControllerTest(){
        Sales_Order_Commissions__c soc = [SELECT Id FROM Sales_Order_Commissions__c LIMIT 1];
        AcctSeedERP__Sales_Order__c so = [SELECT Id FROM AcctSeedERP__Sales_Order__c LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(soc);
        CommissionManuallyController con = new CommissionManuallyController(sc);
        PageReference pageRef = Page.CreateManualCommissionPage;
        pageRef.getParameters().put('salesOrderId', String.valueOf(so.Id));
        con.saveCustom();
        con.cancel();
        con.saveAndNew();
    }
    @isTest
    public static void CommissionManuallyControllerCovTest(){
        Sales_Order_Commissions__c soc = [SELECT Id FROM Sales_Order_Commissions__c LIMIT 1];
        AcctSeedERP__Sales_Order__c so = [SELECT Id FROM AcctSeedERP__Sales_Order__c LIMIT 1];
        so.Manufacturer_Rep__c = [SELECT Id FROM Account WHERE Name='myAccount' LIMIT 1].Id;
        update so;
        ApexPages.StandardController sc = new ApexPages.StandardController(soc);
        CommissionManuallyController con = new CommissionManuallyController(sc);
        PageReference pageRef = Page.CreateManualCommissionPage;
        pageRef.getParameters().put('salesOrderId', String.valueOf(so.Id));
        con.saveCustom();
        con.cancel();
        con.saveAndNew();
    }
    @isTest
    public static void CommissionManuallyControllerCovNewTest(){
        Sales_Order_Commissions__c soc = [SELECT Id FROM Sales_Order_Commissions__c LIMIT 1];
        AcctSeedERP__Sales_Order__c so = [SELECT Id FROM AcctSeedERP__Sales_Order__c LIMIT 1];
        so.Manufacturer_Rep__c = [SELECT Id FROM Account WHERE Name='myAccount' LIMIT 1].Id;
        update so;
        ApexPages.StandardController sc = new ApexPages.StandardController(soc);
        CommissionManuallyController con = new CommissionManuallyController(sc);
        con.commission.Commission_Amount__c = 1;
        PageReference pageRef = Page.CreateManualCommissionPage;
        pageRef.getParameters().put('salesOrderId', String.valueOf(so.Id));
        con.saveCustom();
        con.cancel();
        con.saveAndNew();
    }
    @isTest
    public static void CommissionManuallyControllerCovNewTestOpp(){
        Sales_Order_Commissions__c soc = [SELECT Id FROM Sales_Order_Commissions__c LIMIT 1];
        Opportunity so = [SELECT Id FROM Opportunity LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(soc);
        CommissionManuallyController con = new CommissionManuallyController(sc);
        con.commission.Commission_Amount__c = 1;
        PageReference pageRef = Page.CreateManualCommissionPage;
        pageRef.getParameters().put('salesOrderId', String.valueOf(so.Id));
        con.saveCustom();
        con.cancel();
        con.saveAndNew();
    }

    @isTest
    public static void commissionCoverage(){
        CommissionManuallyController.coverage();
    }

}
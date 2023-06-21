@isTest
public class OpportunityProductsSortOrderTest {

    @testSetup static void CreateData(){
	// here you will create records for the test
        // what type of records ? records for objects that the controller needs and these objects
        // dependencies
 
        
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
        
        // create opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'myOpportunity';
        opp.Sales_Rep_O__c = sr.id;
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Follow up';
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
       // OpportunityLineItem oli = new OpportunityLineItem();
        //oli.OpportunityId = opp.Id;
        //oli.Product2Id = prod.Id;
        //oli.PricebookEntryId = pricebentry2.Id;
        //oli.Quantity = 10;
        //oli.UnitPrice = 100;
        //oli.Description = 'myDescription';
        //insert oli;
        

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
        
        
        List<OpportunityLineItem> OpLineItems = new List<OpportunityLineItem>();
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem();
        lineItem1.OpportunityId = opp.Id;
        lineItem1.Product2Id = prod.Id;
        lineItem1.PricebookEntryId = pricebentry2.Id;
        lineItem1.Quantity = 10;
        lineItem1.UnitPrice = 100;
        lineItem1.Description = 'myDescription';
        OpLineItems.add(lineItem1);
        
        OpportunityLineItem lineItem2 = new OpportunityLineItem();
        lineItem2.OpportunityId = opp.Id;
        lineItem2.Product2Id = prod.Id;
        lineItem2.PricebookEntryId = pricebentry2.Id;
        lineItem2.Quantity = 10;
        lineItem2.UnitPrice = 100;
        lineItem2.Description = 'myDescription';
        OpLineItems.add(lineItem2);
        
        insert OpLineItems;  
    }
    @isTest static void runTest(){   
        
        Opportunity opp = [select id from opportunity where name='myOpportunity' limit 1];
        List<OpportunityLineItem> oppLineItem = [select id, Quantity, UnitPrice
         from OpportunityLineItem 
         where OpportunityId =: opp.Id];
        
        PageReference pageRef = Page.OpportunityProductsSortOrderPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        
        //ApexPages.StandardSetController ss = new ApexPages.StandardSetController(oppLineItem);
        OpportunityProductsSortOrderController oli = new OpportunityProductsSortOrderController();
        ApexPages.currentPage().getParameters().put('sortstring', '[{"'+oppLineItem[0].id+'": 1}]');
        oli.createsort(); 
        oli.back();
        
        String json = oli.jsonStr;
        Boolean vis = oli.visible;
        
        System.assertEquals(true, vis);
        System.assertEquals(null, json);
    }
}
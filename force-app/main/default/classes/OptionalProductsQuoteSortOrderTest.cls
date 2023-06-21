@isTest
public class OptionalProductsQuoteSortOrderTest {
    
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
        
        OpportunityLineItem oli = new OpportunityLineItem();
        
        oli.OpportunityId = opp.Id;
        oli.Product2Id = prod.Id;
        oli.PricebookEntryId = pricebentry2.Id;
        oli.Quantity = 10;
        oli.UnitPrice = 100;
        oli.Description = 'myDescription';
        
        insert oli;

        Optional_Products_Opportunity__c opop = new Optional_Products_Opportunity__c();
        
        opop.Description__c = oli.Description;
        opop.UnitPrice__c = oli.UnitPrice;
        opop.Product__c = oli.Product2Id;
        opop.Opportunity__c = oli.OpportunityId;
        opop.PriceBookEntryId__c = oli.PricebookEntryId;
        opop.Quantity__c = 1;
        
        insert opop;
        
        Quote qt = new Quote();
        
        qt.OpportunityId = opp.id;
        qt.ExpirationDate = Date.today() + 7;
        qt.name = 'myQuote';
        qt.Pricebook2Id = priceb2.Id;
        
        insert qt;
        
        QuoteLineItem qlines = new QuoteLineItem();
        
        qlines.Description = oli.Description;
        qlines.UnitPrice = oli.UnitPrice;
        qlines.Product2id = oli.Product2Id;
        qlines.quoteid = qt.id;
        qlines.PriceBookEntryId = oli.PricebookEntryId;
        qlines.Quantity = 1;
        
        insert qlines;
        
        Optional_Products_Quote__c opq = new Optional_Products_Quote__c();
        
        opq.Description__c = oli.Description;
        opq.UnitPrice__c = oli.UnitPrice;
        opq.Product__c = oli.Product2Id;
        opq.quote__c = qlines.quoteid;
        opq.PriceBookEntryId__c = oli.PricebookEntryId;
        opq.Quantity__c = 1;
        
        insert opq;
        
        

    }
    
    @isTest static void StartTheTest(){
        Quote qt = [select id from Quote where name='myQuote' limit 1];
        
        // get the sales order lines list
        list<Optional_Products_Quote__c> quoteLines = new list<Optional_Products_Quote__c>([select id 
                                                    from Optional_Products_Quote__c 
                                                    where quote__c =: qt.id]);
        
        //PageReference pageRef = Page.SalesOrderLineSortOrder;
        //Test.setCurrentPage(pageRef);
		
        ApexPages.currentPage().getParameters().put('id', qt.id);
        
        ApexPages.StandardSetController stdset = new ApexPages.StandardSetController(quoteLines);
        
        OptionalProductsQuoteSortOrder opsl = new OptionalProductsQuoteSortOrder(stdset);
        
        ApexPages.currentPage().getParameters().put('sortstring', '[{"'+quoteLines[0].id+'": 1}]');
        
        opsl.createsort();
        
        opsl.back();
    }
}
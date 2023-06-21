@isTest
public class AfterContentDocumentLinkTriggerTest {
    
    @TEstSetup static void CreateData() 
 	{
        
        list<AcctSeed__Accounting_Variable__c> avList = new list<AcctSeed__Accounting_Variable__c>();
        
    	avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1'));
        insert avList;
        
        Id RecordTypeIdOpportunity = 
            Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();

        // Accounting Period
        Date dt = date.today();
        
        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        ap.name = dt.year() + '-' + ((dt.month() < 10)?'0' + dt.month():String.ValueOf(dt.month()));
        system.debug(dt.year() + '-' + ((dt.month() < 9)?Integer.ValueOf('0' + dt.month()):dt.month()));
        ap.AcctSeed__Start_Date__c = Date.today() - (dt.day() - 1);
        ap.AcctSeed__End_Date__c = Date.today() + 28;
        ap.AcctSeed__Status__c = 'Open';
        insert ap;
        
    	// create account
        Account acct = new Account();
        
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__Billing_Terms_Name__c = 'Example terms';
        
        insert acct;
		
        // create contact
        Contact cont = new Contact();
        
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        
        insert cont;
        
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        
        gl.name = 'GL Account First';
        gl.AcctSeed__type__c = 'Balance Sheet';
        gl.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl.AcctSeed__Active__c = true;
        
        insert gl;
        
        sales_rep__c salesrep = new sales_rep__c();
        
        salesrep.User__c = Userinfo.getUserId();
        salesrep.Active__c = 'Yes';
        salesrep.Name = 'New User';
        salesrep.Price_Level_1_12__c = 1;
        salesrep.Price_Level_13_20__c = 2;
        salesrep.Price_Level_21_26__c = 3;
        salesrep.Price_Level_27_30__c = 4;
        
        insert salesrep;
        
        // create product
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

        insert prod;

        // get the standard price book id
        Id pricebookId = Test.getStandardPricebookId();
        
        // create standard price book entry
        PricebookEntry pricebentry = new PricebookEntry();
        
        pricebentry.Pricebook2Id = pricebookId;
  		pricebentry.Product2Id = prod.Id;
        pricebentry.UnitPrice = 100;
        pricebentry.IsActive = true;
        
        insert pricebentry;
        
        // create opportunity
        
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Closed Won';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = avList[0].id;
        opp.RecordTypeId = RecordTypeIdOpportunity;
        opp.Pricebook2Id = pricebookId;
        //opp.IsApproved__c= false;
        opp.Sales_Rep_O__c = salesrep.id;
        
        insert opp;
        
        opportunitylineitem oli = new opportunitylineitem();
        
        oli.Quantity = 2;
        oli.UnitPrice = 2;
        oli.Product2Id = prod.id;
        oli.PricebookEntryId = pricebentry.id;
        oli.OpportunityId = opp.id;
        
        insert oli;

        // create quote
        Quote qt = new Quote();
        
        qt.OpportunityId = opp.Id;
        //qt.AccountId = acct.Id;
        qt.Name = 'myQuote';
        qt.Quote_Date__c = Date.today();
        qt.Pricebook2Id = pricebookId;
        
        insert qt;
        
        //----------------------- Quote Line Items

        quotelineitem qli = new quotelineitem();
        
        qli.QuoteId = qt.id;
        qli.Product2Id = prod.id;
        qli.Quantity = 1;
        qli.UnitPrice = 1;
        qli.PricebookEntryId = pricebentry.id;

        insert qli;
        
        // ----------------------- Content Document
        // documents
        
        string DocumentName = qt.Name + '_V1';
        
        Contentversion portfolio = new contentversion();
        portfolio.Title = DocumentName;
        portfolio.VersionData = Blob.valueOf('Test data.');
        portfolio.PathOnClient = 'Test data';
        
        insert portfolio;
                
        ContentDocument document = [SELECT Id, Title FROM ContentDocument where title=:DocumentName limit 1];

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=qt.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId=document.Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
    }
    
    @isTest static void runTests(){
        
        
    }

}
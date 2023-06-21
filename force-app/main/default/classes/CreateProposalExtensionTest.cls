@isTest
public class CreateProposalExtensionTest {
    @testSetup static void createData(){

        AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c(
            Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1');
        insert av;
        
        // create account
        Account acct = new Account();

        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = av.id;
        
        insert acct;
        
        // create contact
        Contact cont = new Contact();
        
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.GL_Account_Variable_1__c = av.id;
        
        insert cont;
        
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = av.id;
        
        insert aegl;
        
        // Gl account with bank unchecked
        AcctSeed__GL_Account__c ga = new AcctSeed__GL_Account__c();
        ga.Name = 'GL Account Test';
        ga.AcctSeed__Active__c = true;
        ga.AcctSeed__Type__c = 'Revenue';
        ga.AcctSeed__Sub_Type_1__c = 'Product Revenue';
        ga.AcctSeed__Sub_Type_2__c = 'Product Family 1';
        ga.AcctSeed__Bank__c = false;
        ga.GL_Account_Variable_1__c = av.id;
        
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
        //prod.Type__c = 'Product';
        
        insert prod;
        
        // create opportunity
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Closed Won';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = av.id;
        
        insert opp;
        
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
        
                // ----------------------- Content Document
        // documents
        
        Contentversion portfolio = new contentversion();
        portfolio.Title = 'new-proposal';
        portfolio.VersionData = Blob.valueOf('Test data.');
        portfolio.PathOnClient = 'Test data';
        
        insert portfolio;
        
        ContentDocument document = [SELECT Id, Title FROM ContentDocument where title='new-proposal' limit 1];
        
        prod.Technical_Specs_Id__c = document.Id;
        
        update prod;
        
        Quote qt = new Quote(name='myQuote', OpportunityId = opp.id, Pricebook2Id=pricebookId);

        insert qt;
        
        QuoteLineItem qli = new QuoteLineItem();
        
        qli.ITEM_DESCRIPTION__c = 'Test Description';
        qli.OpportunityLineItemId = oli.id;
        qli.Size__c = '2 X 3';
        qli.Quantity = 1;
        qli.UnitPrice = 100;
        qli.QuoteId = qt.id; 
        qli.PricebookEntryId = pricebentry.Id; 
        qli.Product2Id = prod.id;
        
        insert qli;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=qt.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId=document.Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        system.assertEquals(portfolio.ContentDocumentId, null);
        

        
    }
    @isTest static void CreateProposal() 
    {
        
        opportunity opp = [select id from opportunity where name='myOpportunity' limit 1];
        System.debug('opp is: ' + opp);
        
        Quote qt = [select id from Quote where OpportunityId =: opp.id limit 1];
        Test.startTest();
        
        ApexPages.StandardController std = new ApexPages.StandardController(qt);

        ApexPages.currentPage().getParameters().put('isContinue', 'false');
        ApexPages.currentPage().getParameters().put('specs', 'yes');
        ApexPages.currentPage().getParameters().put('org', 'Seawin USA');
        
        CreateProposalExtension cpe = new CreateProposalExtension(std);
        
        cpe.refresh();
        cpe.continueAnyway();
        CreateProposalExtension.wrapper wrp = new CreateProposalExtension.wrapper();
        
        wrp.qId = qt.id;
        wrp.str = EncodingUtil.base64Encode(Blob.valueOf('Test data.'));

        CreateProposalExtension.savePDF(wrp);
        
        ApexPages.currentPage().getParameters().put('reason', 'payment');
        cpe.QuotaExceeded();
        
        ContentDocument document = [SELECT Id, Title FROM ContentDocument 
                                    where title='new-proposal' limit 1];
        
        ApexPages.currentPage().getParameters().put('links', document.id);
        ApexPages.currentPage().getParameters().put('qid', qt.id);
        
        cpe.PDFError();
        
        
        Test.stopTest();

    }
    @isTest static void LineItemsMissing() 
    {
        
        opportunity opp = [select id from opportunity where name='myOpportunity' limit 1];
        
        Quote qt = new Quote();
        qt.OpportunityId = opp.Id;
        qt.Name = 'myQuote';
        qt.Quote_Date__c = Date.today();
        insert qt;

        
        Test.startTest();
        
        ApexPages.StandardController std = new ApexPages.StandardController(qt);

        ApexPages.currentPage().getParameters().put('isContinue', 'false');
        ApexPages.currentPage().getParameters().put('specs', 'yes');
        ApexPages.currentPage().getParameters().put('org', 'Seawin USA');
        
        CreateProposalExtension cpe = new CreateProposalExtension(std);
        
        cpe.refresh();
        
        CreateProposalExtension.wrapper wrp = new CreateProposalExtension.wrapper();
        
        wrp.qId = qt.id;
        wrp.str = EncodingUtil.base64Encode(Blob.valueOf('Test data.'));

        CreateProposalExtension.savePDF(wrp);
        
        Test.stopTest();

    }
    @isTest static void PortfolioPDFMissing() 
    {
        
        delete [SELECT Id, Title FROM ContentDocument where title='new-proposal' limit 1];
        
        opportunity opp = [select id from opportunity where name='myOpportunity' limit 1];
       
        quote qt = [select id,name from quote where opportunityId =:opp.id limit 1];
        
        Test.startTest();
        
        ApexPages.StandardController std = new ApexPages.StandardController(qt);

        ApexPages.currentPage().getParameters().put('isContinue', 'false');
        ApexPages.currentPage().getParameters().put('specs', 'yes');
        ApexPages.currentPage().getParameters().put('org', 'Seawin USA');
        
        CreateProposalExtension cpe = new CreateProposalExtension(std);
        
        cpe.refresh();
        
        CreateProposalExtension.wrapper wrp = new CreateProposalExtension.wrapper();
        
        wrp.qId = qt.id;
        wrp.str = EncodingUtil.base64Encode(Blob.valueOf('Test data.'));

        CreateProposalExtension.savePDF(wrp);
        
        Test.stopTest();

    }
}
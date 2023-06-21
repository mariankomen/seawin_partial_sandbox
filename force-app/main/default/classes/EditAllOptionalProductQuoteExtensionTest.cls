@isTest
public class EditAllOptionalProductQuoteExtensionTest {

    @testSetup static void createData(){
     
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        // create account
        Account acct = new Account();
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
        
        // create opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'myOpportunity';
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Follow up';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = accVar.Id;
        opp.Run_Validation_Rule__c = true;
        insert opp;
        
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
        prod.Type__c = 'Kit';
        insert prod;
        
        // create pricebook2
        Pricebook2 priceb2 = new Pricebook2();
        priceb2.Name = 'myPriceBook';
        priceb2.Description = 'myPBDescription';
        priceb2.IsActive = true;
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
        
        // create quote
        Quote qt = new Quote();
        qt.OpportunityId = opp.Id;
        qt.Name = 'myQuote';
        qt.Quote_Date__c = Date.today();
        qt.Pricebook2Id = pricebookId;
        insert qt;
        
        //----------------------- Quote Line Items
        Optional_Products_Quote__c quoteOptLineItm = new Optional_Products_Quote__c();
        quoteOptLineItm.Quote__c = qt.id;
        quoteOptLineItm.Product__c = prod.id;
        quoteOptLineItm.Quantity__c = 1;
        quoteOptLineItm.UnitPrice__c = 1;
        quoteOptLineItm.PriceBookEntryId__c = pricebentry.id;
        insert quoteOptLineItm;
        
        
        
    }
    
    @isTest static void StartProcess(){
    
        Quote quote = [select id,Name from Quote where name='myQuote' limit 1];
        Optional_Products_Quote__c opt = [select id from Optional_Products_Quote__c
                                          where Quote__c =: quote.Id];
        
        test.startTest();
        PageReference pageRef = Page.EditAllOptionalProductOppPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', quote.id);
        
        ApexPages.StandardController std = new ApexPages.StandardController(opt);
        
        EditAllOptionalProductQuoteExtension op = new EditAllOptionalProductQuoteExtension(std);
        
        op.saveOptionalProd();
        op.gotoParent();
        
        
    }
    
}
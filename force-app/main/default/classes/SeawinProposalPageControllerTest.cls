@isTest
public class SeawinProposalPageControllerTest {
    
    @TestSetup static void CreateData(){
        // create GL Account Variable 1 needed by account
        AcctSeed__Accounting_Variable__c glav = new AcctSeed__Accounting_Variable__c(
            Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1');
        
        insert glav;
        
        // Create accounts
        
        Account acct = new Account(name='myAccount', AcctSeed__GL_Account_Variable_1__c=glav.id);
        
        insert acct;
        
        // Create Contact
        Contact contct = new Contact(LastName='myContact1', LeadSource = 'AAOHA 2020');
        insert contct;
        
        // Create GL Account
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = glav.id;
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
        prod.Category__c = 'Shower Door';
        insert prod;
        
        // insert to standard price book
        Id pricebookId = Test.getStandardPricebookId();
        
        // create standard price book entry
        PricebookEntry pricebentry = new PricebookEntry();
        pricebentry.Pricebook2Id = pricebookId;
  		pricebentry.Product2Id = prod.Id;
        pricebentry.UnitPrice = 100;
        pricebentry.IsActive = true;
        insert pricebentry;
        
        
        // create sales rep
        sales_rep__c rep = new sales_rep__c(name__c='example rep', email__C='erep@email.com', 
                                            mobile__c = '1234567890', phone__c = '9876543210',
                                           website__c = 'www.example.com');
        insert rep;

        // Create opportunities
        
        Opportunity op = new Opportunity(name='myOpportunity', price_level__c = null, stagename='Closed Won',
                                         contactperson__c = contct.id,
                                         CloseDate=date.today() + 60, accountid=acct.id, sales_rep_o__c=rep.id,
                                        GL_Account_Variable_1__c = glav.id);
        
        insert op;
        
        // create opportunity line item
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = op.Id;
        oli.Product2Id = prod.Id;
        oli.PricebookEntryId = pricebentry.Id;
        oli.Quantity = 10;
        oli.UnitPrice = 100;
        oli.Description = 'myDescription';
        insert oli;
        
        Quote qt = new Quote(name='myQuote', OpportunityId = op.id, PriceBook2Id=pricebookId);
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
        
    }
    @isTest static void ShowerDoor(){
        
        Quote qt = [select id from Quote limit 1];
        
        Test.startTest();
        	ApexPages.currentPage().getParameters().put('quoteid', qt.id);
        	SeawinProposalPageController ext = new SeawinProposalPageController();
        Test.stopTest();
    }
    @isTest static void Vanities(){
        
        Product2 prod = [select id, category__c from product2 where name='myProduct' limit 1];
        
        prod.Category__c = 'Vanities';
        
        update prod;
        
        Quote qt = [select id from Quote limit 1];
        
        Test.startTest();
        	ApexPages.currentPage().getParameters().put('quoteid', qt.id);
        	SeawinProposalPageController ext = new SeawinProposalPageController();
        Test.stopTest();
    }
    @isTest static void WallSurrounds(){
        
        Product2 prod = [select id, category__c from product2 where name='myProduct' limit 1];
        
        prod.Category__c = 'Wall Surrounds';
        
        update prod;
        
        Quote qt = [select id from Quote limit 1];
        
        Test.startTest();
        	ApexPages.currentPage().getParameters().put('quoteid', qt.id);
        	SeawinProposalPageController ext = new SeawinProposalPageController();
        Test.stopTest();
    }
}
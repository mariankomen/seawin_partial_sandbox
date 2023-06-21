@isTest
public class SyncOptionalProductsToQuoteHandlerTest {
    
    @testSetup static void createData(){
        
        // create GL Account Variable 1 needed by account
        AcctSeed__Accounting_Variable__c glav = new AcctSeed__Accounting_Variable__c(
            Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1');
        
        insert glav;
        
        // Create accounts
        
        Account acct = new Account(name='myAccount', AcctSeed__GL_Account_Variable_1__c=glav.id);
        insert acct;
        
        // create GL Account
        AcctSeed__GL_Account__c gla = new AcctSeed__GL_Account__c();
        gla.name = '2010-Vouchers Payable';
        gla.AcctSeed__Type__c = 'Balance Sheet';
        gla.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gla.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gla.AcctSeed__Active__c = true;
        gla.AcctSeed__Bank__c = true;
        gla.GL_Account_Variable_1__c = glav.Id;
        
        insert gla;
        
        // Create Product
        Product2 prod = new Product2();
        
        prod.Name = 'myProduct';
        prod.ProductCode = 'ABC123';
        prod.Description = 'myDescription';
        prod.AcctSeed__Unit_Cost__c = 100;
        prod.IsActive = true;
        prod.Category__c = 'Shower Door';
        prod.Sub_Category__c = 'Single Sliding';
        prod.AcctSeed__Inventory_Type__c = 'Purchased';
        prod.AcctSeed__Expense_GL_Account__c = gla.id;
        prod.AcctSeed__Inventory_GL_Account__c = gla.id;
        prod.AcctSeed__Revenue_GL_Account__c = gla.id;
        prod.AcctSeed__Inventory_Product__c = true;
        prod.Type__c = 'Product';

        insert prod;
        
        // create pricebook2
        Pricebook2 priceb2 = new Pricebook2();
        
        priceb2.Name = 'myPriceBook';
        priceb2.Description = 'myPBDescription';
        priceb2.IsActive = true;
        //priceb2.IsStandard = true;
        
        insert priceb2;
        
        // get the standard price book id
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
        
        Opportunity opp = new Opportunity(name='myOpportunity', price_level__c = null, stagename='Closed Won', 
                                          CloseDate=date.today() + 60, accountid=acct.id,
                                          Gl_Account_Variable_1__c = glav.id);
        insert opp;
        
        
        // create an optional product on Opportunity
        Optional_Products_Opportunity__c opo = new Optional_Products_Opportunity__c();
        
        opo.Opportunity__c = opp.Id;
        opo.Description__c = 'myDescription';
        opo.Item_Description__c = 'myItemDescription';
        opo.Product__c = prod.Id;
        opo.Quantity__c = 2;
        opo.UnitPrice__c = 10;
        
        insert opo;
        
        // create quote
        Quote qt = new Quote();
        
        qt.OpportunityId = opp.Id;
        //qt.AccountId = acct.Id;
        qt.Name = 'myQuote';
        qt.Quote_Date__c = Date.today();
        
        insert qt;
        
        // create an optional product on Opportunity
        Optional_Products_Quote__c opq = new Optional_Products_Quote__c();
        
        opq.Quote__c = qt.Id;
        opq.Description__c = 'myDescription';
        opq.Item_Description__c = 'myItemDescription';
        opq.Product__c = prod.Id;
        opq.Quantity__c = 2;
        opq.UnitPrice__c = 10;
        
        insert opq;
        
        opp.SyncedQuoteId = qt.Id;
        update opp;
        
    }
    
    @isTest static void runTests(){
        
        
    }
}
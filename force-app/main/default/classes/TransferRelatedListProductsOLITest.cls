@isTest 
public class TransferRelatedListProductsOLITest 
{
    static testMethod void testMethod1() 
    {
    
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
     
        // create account
        Account acct = new Account();
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct;
		
        // create contact
        Contact cont = new Contact();
        cont.LastName = 'myLastName';
     	cont.AccountId = acct.Id;
     	cont.GL_Account_Variable_1__c = accVar.Id;
        insert cont;
        
        // create product
        Product2 prod = new Product2();
        prod.Name = 'myProduct';
        prod.ProductCode = 'ABC123';
        prod.AcctSeed__Unit_Cost__c = 100;
        prod.IsActive = true;
        
        insert prod;
        
        // create opportunity
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Follow up';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = accVar.Id;
        insert opp;
        
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
        
        // create quote
        Quote qt = new Quote();
        
        qt.OpportunityId = opp.Id;
        //qt.AccountId = acct.Id;
        qt.Name = 'myQuote';
        qt.Quote_Date__c = Date.today();
        
        insert qt;
        
        opp.SyncedQuoteId = qt.Id;
		update opp;
        
        // create an optional product on Opportunity
        OpportunityLineItem oli = new OpportunityLineItem();
        
        oli.OpportunityId = opp.Id;
        oli.Description = 'myDescription';
        oli.Item_Description__c = 'myItemDescription';
        oli.Product2Id = prod.Id;
        oli.Quantity = 2;
        oli.UnitPrice = 10;
        oli.PricebookEntryId = pricebentry2.Id;
        
        insert oli;
 
 		Test.startTest();
  		Test.setCurrentPage(Page.TransferRelatedListProductsVFPage);
        
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        ApexPages.currentPage().getParameters().put('id0', oli.Id);
        ApexPages.currentPage().getParameters().put('count', '1');
     
     	TransferRelatedListProductsOLI trlp = new TransferRelatedListProductsOLI();
     
        trlp.dmlOperation();
     
 		Test.stopTest();
 }
}
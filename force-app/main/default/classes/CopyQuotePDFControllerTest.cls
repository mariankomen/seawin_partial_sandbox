@isTest 
public class CopyQuotePDFControllerTest 
{
    static testMethod void testMethod1() 
 	{
		
        	// create account
        Account acct = new Account();
        
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        
        insert acct;
		
        // create contact
        Contact cont = new Contact();
        
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        
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
        
        // create opportunity line item
        
        OpportunityLineItem oli = new OpportunityLineItem();
        
        oli.OpportunityId = opp.Id;
        oli.Product2Id = prod.Id;
        oli.PricebookEntryId = pricebentry2.Id;
        oli.Quantity = 10;
        oli.UnitPrice = 100;
        oli.Description = 'myDescription';
        
        insert oli;
        
        // create quote
        Quote qt = new Quote();
        
        qt.OpportunityId = opp.Id;
        //qt.AccountId = acct.Id;
        qt.Name = 'myQuote';
        qt.Quote_Date__c = Date.today();
        
        insert qt;
        
        // create QuoteDocument
        string before = 'Testing base 64 encode';
        Blob beforeblob = Blob.valueOf(before);
        
        QuoteDocument qdoc = New QuoteDocument();
        qdoc.QuoteId = qt.Id;
		qdoc.Document = Blob.toPdf('Test Document');
        
        insert qdoc;
        
        Test.setCurrentPageReference(new PageReference('Page.CopyQuotePDFControllerVF'));
		System.currentPageReference().getParameters().put('id', qt.Id);
        
        CopyQuotePDFController.pageAction();
        
        

        
    }
}
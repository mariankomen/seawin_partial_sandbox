@isTest
public class QuoteDeleteExtensionTest {

    @testSetup static void createData(){
        
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        // create account
        Account acct = new Account();
        //acct.Sales_Rep_O__c = sr.id;
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
        
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
        Id pricebookId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity();
        opp.Name = 'myOpportunity';
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Closed Won';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = accVar.id;
        opp.RecordTypeId = RecordTypeIdOpportunity;
        opp.Pricebook2Id = pricebookId;
        insert opp;
        
        // create quote
        Quote qt = new Quote();
        qt.OpportunityId = opp.Id;
        qt.Name = 'myQuote';
        qt.Quote_Date__c = Date.today();
        qt.Pricebook2Id = pricebookId;
        insert qt;
        
        
        
    }
    
     @isTest static void StartProcess(){
      
         Opportunity opp = [select id from Opportunity
                           where name =: 'myOpportunity' limit 1];
         
         Quote quote = [select id from Quote
                      where OpportunityId =: opp.Id limit 1];
         
         test.startTest();
		        
         PageReference pageRef = Page.QuoteDeletePage;
         Test.setCurrentPage(pageRef);
		
         ApexPages.currentPage().getParameters().put('id', quote.id);
         ApexPages.currentPage().getParameters().put('retURL', opp.id);
        
         ApexPages.StandardController std = new ApexPages.StandardController(quote);
        
         QuoteDeleteExtension obj = new QuoteDeleteExtension(std);

         obj.TryDelete();
         obj.back();
         
     }
}
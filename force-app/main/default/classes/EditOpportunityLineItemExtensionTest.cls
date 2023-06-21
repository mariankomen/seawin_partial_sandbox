@isTest 
public class EditOpportunityLineItemExtensionTest {
 
    @testSetup static void CreateData(){
        
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        Account acct = new Account();
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct;
        
        Contact cont = new Contact();
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.GL_Account_Variable_1__c = accVar.Id;
        insert cont;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        list<AcctSeed__Accounting_Variable__c> avList = new list<AcctSeed__Accounting_Variable__c>();
    	avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin China',AcctSeed__Type__c = 'GL Account Variable 1'));
        avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1'));
        insert avList;
        
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
        
        sales_rep__c salesrep = new sales_rep__c();
        salesrep.User__c = Userinfo.getUserId();
        salesrep.Active__c = 'Yes';
        salesrep.Name = 'New User';
        salesrep.Price_Level_1_12__c = 1;
        salesrep.Price_Level_13_20__c = 2;
        salesrep.Price_Level_21_26__c = 3;
        salesrep.Price_Level_27_30__c = 4;
        insert salesrep;

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
        opp.Sales_Rep_O__c = salesrep.id;
        insert opp;
        
        Quote qt = new Quote();
        qt.OpportunityId = opp.Id;
        qt.Name = 'myQuote';
        qt.Quote_Date__c = Date.today();
        qt.Pricebook2Id = pricebookId;
        insert qt;
        
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        
        gl.name = 'GL Account First';
        gl.AcctSeed__type__c = 'Balance Sheet';
        gl.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl.AcctSeed__Active__c = true;
        insert gl;
        
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
        prod.Type__c = 'Kit';
        insert prod;
        
        PricebookEntry pricebentry = new PricebookEntry();
        pricebentry.Pricebook2Id = pricebookId;
  		pricebentry.Product2Id = prod.Id;
        pricebentry.UnitPrice = 100;
        pricebentry.IsActive = true;
        insert pricebentry;
        
        quotelineitem qlis = new quotelineitem();
        qlis.QuoteId = qt.id;
        qlis.Product2Id = prod.id;
        qlis.Quantity = 1;
        qlis.UnitPrice = 1;
        qlis.PricebookEntryId = pricebentry.id;
        insert qlis;
        
        opportunitylineitem l1 = new opportunitylineitem();
        l1.Quantity = 2;
        l1.UnitPrice = 2;
        l1.Product2Id = prod.id;
        l1.PricebookEntryId = pricebentry.id;
        l1.OpportunityId = opp.id;
        insert l1;
    }
    
    @isTest static void firstRun(){
        
        Opportunity opp = [select id,Name from Opportunity where name = 'myOpportunity' limit 1];
        OpportunityLineItem oli = [select id, Name from OpportunityLineItem where OpportunityId =: opp.id limit 1];
        
        test.startTest();
        
        PageReference pageRef = Page.EditOpportunityLineItemPage;
        Test.setCurrentPage(pageRef);
		
        ApexPages.currentPage().getParameters().put('Id', oli.id);
        
        ApexPages.StandardController std = new ApexPages.StandardController(oli);
        
        EditOpportunityLineItemExtension EditOLI = new EditOpportunityLineItemExtension(std);
        EditOLI.Edit();
        EditOLI.CancelButton();
    }
}
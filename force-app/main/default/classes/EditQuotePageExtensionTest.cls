@isTest
public class EditQuotePageExtensionTest {
    
        @testSetup static void CreateData(){
        
        list<AcctSeed__Accounting_Variable__c> avList = new list<AcctSeed__Accounting_Variable__c>();
        
    	avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin China',AcctSeed__Type__c = 'GL Account Variable 1'));
        
        avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1'));
        insert avList;
            
        Id USAHospitality = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
		Id ChinaHospitality = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin China Hospitality').getRecordTypeId();
        
        // create account
        Account acct = new Account();
        //acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = avList[1].id;
        insert acct;
		
        // create contact
        Contact cont = new Contact();
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.GL_Account_Variable_1__c = avList[1].id;
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
		prod.Type__c = 'Kit';
        insert prod;
        
         // create opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'Opportunity1';
        //opp.Sales_Rep_O__c = sr.id;
        opp.GL_Account_Variable_1__c = avList[1].id; 
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Follow up';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.Approval_Status__c = 'Approved';
        opp.RecordTypeId = USAHospitality;
        insert opp;
            
             // create opportunity
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Opportunity2';
        //opp.Sales_Rep_O__c = sr.id;
        opp1.GL_Account_Variable_1__c = avList[1].id; 
        opp1.AccountId = acct.Id;
        opp1.Type = 'Actual Order';
        opp1.StageName = 'Negotiation';
        opp1.CloseDate = system.today();
        opp1.ContactPerson__c = cont.Id;
        opp1.Approval_Status__c = 'Not Approved';
        opp1.RecordTypeId = ChinaHospitality;
        insert opp1;


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
            
        Quote q = new Quote();
        q.OpportunityId = opp.id;
        q.Name = 'Test Quote 1';
        q.Quote_Date__c = date.today();
        q.ExpirationDate = date.today() + 14;
        insert q;
            
        Quote q1 = new Quote();
        q1.OpportunityId = opp1.id;
        q1.Name = 'Test Quote 2';
        q1.Quote_Date__c = date.today();
        q1.ExpirationDate = date.today() + 14;
        insert q1;

    }
    
    @isTest static void NotApproved(){
        
        Quote q = [select id, OpportunityId from quote where name='Test Quote 2' Limit 1];
        
        ApexPages.currentPage().getParameters().put('retURL', q.id);        
        ApexPages.standardController std = new ApexPages.StandardController(q);
        
        EditQuotePageExtension e = new EditQuotePageExtension(std);
        
        e.pageAction();
        e.back();

    }
    @isTest static void Approved(){
        
        Quote q = [select id, OpportunityId from quote where name='Test Quote 1' Limit 1];
        
        ApexPages.standardController std = new ApexPages.StandardController(q);
        EditQuotePageExtension e = new EditQuotePageExtension(std);
        e.pageAction();
        
    }
}
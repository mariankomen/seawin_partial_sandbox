/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-10-2023
 * @last modified by  : Marian Lyzhychka
**/
@isTest
public with sharing class DifferentUpdatesBatchTest {
    @testSetup static void CreateData() 
 	{
         integer recordSize = 2;
    	AcctSeed__Accounting_Variable__c av = 
            new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA', 
            AcctSeed__Type__c = 'GL Account Variable 1');
        insert av;
        
        Date dt = Date.today();

        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        
        Integer year = dt.year();
        String month = dt.month() > 9 ? '' + dt.month() : '0' + dt.month();

        ap.Name = year + '-' + month;
        ap.AcctSeed__Start_Date__c = Date.NewInstance(year, dt.month(), 1);
        ap.AcctSeed__End_Date__c = Date.NewInstance(year, dt.month(), Date.DaysInMonth(year, dt.month()));
        ap.AcctSeed__Status__c = 'Open';
            
        insert ap;
        
        
        AcctSeed__Accounting_Period__c apGet = [select name, AcctSeed__Start_Date__c, AcctSeed__End_Date__c
                                               ,AcctSeed__Status__c from AcctSeed__Accounting_Period__c where name
                                               =:dt.year() + '-' + ((dt.month() <= 9)?'0' + 
                                                                    dt.month():String.ValueOf(dt.month())) limit 1];
        
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
        
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        
        gl.name = 'GL Account First';
        gl.AcctSeed__type__c = 'Expense';
        gl.AcctSeed__Sub_Type_1__c = 'Facilities';
        gl.AcctSeed__Sub_Type_1__c = 'Rent';
        
        insert gl;
        
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

        Product2 prod2 = new Product2();
        
        prod2.Name = 'myProduct2';
        prod2.ProductCode = 'ABC123';
        prod2.Description = 'myDescription2';
        prod2.AcctSeed__Unit_Cost__c = 100;
        prod2.IsActive = true;
        prod2.Category__c = 'Shower Door';
        prod2.Sub_Category__c = 'Single Sliding';
        prod2.AcctSeed__Inventory_Type__c = 'Purchased';
        prod2.AcctSeed__Expense_GL_Account__c = gl.id;
        prod2.AcctSeed__Inventory_GL_Account__c = gl.id;
        prod2.AcctSeed__Revenue_GL_Account__c = gl.id;
        prod2.AcctSeed__Inventory_Product__c = true;

        insert prod2;
        
        // create opportunity
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Follow up';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = av.id;
        
        insert opp;
		
        Id pricebookId = Test.getStandardPricebookId();
        
        // create standard price book entry
        PricebookEntry pricebentry = new PricebookEntry();
        
        pricebentry.Pricebook2Id = pricebookId;
        pricebentry.Product2Id = prod.Id;
        pricebentry.UnitPrice = 100;
        pricebentry.IsActive = true;
        
        insert pricebentry;

        PricebookEntry pricebentry2 = new PricebookEntry();
        
        pricebentry2.Pricebook2Id = pricebookId;
        pricebentry2.Product2Id = prod2.Id;
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
		
        OpportunityLineItem oli = new OpportunityLineItem();
        
        oli.OpportunityId = opp.Id;
        oli.Product2Id = prod.Id;
        oli.PricebookEntryId = pricebentry2.Id;
        oli.Quantity = 10;
        oli.UnitPrice = 100;
        oli.Description = 'myDescription';
        
        insert oli;


    }

    @isTest
    public static void executeTest(){
        Test.startTest();
        DifferentUpdatesBatch k = new DifferentUpdatesBatch();
        Database.executeBatch(k,1);
        Test.stopTest();
    }
}
/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 08-04-2023
 * @last modified by  : Marian Lyzhychka
**/
@isTest
public with sharing class SObjectSortControllerTest {
    
    @TestSetup
    static void makeData(){
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'Seawin USA';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        list<AcctSeed__GL_Account__c> glList = new List<AcctSeed__GL_Account__c>();
        
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        
        gl.name = 'GL Account First';
        gl.AcctSeed__type__c = 'Balance Sheet';
        gl.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl.AcctSeed__Active__c = true;
        gl.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(gl);
        
        // ledger creation
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(aegl);
        
        AcctSeed__GL_Account__c vch = new AcctSeed__GL_Account__c();
        vch.name = '2010-Vouchers Payable';
        vch.AcctSeed__Type__c = 'Balance Sheet';
        vch.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch.AcctSeed__Active__c = true;
        vch.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(vch);
        
        AcctSeed__GL_Account__c vch1 = new AcctSeed__GL_Account__c();
        vch1.name = '2010-Vouchers Payable1';
        vch1.AcctSeed__Type__c = 'Balance Sheet';
        vch1.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch1.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch1.AcctSeed__Active__c = true;
        vch1.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(vch1);
        
        AcctSeed__GL_Account__c vch2 = new AcctSeed__GL_Account__c();
        vch2.name = '2010-Vouchers Payable2';
        vch2.AcctSeed__Type__c = 'Balance Sheet';
        vch2.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch2.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch2.AcctSeed__Active__c = true;
        vch2.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(vch2);
        
        AcctSeed__GL_Account__c vch3 = new AcctSeed__GL_Account__c();
        vch3.name = '2010-Vouchers Payable3';
        vch3.AcctSeed__Type__c = 'Balance Sheet';
        vch3.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch3.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch3.AcctSeed__Active__c = true;
        vch3.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(vch3);
        
        AcctSeed__GL_Account__c gl1 = new AcctSeed__GL_Account__c();
        gl1.name = '2010-Vouchers Payable1';
        gl1.AcctSeed__Type__c = 'Balance Sheet';
        gl1.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl1.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl1.AcctSeed__Active__c = true;
        gl1.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(gl1);
        
        AcctSeed__GL_Account__c gl2 = new AcctSeed__GL_Account__c();
        gl2.name = '2010-Vouchers Payable2';
        gl2.AcctSeed__Type__c = 'Balance Sheet';
        gl2.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl2.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl2.AcctSeed__Active__c = true;
        gl2.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(gl2);
        
        AcctSeed__GL_Account__c gl3 = new AcctSeed__GL_Account__c();
        gl3.name = '2010-Vouchers Payable3';
        gl3.AcctSeed__Type__c = 'Balance Sheet';
        gl3.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl3.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl3.AcctSeed__Active__c = true;
        gl3.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(gl3);
        
        AcctSeed__GL_Account__c gl4 = new AcctSeed__GL_Account__c();
        gl4.name = '2010-Vouchers Payable4';
        gl4.AcctSeed__Type__c = 'Balance Sheet';
        gl4.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl4.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl4.AcctSeed__Active__c = true;
        gl4.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(gl4);
        
        insert glList;
        
        // Accounting Period
        Date dt = date.today();
        
        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        ap.name =
            dt.year() +
            '-' +
            ((dt.month() < 10) ? '0' + dt.month() : String.ValueOf(dt.month()));
        system.debug(
            dt.year() +
            '-' +
            ((dt.month() < 9) ? Integer.ValueOf('0' + dt.month()) : dt.month())
        );
        ap.AcctSeed__Start_Date__c = Date.today() - (dt.day() - 1);
        ap.AcctSeed__End_Date__c = Date.today() + 28;
        ap.AcctSeed__Status__c = 'Open';
        insert ap;
        
        // create account
        Account acct = new Account();
        //acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct;

        Test.startTest();
        Sales_Rep__c sr = new Sales_Rep__c();
        
        sr.name = 'Test Team';
        sr.Email__c = 'team@test.com';
        sr.Team__c = UserInfo.getUserId();
        sr.Price_Level_1_12__c = 1;
        sr.Price_Level_13_20__c = 1;
        sr.Price_Level_21_26__c = 1;
        sr.Price_Level_27_30__c = 1;
        sr.Man_Rep_Price_Level_1_12__c = 1;
        sr.Man_Rep_Price_Level_13_20__c = 1;
        sr.Man_Rep_Price_Level_21_26__c = 1;
        sr.Man_Rep_Price_Level_27_30__c = 1;
        sr.GL_Account_Variable_to_Sales_Rep__c = accVar.Id;
        
        insert sr;
        
        // create account
        Account acct2 = new Account();
        acct2.Name = 'Manufacturer Representative';
        acct2.Sales_Rep_O__c = sr.id;
        acct2.Type = 'Designer';
        acct2.AcctSeed__Accounting_Type__c = 'Manufacturer Representative';
        acct2.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        acct2.Price_Level_1_12__c = 1;
        acct2.Price_Level_13_20__c = 1;
        acct2.Price_Level_21_26__c = 1;
        acct2.Price_Level_27_30__c = 1;
        
        insert acct2;
        
        // create contact
        Contact cont = new Contact();
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.LeadSource = 'AAOHA 2020';
        cont.GL_Account_Variable_1__c = accVar.Id;
        insert cont;
        
        AcctSeed__GL_Account__c glAccount2 = new AcctSeed__GL_Account__c();
        glAccount2.name = 'glaccount';
        glAccount2.AcctSeed__Type__c = 'Expense';
        glAccount2.AcctSeed__Sub_Type_1__c = 'Facilities';
        glAccount2.AcctSeed__Sub_Type_2__c = 'Rent';
        glAccount2.AcctSeed__Bank__c = false;
        glAccount2.GL_Account_Variable_1__c = accVar.Id;
        insert glAccount2;
        
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
        prod.Commissionable_Product__c = true;
        
        insert prod;
        
        // create opportunity
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.Sales_Rep_O__c = sr.id;
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Follow up';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = accVar.Id;
        opp.Run_Validation_Rule__c = true;
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
    }

    @isTest
    private static void getLinesForSortingTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String payload = '{"sobjectName":"OpportunityLineItem","parentSObjectName":"Opportunity","parentSObjectFieldApi":"OpportunityId","parentRecordId":"006EY000002J7c7YAC","datatableFields":"Quantity","sortOrderFieldApi":"SortOrder"}';
        SObjectSortController.PayloadWrapper payl = (SObjectSortController.PayloadWrapper)JSON.deserialize(payload, SObjectSortController.PayloadWrapper.class);
        payl.parentRecordId = opp.Id;

        SObjectSortController.getLinesForSorting(JSON.serialize(payl));
    }

    @isTest
    private static void handleSaveSortingTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        OpportunityLineItem itm = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId=:opp.Id LIMIT 1];
        String payload = '{"sobjectName":"OpportunityLineItem","parentSObjectName":"Opportunity","parentSObjectFieldApi":"OpportunityId","parentRecordId":"006EY000002J7c7YAC","datatableFields":"Quantity","sortOrderFieldApi":"SortOrder"}';
        SObjectSortController.PayloadWrapper payl = (SObjectSortController.PayloadWrapper)JSON.deserialize(payload, SObjectSortController.PayloadWrapper.class);
        payl.parentRecordId = opp.Id;

        SObjectSortController.LinesSortWrapper lineWrap = new SObjectSortController.LinesSortWrapper(itm.Id, 1);

        SObjectSortController.handleSaveSorting(JSON.serialize(new List<SObjectSortController.LinesSortWrapper>{lineWrap}), JSON.serialize(payl));
    }
}
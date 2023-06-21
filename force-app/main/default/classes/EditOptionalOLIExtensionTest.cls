@isTest
public class EditOptionalOLIExtensionTest {

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
        opp.Name = 'myOpportunity';
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Follow up';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = accVar.Id;
        opp.Run_Validation_Rule__c = true;
        insert opp;
        
        LIST<Optional_Products_Opportunity__c> optionalProd = new LIST<Optional_Products_Opportunity__c>();
        
        Optional_Products_Opportunity__c optionalProd1 = new Optional_Products_Opportunity__c();
        optionalProd1.Opportunity__c = opp.Id;
        optionalProd1.Description__c = 'desc';
        optionalProd1.Product__c = prod.Id;
        optionalProd1.Quantity__c = 2;
        optionalProd1.UnitPrice__c = 2;
        
        Optional_Products_Opportunity__c optionalProd2 = new Optional_Products_Opportunity__c();
        optionalProd2.Opportunity__c = opp.Id;
        optionalProd2.Description__c = 'desc';
        optionalProd2.Product__c = prod.Id;
        optionalProd2.Quantity__c = 2;
        optionalProd2.UnitPrice__c = 2;
        optionalProd.Add(optionalProd1);
        optionalProd.Add(optionalProd2);
        insert optionalProd;
        
    }
    
    @isTest static void StartProcess(){
        
        Opportunity opp = [select id, Name from opportunity where name='myOpportunity' limit 1];
        LIST<Optional_Products_Opportunity__c> optionalProd = [select id, Opportunity__c from Optional_Products_Opportunity__c 
                                                               where Opportunity__c =: opp.Id];
        test.startTest();
		        
        PageReference pageRef = Page.EditOptionalOlIPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', optionalProd[0].Id);
        ApexPages.currentPage().getParameters().put('retURL', opp.id);
        
        ApexPages.StandardController std = new ApexPages.StandardController(optionalProd[0]);
        
        EditOptionalOLIExtension obj = new EditOptionalOLIExtension(std);
        obj.EditProcess();
        obj.back();
         
     }
}
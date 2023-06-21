@isTest
public class ProductPartHandlerTest {
	@TestSetup static void CreateDate(){
     
        AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c();
        
        av.Name = 'GL Account Variable Test';
        av.AcctSeed__Active__c = true;
        av.AcctSeed__Type__c = 'GL Account Variable 1';
        
        insert av;
        
         // create account
        Account acct = new Account();
        
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = av.Id;
        insert acct;
        
        // create contact
        Contact cont = new Contact();
        
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.GL_Account_Variable_1__c = av.Id;
        insert cont;
        
        // create GL Account
        AcctSeed__GL_Account__c gla = new AcctSeed__GL_Account__c();
        gla.name = '2010-Vouchers Payable';
        gla.AcctSeed__Type__c = 'Balance Sheet';
        gla.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gla.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gla.AcctSeed__Active__c = true;
        gla.AcctSeed__Bank__c = true;
        gla.GL_Account_Variable_1__c = av.Id;
        
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
        
        AcctSeed__Product_Part__c pp = new AcctSeed__Product_Part__c();
        
        pp.AcctSeed__Quantity__c = 1;
        pp.Kit_Product__c = prod.id;
        pp.kit_children__c = prod.id;
        
        insert pp;
        
    }
    
    @isTest static void runTests(){
        
        
    }
}
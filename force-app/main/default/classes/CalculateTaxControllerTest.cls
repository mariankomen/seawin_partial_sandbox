@isTest
public class CalculateTaxControllerTest {
    
    @testsetup static void createData(){
        
        TestUtility.CreateData();
    }
    @isTest static void WithoutTaxRecords(){

        opportunity opp = [select Id, Name, AccountId, Account.Name, 
               Gl_Account_Variable_1__c from Opportunity where name = 'myOpportunity' limit 1];
        
        ApexPages.currentPage().getParameters().put('id', opp.id);
        
        CalculateTaxController ctc = new CalculateTaxController();

    }
    @isTest static void PartialTaxRecords(){
        
        AcctSeed__GL_Account__c gl = [select id from AcctSeed__GL_Account__c where name = 'GL Account First' limit 1];

        Product2 taxRate = new Product2();
        
        taxRate.name = 'TaxProduct';
        taxRate.AcctSeed__Accounting_type__c = 'Tax Rate';
        taxRate.AcctSeed__Tax_Rate__c = 1;
        taxRate.AcctSeed__Expense_GL_Account__c = gl.id;
        taxRate.AcctSeed__Revenue_GL_Account__c = gl.id;
        insert taxRate;
        
        Product2 taxRate2 = new Product2();
        
        taxRate2.name = 'TaxProduct2';
        taxRate2.AcctSeed__Accounting_type__c = 'Tax Rate';
        taxRate2.AcctSeed__Tax_Rate__c = 1;
        taxRate2.AcctSeed__Expense_GL_Account__c = gl.id;
        taxRate2.AcctSeed__Revenue_GL_Account__c = gl.id;
        insert taxRate2;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // create standard price book entry
        PricebookEntry pbe = new PricebookEntry();
        
        pbe.Pricebook2Id = pricebookId;
  		pbe.Product2Id = taxRate.Id;
        pbe.UnitPrice = 100;
        pbe.IsActive = true;
        
        insert pbe;
        
        Account acct = [select id from Account where name='myAccount' limit 1];
        
        AcctSeed__Account_Tax__c taxes = new AcctSeed__Account_Tax__c();
        taxes.AcctSeed__Account__c = acct.id;
        taxes.AcctSeed__Tax_Rate__c = taxRate.id;
        taxes.AcctSeed__Tax_Type__c = 'Sales';

        insert taxes;
        
        AcctSeed__Account_Tax__c taxes2 = new AcctSeed__Account_Tax__c();
        taxes2.AcctSeed__Account__c = acct.id;
        taxes2.AcctSeed__Tax_Rate__c = taxRate2.id;
        taxes2.AcctSeed__Tax_Type__c = 'Sales';

        insert taxes2;

        opportunity opp = [select Id, Name, AccountId, Account.Name, 
               Gl_Account_Variable_1__c from Opportunity where name = 'myOpportunity' limit 1];
        
        ApexPages.currentPage().getParameters().put('id', opp.id);
        
        CalculateTaxController ctc = new CalculateTaxController();

    }
    @isTest static void WithTaxRecords(){
        
        AcctSeed__GL_Account__c gl = [select id from AcctSeed__GL_Account__c where name = 'GL Account First' limit 1];

        Product2 taxRate = new Product2();
        
        taxRate.name = 'TaxProduct';
        taxRate.AcctSeed__Accounting_type__c = 'Tax Rate';
        taxRate.AcctSeed__Tax_Rate__c = 1;
        taxRate.AcctSeed__Expense_GL_Account__c = gl.id;
        taxRate.AcctSeed__Revenue_GL_Account__c = gl.id;
        insert taxRate;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // create standard price book entry
        PricebookEntry pbe = new PricebookEntry();
        
        pbe.Pricebook2Id = pricebookId;
  		pbe.Product2Id = taxRate.Id;
        pbe.UnitPrice = 100;
        pbe.IsActive = true;
        
        insert pbe;
        
        Account acct = [select id from Account where name='myAccount' limit 1];
        
        AcctSeed__Account_Tax__c taxes = new AcctSeed__Account_Tax__c();
        taxes.AcctSeed__Account__c = acct.id;
        taxes.AcctSeed__Tax_Rate__c = taxRate.id;
        taxes.AcctSeed__Tax_Type__c = 'Sales';

        insert taxes;

        opportunity opp = [select Id, Name, AccountId, Account.Name, 
               Gl_Account_Variable_1__c from Opportunity where name = 'myOpportunity' limit 1];
        
        ApexPages.currentPage().getParameters().put('id', opp.id);
        
        CalculateTaxController ctc = new CalculateTaxController();

    }
    @isTest static void TaxableProducts(){
        
               
        AcctSeed__GL_Account__c gl = [select id from AcctSeed__GL_Account__c where name = 'GL Account First' limit 1];

        Product2 taxRate = new Product2();
        
        taxRate.name = 'TaxProduct';
        taxRate.AcctSeed__Accounting_type__c = 'Tax Rate';
        taxRate.AcctSeed__Tax_Rate__c = 1;
        taxRate.AcctSeed__Expense_GL_Account__c = gl.id;
        taxRate.AcctSeed__Revenue_GL_Account__c = gl.id;
        insert taxRate;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // create standard price book entry
        PricebookEntry pbtx = new PricebookEntry();
        
        pbtx.Pricebook2Id = pricebookId;
  		pbtx.Product2Id = taxRate.Id;
        pbtx.UnitPrice = 100;
        pbtx.IsActive = true;
        
        insert pbtx;
        
        Account acct = [select id from Account where name='myAccount' limit 1];
        
        AcctSeed__Account_Tax__c taxes = new AcctSeed__Account_Tax__c();
        taxes.AcctSeed__Account__c = acct.id;
        taxes.AcctSeed__Tax_Rate__c = taxRate.id;
        taxes.AcctSeed__Tax_Type__c = 'Sales';

        insert taxes;
        
        
        Product2 prod = new Product2();
        
        prod.name = 'Product 2';
        prod.AcctSeed__Accounting_type__c = 'Taxable Product';
        // prod.AcctSeed__Tax_Rate__c = 1;
        prod.AcctSeed__Expense_GL_Account__c = gl.id;
        prod.AcctSeed__Revenue_GL_Account__c = gl.id;
        insert prod;
        
        PricebookEntry pbe = new PricebookEntry();
        
        pbe.Pricebook2Id = pricebookId;
  		pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 12;
        pbe.IsActive = true;
        
        insert pbe;

        opportunity opp = [select Id, Name, AccountId, Account.Name, 
               Gl_Account_Variable_1__c from Opportunity where name = 'myOpportunity' limit 1];
        
        opportunitylineitem l1 = new opportunitylineitem();
        
        l1.Quantity = 2;
        l1.UnitPrice = 2;
        l1.Product2Id = prod.id;
        l1.PricebookEntryId = pbe.id;
        l1.OpportunityId = opp.id;
        
        insert l1;
        
        ApexPages.currentPage().getParameters().put('id', opp.id);
        
        CalculateTaxController ctc = new CalculateTaxController();
        
        ctc.selectedTaxId = taxes.id;
        ctc.selectedTaxValue = taxRate.Name;
        
        ctc.Back();
        ctc.CalculateTax();
        

    }
    @isTest static void RunTest(){

        opportunity opp = [select Id, Name, AccountId, Account.Name, 
               Gl_Account_Variable_1__c from Opportunity where name = 'myOpportunity' limit 1];
        
        ApexPages.currentPage().getParameters().put('id', opp.id);
        
        CalculateTaxController ctc = new CalculateTaxController();

    }
}
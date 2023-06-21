@isTest
public class PartProductExtensionTest {
    
    @testSetup static void CreateData(){

            AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',
            AcctSeed__Type__c = 'GL Account Variable 1');
        
        	insert av;

            AcctSeed__GL_Account__c gl_normal = new AcctSeed__GL_Account__c();
            
            gl_normal.name = 'GL Account First';
            gl_normal.AcctSeed__type__c = 'Balance Sheet';
            gl_normal.AcctSeed__Sub_Type_1__c = 'Liabilities';
            gl_normal.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
            gl_normal.AcctSeed__Active__c = true;
            gl_normal.GL_Account_Variable_1__c = av.id;
        
        	insert gl_normal;
 
            // create product
            Product2 prod = new Product2();
            
            prod.Name = 'myProduct';
            prod.ProductCode = 'ABC123';
            prod.AcctSeed__Unit_Cost__c = 100;
            prod.IsActive = true;
            prod.AcctSeed__Inventory_Type__c = 'Purchased';
            prod.AcctSeed__Expense_GL_Account__c = gl_normal.id;
            prod.AcctSeed__Inventory_GL_Account__c = gl_normal.id;
            prod.AcctSeed__Revenue_GL_Account__c = gl_normal.id;
            prod.Type__c = 'Part';
            
            insert prod;
        
            Id pricebookId = Test.getStandardPricebookId();
            
            // create standard price book entry
            PricebookEntry pbe = new PricebookEntry();
            
            pbe.Pricebook2Id = pricebookId;
            pbe.Product2Id = prod.Id;
            pbe.UnitPrice = 100;
            pbe.IsActive = true;
            
            insert pbe;
    }
    
    @isTest static void ParentId(){
        
        Product2 prod = [select id from product2 where name='myProduct' limit 1];
        
        AcctSeed__Product_Part__c pp = new AcctSeed__Product_Part__c();
        
        ApexPages.standardController std = new ApexPages.standardController(pp);
        
        ApexPages.currentPage().getParameters().put('parentId', prod.id);
        ApexPages.currentPage().getParameters().put('childId', null);
        ApexPages.currentPage().getParameters().put('retURL', '/'+prod.id);
        
        PartProductExtension ppe = new PartProductExtension(std);
        
        ppe.SavePart();
        ppe.SaveAndMore();
        ppe.Back();
    }
    @isTest static void ChildId(){
        
        Product2 prod = [select id from product2 where name='myProduct' limit 1];
        
        AcctSeed__Product_Part__c pp = new AcctSeed__Product_Part__c();
        
        ApexPages.standardController std = new ApexPages.standardController(pp);
        
        ApexPages.currentPage().getParameters().put('parentId', null);
        ApexPages.currentPage().getParameters().put('childId', prod.id);
        ApexPages.currentPage().getParameters().put('retURL', '/'+prod.id);
        
        PartProductExtension ppe = new PartProductExtension(std);
        
        ppe.SavePart();
        ppe.SaveAndMore();
        ppe.Back();

    }
}
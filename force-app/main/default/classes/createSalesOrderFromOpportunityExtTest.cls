@isTest
public class createSalesOrderFromOpportunityExtTest {
    
    static testmethod void testMethod1() {
        
        test.startTest();        
        
        AcctSeed__Accounting_Variable__c accountingVariable = new AcctSeed__Accounting_Variable__c(Name = 'Test Accounting Variable', 
                                                                                                   AcctSeed__Type__c = 'GL Account Variable 1');
        insert accountingVariable;
        
        List<Account> accList = new List<Account>();        
        accList.add(new Account(Name = 'Test Account', AcctSeed__GL_Account_Variable_1__c = accountingVariable.Id, 
                                Industry = 'Hospitality', AcctSeed__Accounting_Type__c = 'Customer', 
                                BillingCountry = 'United States', BillingCIty = 'Birmingham', BillingState='AL'));
        
        accList.add(new Account(Name = 'Vendor Account', AcctSeed__GL_Account_Variable_1__c = accountingVariable.Id, 
                                Industry = 'Manufacturing', AcctSeed__Accounting_Type__c = 'Vendor', 
                                BillingCountry = 'United States', BillingCIty = 'Birmingham', BillingState='AL'));        
        insert accList;
        
        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(LastName = 'test Contact', Email='testcontact@mail.com', AccountId = accList[0].Id));
        contactList.add(new Contact(LastName = 'vendor Contact', Email='testcontact@mail.com', AccountId = accList[1].Id));        
        insert contactList;
        
        Opportunity opp = new Opportunity(Name='Test Opportunity', AccountId = accList[0].Id,
                                          ContactPerson__c = contactList[0].Id, StageName = 'Closed Won', Probability = 100, CloseDate = Date.newInstance(2018,10,10),
                                          ForecastCategoryName = 'Closed');
        
        insert opp;
        
        List<AcctSeed__GL_Account__c> glAccountList = new List<AcctSeed__GL_Account__c>();
        glAccountList.add(new AcctSeed__GL_Account__c(Name = 'Inventory GL Account Test', AcctSeed__Type__c = 'Balance Sheet',
                                                      AcctSeed__Sub_Type_1__c = 'Assets', AcctSeed__Sub_Type_2__c = 'Current Assets'));
        glAccountList.add(new AcctSeed__GL_Account__c(Name = 'Revenue GL Account Test', AcctSeed__Type__c = 'Revenue',
                                                      AcctSeed__Sub_Type_1__c = 'Product Revenue', AcctSeed__Sub_Type_2__c = 'Product Family 1'));
        glAccountList.add(new AcctSeed__GL_Account__c(Name = 'Expense GL Account Test', AcctSeed__Type__c = 'Expense',
                                                      AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold', AcctSeed__Sub_Type_2__c = 'Materials'));
        insert glAccountList;        
        
        
        //creating a new product
        Product2 testProduct = new Product2(Name = 'Test Product', ProductCode = 'SKZ00013', IsActive = true, Category__c = 'Custom',
                                            AcctSeed__Inventory_Type__c = 'Purchased', AcctSeedERP__Default_Vendor__c = accList[1].Id,
                                            AcctSeed__Unit_Cost__c = 45, AcctSeed__Inventory_Product__c = true, AcctSeed__Inventory_GL_Account__c = glAccountList[0].Id,
                                            AcctSeed__Revenue_GL_Account__c = glAccountList[1].Id, AcctSeed__Expense_GL_Account__c = glAccountList[2].Id);
        insert testProduct;
        
        //define the standart price for the product
        //Pricebook2 standard = [Select Id, Name, IsActive From Pricebook2 where Where Id IsStandard = true LIMIT 1];
        
        PriceBook2 pb2=new PriceBook2(Name = 'test', IsActive = true);      	
        insert pb2;                
        PricebookEntry pbe = createPricebookEntry(test.getStandardPricebookId(),pb2,testProduct);
        
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(PricebookEntryId = pbe.Id, OpportunityId = opp.Id, Product2Id = testProduct.Id, Quantity = 2, UnitPrice = 100,
                                                                  Item_Description__c = 'Test OpplineItem');
        
        insert oppLineItem;
        
        //[SELECT Id, Product2Id, Product2.Name, ProductCode,Item_Description__c, Size__c, Quantity, TotalPrice, UnitPrice FROM OpportunityLineItem WHERE OpportunityId = :opportunity.Id]
        
        // Instantiate the standard controller
        Apexpages.StandardController sc = new Apexpages.standardController(opp);
        
        // Instantiate the extension
        createSalesOrderFromOpportunityExt ext = new createSalesOrderFromOpportunityExt(sc);
        ext.insertRecords();
        
        test.stopTest();
    }
    
    public static PricebookEntry createPricebookEntry (Id standardId, Pricebook2 newPricebook, Product2 prod) {
        System.debug('***** starting one');
        PricebookEntry one = new PricebookEntry();
        one.pricebook2Id = standardId;
        one.product2id = prod.id;
        one.unitprice = 1249.0;
        one.isactive = true;
        insert one;
        System.debug('***** one complete, ret next');
        PricebookEntry ret = new PricebookEntry();
        ret.pricebook2Id = newPricebook.id;
        ret.product2id = prod.id;
        ret.unitprice = 1250.0;
        ret.isactive = true;
        insert ret;
        return ret;
    }
}
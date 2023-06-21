@isTest
public class CloneOpportunityControllerTest {
    
    @testSetup static void createdata(){
        
        // accounting  variable
        list<AcctSeed__Accounting_Variable__c> avList = new list<AcctSeed__Accounting_Variable__c>();       
    	avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin China',AcctSeed__Type__c = 'GL Account Variable 1'));
        avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1'));
        insert avList;

        Sales_rep__c srp = new Sales_rep__c();

        srp.name = 'Test';
        srp.Email__c = 'Test@test.com';
        srp.Active__c = 'Yes';

        insert srp;


        // create account
        list<Account> acctList = new list<Account>();  
              
        Account acct = new Account();       
        acct.Name = 'myAccount';
        acct.Sales_Rep_O__c = srp.id;
        acct.Type = 'Customer';
        acct.AcctSeed__Billing_Terms_Name__c = 'Example terms';
        acct.AcctSeed__GL_Account_Variable_1__c = avList[1].id;
        
        insert acct;


        // create contact
        Contact cont = new Contact();        
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.GL_Account_Variable_1__c = avList[1].id;
        insert cont;
        
        // Gl account with bank unchecked
        AcctSeed__GL_Account__c ga = new AcctSeed__GL_Account__c();
        ga.Name = 'GL Account Test';
        ga.AcctSeed__Active__c = true;
        ga.AcctSeed__Type__c = 'Revenue';
        ga.AcctSeed__Sub_Type_1__c = 'Product Revenue';
        ga.AcctSeed__Sub_Type_2__c = 'Product Family 1';
        ga.AcctSeed__Bank__c = false;
        
        insert ga;
        
        Product2 prod = new Product2();
        
        prod.Name = 'myProduct';
        prod.ProductCode = 'ABC123';
        prod.AcctSeed__Unit_Cost__c = 100;
        prod.IsActive = true;
        prod.AcctSeed__Inventory_Type__c = 'Purchased';
        prod.AcctSeed__Expense_GL_Account__c = ga.id;
        prod.AcctSeed__Inventory_GL_Account__c = ga.id;
        prod.AcctSeed__Revenue_GL_Account__c = ga.id;
        prod.type__c = 'Product';
        
        insert prod;
        
        // get the standard price book id
        Id pricebookId = Test.getStandardPricebookId();
        
        // create standard price book entry
        PricebookEntry pricebentry = new PricebookEntry();
        
        pricebentry.Pricebook2Id = pricebookId;
  		pricebentry.Product2Id = prod.Id;
        pricebentry.UnitPrice = 100;
        pricebentry.IsActive = true;
        
        insert pricebentry;

        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.Sales_Rep_O__c = srp.id;
        opp.stagename = 'Need Analysis';
        opp.closedate = Date.today() + 7;
        opp.GL_Account_Variable_1__c = avList[1].id;

        insert opp;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.Id;
        oli.Product2Id = prod.Id;
        oli.PricebookEntryId = pricebentry.Id;
        oli.Quantity = 10;
        oli.UnitPrice = 100;
        oli.Description = 'myDescription';
        
        insert oli;
        
        Optional_Products_Opportunity__c opo = new Optional_Products_Opportunity__c();
        
        opo.Opportunity__c = opp.Id;
        opo.Description__c = 'myDescription';
        opo.Item_Description__c = 'myItemDescription';
        opo.Product__c = prod.Id;
        opo.Quantity__c = 2;
        opo.UnitPrice__c = 10;
        opo.PriceBookEntryId__c = pricebentry.Id; 
        
        insert opo;
    }
    
    @isTest static void runTest(){

        List<string> fieldNames = new List<string>();
        
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = 
        schemaMap.get('Opportunity').getDescribe().fields.getMap();

        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            fieldNames.add(dfield.getname());

        }

        String fieldstring = String.join(fieldNames,',');
        
        String oPPName = 'Test Opportunity';

        Opportunity opp = Database.query('Select ' + fieldstring + 
        ' from Opportunity where name=:oPPName Limit 1');

        Sales_rep__c srp = new Sales_rep__c();

        srp.name = 'Test 2';
        srp.Email__c = 'Test2@test.com';
        srp.Active__c = 'Yes';

        insert srp;
        
        Test.startTest();

        ApexPages.currentPage().getParameters().put('salesrepid', srp.id);
        ApexPages.currentPage().getParameters().put('ownerid', UserInfo.getUserId());
        ApexPages.currentPage().getParameters().put('createproducts', 'yes');
        
        ApexPages.StandardController std = new ApexPages.StandardController(opp);
        CloneOpportunityController cop = new CloneOpportunityController(std);
        
        cop.saveOverride();
        
        Test.stopTest();
        
    }

}
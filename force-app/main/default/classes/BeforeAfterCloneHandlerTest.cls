@isTest 
public class BeforeAfterCloneHandlerTest {

    @testSetup static void CreateData(){
        
        list<AcctSeed__Accounting_Variable__c> avList = new list<AcctSeed__Accounting_Variable__c>();
        
    	avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin China',AcctSeed__Type__c = 'GL Account Variable 1'));
        
        avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1'));
        insert avList;

        
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
        aegl.GL_Account_Variable_1__c = [SELECT Id FROM AcctSeed__Accounting_Variable__c WHERE Name = 'Seawin USA' AND AcctSeed__Type__c = 'GL Account Variable 1' LIMIT 1].Id;
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
        insert opp;
       
         // create opportunity
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Opportunity2';
        //opp2.Sales_Rep_O__c = sr.id;
        opp2.AccountId = acct.Id;
        opp2.GL_Account_Variable_1__c = avList[1].id; 
        opp2.Type = 'Template';
        opp2.StageName = 'Follow up';
        opp2.CloseDate = system.today();
        opp2.ContactPerson__c = cont.Id;
        insert opp2;
                
        Opportunity oppCloned = opp2.clone(false, false, false, false);
        insert oppCloned;


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
        oli.OpportunityId = opp2.Id;
        oli.Product2Id = prod.Id;
        oli.PricebookEntryId = pricebentry2.Id;
        oli.Quantity = 10;
        oli.UnitPrice = 100;
        oli.Description = 'myDescription';
        insert oli;
       
        
        LIST<Opportunity> oppList = new LIST<Opportunity>();
        oppList.add(opp);
        oppList.add(opp2);
        
    }
    
    @isTest static void runTest(){   
     
        Set<Id> ol = (new Map<Id, OpportunityLineItem>([SELECT Id FROM OpportunityLineItem])).keySet();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];

        BeforeAfterCloneHandler.ProcessAfter(oppList);
        BeforeAfterCloneHandler.DeleteProducts(ol);


     // Dont need this because the trigger is fired when the opportunity is inserted   
     /*
     LIST<Opportunity> listOpp = [select id 
                                  from Opportunity
                                  where Name = 'Opportunity1' OR Name = 'Opportunity2'];
     */                                 
     // BeforeAfterCloneHandler oli = new BeforeAfterCloneHandler(); 
     
     // we dont need to instantiate the class because the trigger runs the handler  
        
        
    }
}
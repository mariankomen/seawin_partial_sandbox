@isTest
public with sharing class MonthlyOpportunityBatchTest {
    
    @TestSetup
    static void makeData(){
        Profile pf = [Select Id from profile where Name = 'System Administrator'];
        
        String orgId = UserInfo.getOrganizationId(); 
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName = orgId + dateString + RandomId; 

        User uu1 = new User(firstname = 'ABC', 
                            lastName = 'XYZ', 
                            email = uniqueName + '@test' + orgId + '.org', 
                            Username = uniqueName + '@test' + orgId + '.org', 
                            EmailEncodingKey = 'ISO-8859-1', 
                            Alias = uniqueName.substring(18, 23), 
                            TimeZoneSidKey = 'America/Los_Angeles', 
                            LocaleSidKey = 'en_US', 
                            LanguageLocaleKey = 'en_US', 
                            ProfileId = pf.Id
                           ); 
        
        insert uu1;
        
        Sales_rep__c sr = new Sales_rep__c();
        sr.Active__c = 'Yes';
        sr.Name = 'John Doe';
        sr.User__c = uu1.id;
        
        insert sr;
        
        uu1.Sales_Rep_Id__c = sr.id;
        
        update uu1;

        Account acct = new Account();
        
        acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.BillingStreet = 'street';
        acct.BillingCity = 'city';
        acct.BillingState = 'state';
        acct.BillingPostalCode = 'postalcode';
        acct.BillingCountry = 'country';
        
        insert acct;

        Contact cont = new Contact();
        
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        
        insert cont;

        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'Seawin USA';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;

        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.Sales_Rep_O__c = sr.id;
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Closed Won';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = accVar.Id;

        insert opp;

        Datetime testDT = Datetime.newInstance(2020, 1, 1, 1, 1, 1);
        Test.setCreatedDate(opp.Id, testDT);

        Opportunity opp1 = new Opportunity();
        
        opp1.Name = 'myOpportunit11111y';
        opp1.Sales_Rep_O__c = sr.id;
        opp1.AccountId = acct.Id;
        opp1.Type = 'Actual Order';
        opp1.StageName = 'Closed Won';
        opp1.CloseDate = system.today();
        opp1.ContactPerson__c = cont.Id;
        opp1.GL_Account_Variable_1__c = accVar.Id;
        insert opp1;
        
        delete opp1;
    }

    @IsTest
    public static void MonthlyOpportunityBatch_Test(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        MonthlyOpportunityBatch batch = new MonthlyOpportunityBatch();
        MonthlyOpportunityBatch.ErrorWrapper k= new MonthlyOpportunityBatch.ErrorWrapper(opp.Id, 'Test');
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }
}
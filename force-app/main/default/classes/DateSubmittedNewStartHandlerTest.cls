@isTest
public class DateSubmittedNewStartHandlerTest {
    
    @testSetup static void MakeData(){
        
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
        
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
        Id pricebookId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity();
        opp.Name = 'myOpportunity';
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Closed Won';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = accVar.id;
        opp.RecordTypeId = RecordTypeIdOpportunity;
        opp.Pricebook2Id = pricebookId;
        insert opp;
        
        // create quote
        Quote qt = new Quote();
        qt.OpportunityId = opp.Id;
        qt.Name = 'myQuote';
        qt.Status = 'Presented';
        qt.Quote_Date__c = Date.today();
        qt.Pricebook2Id = pricebookId;
        insert qt;
        
    }
	
    @isTest static void runTests(){

        // Change the quote status back to pending
        Quote q = [select id,status from quote where name='myQuote' limit 1];
        q.status = 'Pending';
        update q;
        
        // Assign the opportunity field null
        Opportunity o = [select id, Newly_Submitted_Quote_First_Date__c from Opportunity
                        where name='myOpportunity' limit 1];
        o.Newly_Submitted_Quote_First_Date__c = null;
        Update o;
		
        // Change the quote status back to presented for update case test
        q.status = 'Presented';
        
        Test.startTest();
        	update q;
        Test.stopTest();
        
    }
}
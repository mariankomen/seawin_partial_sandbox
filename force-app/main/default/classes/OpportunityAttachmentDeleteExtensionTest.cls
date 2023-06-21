@isTest
public class OpportunityAttachmentDeleteExtensionTest {

    
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
        
     }
    
    @isTest static void StartProcess(){
         
        Opportunity opp = [select id, Name from Opportunity where name='myOpportunity' limit 1];
        
        Test.startTest();
        
        PageReference pageRef = Page.OpportunityPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', opp.id);
        ApexPages.currentPage().getParameters().put('retURL', opp.id);
        
        OpportunityAttachmentDeleteExtension obj = new OpportunityAttachmentDeleteExtension();
        obj.back();
        
    }
    
}
@isTest
public class OpportunityAttachmentExtensionTest {
    
    @testSetup static void createData(){
        
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        // create account
        Account acct = new Account();
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
        
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();        
        gl.name = 'GL Account First';
        gl.AcctSeed__type__c = 'Balance Sheet';
        gl.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl.AcctSeed__Active__c = true;
        gl.AcctSeed__Bank__c = true;
        gl.GL_Account_Variable_1__c = accVar.id;
		insert gl;
        
        // create attachment
        Attachment Secnd = new Attachment();
        Secnd.Name = 'Attachment Secnd';
        Secnd.Body = Blob.valueOf('Test Text.');
        Secnd.ParentId = opp.id;
        insert Secnd;
    }
    
    @isTest static void StartProcess(){
        
        Opportunity opp = [select id, Name from Opportunity where Name = 'myOpportunity'];
        Attachment att = [select id, Name, ContentType, Body, ParentId from Attachment where ParentId =: opp.Id limit 1];
        
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', opp.id);
        
        OpportunityAttachmentExtension opAtt = new OpportunityAttachmentExtension();
        opAtt.attachmentName = att.name;
        OpportunityAttachmentExtension.attachmentBody = att.body;
        //soAtt.attachment = att;
        opAtt.upload();
        opAtt.upload_Process();
        opAtt.done_Process();
        opAtt.getShortDescriptionOptions();
        
        test.stopTest();
    }
}
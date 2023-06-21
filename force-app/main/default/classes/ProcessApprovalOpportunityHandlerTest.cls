@isTest
public class ProcessApprovalOpportunityHandlerTest {
    
    @testSetup static void createData(){
        
        // create GL Account Variable 1 needed by account
        AcctSeed__Accounting_Variable__c glav = new AcctSeed__Accounting_Variable__c(
            Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1');
        
        insert glav;
        
        // Create accounts
        
        Account acct = new Account(name='myAccount', AcctSeed__GL_Account_Variable_1__c=glav.id);
        insert acct;
        
        Opportunity op = new Opportunity(name='myOpportunity', price_level__c = null, stagename='Closed Won', 
                                         CloseDate=date.today() + 60, accountid=acct.id,
                                        Gl_Account_Variable_1__c = glav.id);
        insert op;
        
        // Submit to approval
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Approve.');
        req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req.setObjectId(op.Id);

        Approval.ProcessResult result = Approval.process(req);
        
    }
    
    @isTest static void Approved(){
        
        Opportunity oppty = [select id, name, Approval_Status__c,price_level__c 
                        from opportunity where name='myOpportunity' limit 1];
        
        oppty.Approval_Status__c = 'Approved';
        
        Test.startTest();
        	update oppty;
        Test.stopTest();
        
    }
    @isTest static void Rejected(){

        Opportunity oppty = [select id, name, Approval_Status__c,price_level__c 
                        from opportunity where name='myOpportunity' limit 1];
        
        oppty.Approval_Status__c = 'Rejected';
        
        Test.startTest();
        	update oppty;
        Test.stopTest();
    }
}
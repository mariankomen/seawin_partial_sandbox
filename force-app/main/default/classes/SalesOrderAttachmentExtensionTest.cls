@isTest
public class SalesOrderAttachmentExtensionTest {
    
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
		insert gl;
        
        AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();
        abf.Name = 'newPDF Format';
        abf.AcctSeed__Type__c = 'Purchase Order';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        insert abf;
        
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
        ledger.Name = 'myLedger';
        ledger.AcctSeed__Type__c = 'Transactional';
        ledger.AcctSeed__Billing_Activity_Statement_Format__c = abf.id;
        ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = abf.id;
        ledger.AcctSeed__Default_Bank_Account__c = gl.id;
        ledger.AcctSeed__Default_Billing_Format__c = abf.id; 
        ledger.AcctSeed__Default_Purchase_Order_Format__c = abf.id;
        ledger.AcctSeed__Default_Packing_Slip_Format__c = abf.id;
        insert ledger;
        
        AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c();
        av.Name = 'Seawin China';
        av.AcctSeed__Type__c = 'GL Account Variable 1';
    	insert av;
        
        Id RecordTypeIdSO = Schema.SObjectType.AcctSeedERP__Sales_Order__c.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
        
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c();    
        salesorder.AcctSeedERP__Customer__c = acct.Id;
        salesorder.AcctSeedERP__Opportunity__c = opp.Id;
        salesorder.Contact__c = cont.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
       	salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.GL_Account_Variable_1__c = av.id;
        salesorder.Stage__c = 'Production';
        salesorder.RecordTypeId = RecordTypeIdSO;
        salesorder.GL_Account_Variable_1__c = accVar.Id;
        //salesorder.Sales_Rep_O__c = salesrepList[0].id;
        //salesorder.Sales_Rep_O_2__c = salesrepList[1].id;
        insert salesorder;
        
        // create attachment
        Attachment att = new Attachment();
        att.Name = 'Attachment Secnd';
        att.Body = Blob.valueOf('Test Text.');
        att.ParentId = salesorder.id;
        insert att;
    }
    
    @isTest static void StartProcess(){
        Opportunity opp = [select id, Name from Opportunity where Name = 'myOpportunity'];
        
        AcctSeedERP__Sales_Order__c so = [select id, Name from AcctSeedERP__Sales_Order__c 
                                          where acctseederp__opportunity__c =: opp.id limit 1];
        
        Attachment att = [select id, Name, ContentType, Body, ParentId from Attachment where ParentId =: so.Id limit 1];
        
        test.startTest();
		
        ApexPages.currentPage().getParameters().put('id', so.id);
        
        SalesOrderAttachmentExtension soAtt = new SalesOrderAttachmentExtension();
        soAtt.attachmentName = att.name;
        SalesOrderAttachmentExtension.attachmentBody = att.body;
        //soAtt.attachment = att;
        soAtt.upload();
        soAtt.upload_Process();
        soAtt.done_Process();
        soAtt.getShortDescriptionOptions();
    }
}
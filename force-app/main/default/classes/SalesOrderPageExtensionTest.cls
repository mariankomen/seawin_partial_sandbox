@isTest
public class SalesOrderPageExtensionTest {
    
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
        gl.GL_Account_Variable_1__c = accVar.Id;
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
        //salesorder.Sales_Rep_O__c = salesrepList[0].id;
        //salesorder.Sales_Rep_O_2__c = salesrepList[1].id;
        salesorder.GL_Account_Variable_1__c = accVar.Id;
        insert salesorder;
       
        

    }
    
    @isTest static void runTests(){
        Opportunity opp = [select id,name from opportunity where name='myOpportunity' limit 1];
        
        acctseederp__sales_order__c so = [select id,name,AcctSeedERP__Status__c,
                                          Stage__c, Status_Helper__c,Stage_Helper__c,
                                          Show_SalesOrder_Message__c from acctseederp__sales_order__c 
                                          where acctseederp__opportunity__c =:opp.id limit 1];
        
 		// Create attachments 
 		Attachment One = new Attachment();
        
        One.Name = 'Attachment One';
        One.Body = Blob.valueOf('Sample Text.');
		One.ParentId = opp.id;
        
        insert One;
        
        Attachment Two = new Attachment();
        
        Two.Name = 'Attachment Two';
        Two.Body = Blob.valueOf('Test Text.');
        Two.ParentId = so.id;
        
        insert Two;
        
        test.startTest();
		        
        PageReference pageRef = Page.SalesOrderPage;
        Test.setCurrentPage(pageRef);
		
        ApexPages.currentPage().getParameters().put('id', so.id);
        
        ApexPages.StandardController std = new ApexPages.StandardController(so);
        
        SalesOrderPageExtension s = new SalesOrderPageExtension(std);
        s.SOLHasChanged = true;
        system.assert(s.SOLHasChanged);
        s.hideSOMessage();
        
        s.ResetFields();
        // --------------
        // sorting test
        
        // ------------title
        ApexPages.currentPage().getParameters().put('sort', 'title');
        s.checkSort();
		
        s.TitleSortUp = false;
        s.sortProcess = 'DESC';
        ApexPages.currentPage().getParameters().put('sort', 'title');
        s.checkSort();
        
        // ---------created
        ApexPages.currentPage().getParameters().put('sort', 'created');
        s.checkSort();
        
        s.CreatedSortUp = false;
        s.sortProcess = 'DESC';
        ApexPages.currentPage().getParameters().put('sort', 'created');
        s.checkSort();
        
        // -------------last
        ApexPages.currentPage().getParameters().put('sort', 'last');
        s.checkSort();
        
        s.LastSortUp = false;
        s.sortProcess = 'DESC';
        ApexPages.currentPage().getParameters().put('sort', 'last');
        s.checkSort();
        
        // -------------- by
        ApexPages.currentPage().getParameters().put('sort', 'by');
        s.checkSort();
        
        s.BySortUp = false;
        s.sortProcess = 'DESC';
        ApexPages.currentPage().getParameters().put('sort', 'by');
        s.checkSort(); 
        
        // ----------------
        
        s.newAttachment();
        s.hideChangeMessage();
        s.removeHelperValue();
        s.ChangedMessage();
        s.hideAccountMessage();
        s.hideContactMessage();
        
        ApexPages.currentPage().getParameters().put('viewId', One.id);
        s.viewAttachment();
        
        ApexPages.currentPage().getParameters().put('editId', Two.id);
        s.editAttachment();
        
        ApexPages.currentPage().getParameters().put('deleteId', Two.id);
        s.deleteAttachment();
 		test.stopTest();
    }
}
@isTest
public class BillingDeleteExtensionTest {

    @testSetup static void createData(){
        
        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        
        Date dates = date.today();
        
        Integer monthDays = date.daysInMonth(dates.year(), dates.month());
        
        ap.Name = dates.year() + '-0' + dates.month();
        ap.AcctSeed__Status__c = 'Open';
        ap.AcctSeed__Start_Date__c = Date.newInstance(dates.year(), dates.month(), dates.day());
        ap.AcctSeed__End_Date__c = Date.newInstance(dates.year(), dates.month(), monthDays);
        
        insert ap;
    
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
    
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        Sales_Rep__c sr = new Sales_Rep__c();
        
        sr.name = 'Test Team';
        sr.Email__c = 'team@test.com';
        sr.Team__c = UserInfo.getUserId();
        
        insert sr;
        
 		// create account
        Account acct = new Account();
        acct.Name = 'myAccount';
        acct.Sales_Rep_O__c = sr.id;
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
        opp.Sales_Rep_O__c = sr.id;
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
        
        Id RecordTypeIdSO = 
            Schema.SObjectType.AcctSeedERP__Sales_Order__c.getRecordTypeInfosByName()
            .get('Seawin USA Hospitality').getRecordTypeId();
        
        AcctSeedERP__Sales_Order__c so = new AcctSeedERP__Sales_Order__c();   
        so.AcctSeedERP__Customer__c = acct.Id;
        so.sales_rep_o__c = sr.id;
        so.AcctSeedERP__Opportunity__c = opp.Id;
        so.Contact__c = cont.Id;
        so.AcctSeedERP__Status__c = 'Open';
        so.AcctSeedERP__Ledger__c = ledger.id;
        so.GL_Account_Variable_1__c = av.id;
        so.Stage__c = 'Production';
        so.RecordTypeId = RecordTypeIdSO;
        so.GL_Account_Variable_1__c = accVar.Id;

        insert so;
        
        AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
        bill.AcctSeed__Status__c = 'Approved';
        bill.AcctSeed__PDF_Email_Status__c = 'Unsent';
		bill.AcctSeed__Customer__c = acct.id;
        bill.AcctSeed__Billing_Format__c = abf.id;
        bill.AcctSeedERP__Sales_Order__c = so.id; 
        bill.AcctSeed__Date__c = Date.Today();
        bill.AcctSeed__Due_Date2__c = Date.Today();
        bill.AcctSeed__Ledger__c = ledger.id;
        bill.AcctSeed__Accounting_Period__c = ap.id;
        insert bill;
        
    }
    
    @isTest static void StartProcess(){
        Account acc = [select id from Account where Name = 'myAccount' limit 1 ];
        
        AcctSeed__Billing__c billing = [select id, AcctSeed__Status__c , AcctSeedERP__Sales_Order__c from AcctSeed__Billing__c 
                                        where AcctSeed__Status__c = 'Approved' and AcctSeed__Customer__c =: acc.Id limit 1];
                       
        PageReference pageRef = Page.BillingDeletePage;
        Test.setCurrentPage(pageRef);
		    
        ApexPages.currentPage().getParameters().put('delID', billing.id);
        ApexPages.currentPage().getParameters().put('retURL', '/apex/'+Page.BillingDeletePage+'?id='+billing.id);
        
        ApexPages.StandardController std = new ApexPages.StandardController(billing);
        
        BillingDeleteExtension billngDelteExt = new BillingDeleteExtension(std);
        //System.assertEquals(null, billngDelteExt.strTabName);
        billngDelteExt.DeleteProcess();
        billngDelteExt.back();
    }
}
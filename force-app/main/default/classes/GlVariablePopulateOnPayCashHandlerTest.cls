@isTest
public class GlVariablePopulateOnPayCashHandlerTest {
    
    @testSetup static void createData(){
        
        Date d = Date.today();

        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        
        Integer year = d.year();
        String month = d.month() > 9 ? '' + d.month() : '0' + d.month();

        ap.Name = year + '-' + month;
        ap.AcctSeed__Start_Date__c = Date.NewInstance(year, d.month(), 1);
        ap.AcctSeed__End_Date__c = Date.NewInstance(year, d.month(), Date.DaysInMonth(year, d.month()));
        ap.AcctSeed__Status__c = 'Open';
            
        insert ap;
        
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'Seawin USA';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();
        
        abf.Name = 'newPDF Format';
        abf.AcctSeed__Type__c = 'Purchase Order';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        insert abf;
        
        
        // create account
        Account acct = new Account();
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct;
        
        // create contact
        Contact ct = new Contact();
        ct.LastName = 'myLastName';
        ct.AccountId = acct.Id;
        ct.GL_Account_Variable_1__c = accVar.Id;
        insert ct;
        
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = accVar.Id;
        insert aegl;
        
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
        ledger.Name = 'myLedger';
        ledger.AcctSeed__Type__c = 'Transactional';
        ledger.AcctSeed__Billing_Activity_Statement_Format__c = abf.id;
        ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = abf.id;
        ledger.AcctSeed__Default_Bank_Account__c = aegl.id;
        ledger.AcctSeed__Default_Billing_Format__c = abf.id; 
        ledger.AcctSeed__Default_Purchase_Order_Format__c = abf.id;
        ledger.AcctSeed__Default_Packing_Slip_Format__c = abf.id;
        insert ledger;

        acctseederp__purchase_order__c po = new acctseederp__purchase_order__c();
        po.AcctSeedERP__Order_Date__c = date.today();
        po.AcctSeedERP__Status__c = 'Open';
        po.AcctSeedERP__Type__c = 'Drop Shipment';
        po.Stage__c = 'Production';
        po.AcctSeedERP__Purchase_Order_Format__c = abf.Id;
        po.AcctSeedERP__Ledger__c = ledger.Id;
        po.GL_Account_Variable_1__c = accVar.id;
        po.AcctSeedERP__Vendor_Contact__c = ct.id;
        po.AcctSeedERP__Vendor__c = acct.id;

        insert po;
        
        User usr = new User(Firstname='FirstName', LastName='LastName', ProfileId = UserInfo.getProfileId(),
                            Email = 'random@email.com',
                            Username = 'randmna@email.com', Alias='randmna', TimeZoneSidKey='America/Los_Angeles', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US',
                           Default_GL_Account_Variable__c='Seawin USA');
        insert usr;
        
    }
    
    @isTest static void PurchaseOrder(){
        
        AcctSeedERP__Purchase_Order__c po = [select id from AcctSeedERP__Purchase_Order__c limit 1];
        Account acct = [select id from account limit 1];
        
        AcctSeed__Accounting_Period__c ap = [select id from AcctSeed__Accounting_Period__c limit 1];
        AcctSeed__Ledger__c ledger = [select id from AcctSeed__Ledger__c limit 1];
        AcctSeed__GL_Account__c aegl = [select id from AcctSeed__GL_Account__c Limit 1];

        AcctSeed__Cash_Disbursement_Batch__c cashBatch = new AcctSeed__Cash_Disbursement_Batch__c();
        cashBatch.Name = 'batch Name';
        insert cashBatch;
        
        AcctSeed__Account_Payable__c payable = new AcctSeed__Account_Payable__c();
        payable.AcctSeed__Accounting_Period__c = ap.id;  
        payable.AcctSeed__Date__c  = date.today();
        payable.AcctSeed__Due_Date__c = date.today() + 7;
        payable.AcctSeed__Status__c = 'Posted';
        payable.AcctSeedERP__Purchase_Order__c = po.id;
        payable.AcctSeed__Vendor__c = acct.id;
        //payable.AcctSeed__Contact__c = ct.id;
        //payable.AcctSeed__Employee__c = usr.id;
        payable.AcctSeed__Ledger__c = ledger.id;
        payable.AcctSeed__Payee_Reference__c = 'Purchase Order - ' + System.Now().formatLong(); 
        insert payable;

        AcctSeed__Cash_Disbursement__c cashDis = new AcctSeed__Cash_Disbursement__c();
        cashDis.AcctSeed__Amount__c = 1;
        cashDis.AcctSeed__Disbursement_Date__c = date.newInstance(2021, 5, 2);
        cashDis.AcctSeed__Bank_Account__c = aegl.Id;
        cashDis.AcctSeed__Type__c = 'Check';
        cashDis.AcctSeed__Check_Number__c = 123;
        cashDis.AcctSeed__Cash_Disbursement_Batch__c = cashBatch.Id;
        cashDis.AcctSeed__Accounting_Period__c = ap.Id;
        cashDis.AcctSeed__Ledger__c = ledger.Id;
        //cashDis.AcctSeed__Cash_Disbursement_Batch__c
        cashDis.AcctSeed__Status__c = 'Posted';
        cashDis.AcctSeed__Vendor__c = acct.id;
        cashDis.AcctSeed__GL_Account_Variable_1__c = null;
        insert cashDis;
        
        AcctSeed__AP_Disbursement__c apDisb = new AcctSeed__AP_Disbursement__c();
        apDisb.AcctSeed__Account_Payable__c = payable.Id;
        apDisb.AcctSeed__Cash_Disbursement__c = cashDis.Id;
        apDisb.AcctSeed__Accounting_Period__c = ap.Id;
        apDisb.AcctSeed__Paid_Amount__c = 0;
        
        Test.startTest();
        insert apDisb;
        TEst.stopTest();
    }
    
    @isTest static void Vendor(){
        
        Account acct = [select id from account limit 1];
        
        AcctSeed__Accounting_Period__c ap = [select id from AcctSeed__Accounting_Period__c limit 1];
        AcctSeed__Ledger__c ledger = [select id from AcctSeed__Ledger__c limit 1];
        AcctSeed__GL_Account__c aegl = [select id from AcctSeed__GL_Account__c Limit 1];

        AcctSeed__Cash_Disbursement_Batch__c cashBatch = new AcctSeed__Cash_Disbursement_Batch__c();
        cashBatch.Name = 'batch Name';
        insert cashBatch;
        
        AcctSeed__Account_Payable__c payable = new AcctSeed__Account_Payable__c();
        payable.AcctSeed__Accounting_Period__c = ap.id;  
        payable.AcctSeed__Date__c  = date.today();
        payable.AcctSeed__Due_Date__c = date.today() + 7;
        payable.AcctSeed__Status__c = 'Posted';
        //payable.AcctSeedERP__Purchase_Order__c = po.id;
        payable.AcctSeed__Vendor__c = acct.id;
        //payable.AcctSeed__Contact__c = ct.id;
        //payable.AcctSeed__Employee__c = usr.id;
        payable.AcctSeed__Ledger__c = ledger.id;
        payable.AcctSeed__Payee_Reference__c = 'Purchase Order - ' + System.Now().formatLong(); 
        insert payable;

        AcctSeed__Cash_Disbursement__c cashDis = new AcctSeed__Cash_Disbursement__c();
        cashDis.AcctSeed__Amount__c = 1;
        cashDis.AcctSeed__Disbursement_Date__c = date.newInstance(2021, 5, 2);
        cashDis.AcctSeed__Bank_Account__c = aegl.Id;
        cashDis.AcctSeed__Type__c = 'Check';
        cashDis.AcctSeed__Check_Number__c = 123;
        cashDis.AcctSeed__Cash_Disbursement_Batch__c = cashBatch.Id;
        cashDis.AcctSeed__Accounting_Period__c = ap.Id;
        cashDis.AcctSeed__Ledger__c = ledger.Id;
        //cashDis.AcctSeed__Cash_Disbursement_Batch__c
        cashDis.AcctSeed__Status__c = 'Posted';
        cashDis.AcctSeed__Vendor__c = acct.id;
        cashDis.AcctSeed__GL_Account_Variable_1__c = null;
        insert cashDis;
        
        AcctSeed__AP_Disbursement__c apDisb = new AcctSeed__AP_Disbursement__c();
        apDisb.AcctSeed__Account_Payable__c = payable.Id;
        apDisb.AcctSeed__Cash_Disbursement__c = cashDis.Id;
        apDisb.AcctSeed__Accounting_Period__c = ap.Id;
        apDisb.AcctSeed__Paid_Amount__c = 0;
        
        Test.startTest();
        insert apDisb;
        TEst.stopTest();
        
    }
    
    @isTest static void Contact(){

        Contact ct = [select id from Contact limit 1];
        
        AcctSeed__Accounting_Period__c ap = [select id from AcctSeed__Accounting_Period__c limit 1];
        AcctSeed__Ledger__c ledger = [select id from AcctSeed__Ledger__c limit 1];
        AcctSeed__GL_Account__c aegl = [select id from AcctSeed__GL_Account__c Limit 1];
                
        AcctSeed__Cash_Disbursement_Batch__c cashBatch = new AcctSeed__Cash_Disbursement_Batch__c();
        cashBatch.Name = 'batch Name';
        insert cashBatch;
        
        AcctSeed__Account_Payable__c payable = new AcctSeed__Account_Payable__c();
        payable.AcctSeed__Accounting_Period__c = ap.id;  
        payable.AcctSeed__Date__c  = date.today();
        payable.AcctSeed__Due_Date__c = date.today() + 7;
        payable.AcctSeed__Status__c = 'Posted';
        //payable.AcctSeedERP__Purchase_Order__c = po.id;
        //payable.AcctSeed__Vendor__c = acct.id;
        payable.AcctSeed__Contact__c = ct.id;
        //payable.AcctSeed__Employee__c = usr.id;
        payable.AcctSeed__Ledger__c = ledger.id;
        payable.AcctSeed__Payee_Reference__c = 'Purchase Order - ' + System.Now().formatLong(); 
        insert payable;

        AcctSeed__Cash_Disbursement__c cashDis = new AcctSeed__Cash_Disbursement__c();
        cashDis.AcctSeed__Amount__c = 1;
        cashDis.AcctSeed__Disbursement_Date__c = date.newInstance(2021, 5, 2);
        cashDis.AcctSeed__Bank_Account__c = aegl.Id;
        cashDis.AcctSeed__Type__c = 'Check';
        cashDis.AcctSeed__Check_Number__c = 123;
        cashDis.AcctSeed__Cash_Disbursement_Batch__c = cashBatch.Id;
        cashDis.AcctSeed__Accounting_Period__c = ap.Id;
        cashDis.AcctSeed__Ledger__c = ledger.Id;
        //cashDis.AcctSeed__Cash_Disbursement_Batch__c
        cashDis.AcctSeed__Status__c = 'Posted';
        cashDis.AcctSeed__Contact__c = ct.id;
        cashDis.AcctSeed__GL_Account_Variable_1__c = null;
        insert cashDis;
        
        AcctSeed__AP_Disbursement__c apDisb = new AcctSeed__AP_Disbursement__c();
        apDisb.AcctSeed__Account_Payable__c = payable.Id;
        apDisb.AcctSeed__Cash_Disbursement__c = cashDis.Id;
        apDisb.AcctSeed__Accounting_Period__c = ap.Id;
        apDisb.AcctSeed__Paid_Amount__c = 0;
        
        Test.startTest();
        insert apDisb;
        TEst.stopTest();
        
    }
    
    @isTest static void Employee(){

        User usr = [select id from user where firstname='FirstName' and LastName='LastName' limit 1];
        
        AcctSeed__Accounting_Period__c ap = [select id from AcctSeed__Accounting_Period__c limit 1];
        AcctSeed__Ledger__c ledger = [select id from AcctSeed__Ledger__c limit 1];
        AcctSeed__GL_Account__c aegl = [select id from AcctSeed__GL_Account__c Limit 1];
                
        AcctSeed__Cash_Disbursement_Batch__c cashBatch = new AcctSeed__Cash_Disbursement_Batch__c();
        cashBatch.Name = 'batch Name';
        insert cashBatch;
        
        AcctSeed__Account_Payable__c payable = new AcctSeed__Account_Payable__c();
        payable.AcctSeed__Accounting_Period__c = ap.id;  
        payable.AcctSeed__Date__c  = date.today();
        payable.AcctSeed__Due_Date__c = date.today() + 7;
        payable.AcctSeed__Status__c = 'Posted';
        //payable.AcctSeedERP__Purchase_Order__c = po.id;
        //payable.AcctSeed__Vendor__c = acct.id;
        //payable.AcctSeed__Contact__c = ct.id;
        payable.AcctSeed__Employee__c = usr.id;
        payable.AcctSeed__Ledger__c = ledger.id;
        payable.AcctSeed__Payee_Reference__c = 'Purchase Order - ' + System.Now().formatLong();  
        insert payable;

        AcctSeed__Cash_Disbursement__c cashDis = new AcctSeed__Cash_Disbursement__c();
        cashDis.AcctSeed__Amount__c = 1;
        cashDis.AcctSeed__Disbursement_Date__c = date.newInstance(2021, 5, 2);
        cashDis.AcctSeed__Bank_Account__c = aegl.Id;
        cashDis.AcctSeed__Type__c = 'Check';
        cashDis.AcctSeed__Check_Number__c = 123;
        cashDis.AcctSeed__Cash_Disbursement_Batch__c = cashBatch.Id;
        cashDis.AcctSeed__Accounting_Period__c = ap.Id;
        cashDis.AcctSeed__Ledger__c = ledger.Id;
        //cashDis.AcctSeed__Cash_Disbursement_Batch__c
        cashDis.AcctSeed__Status__c = 'Posted';
        cashDis.AcctSeed__Employee__c = usr.id;
        cashDis.AcctSeed__GL_Account_Variable_1__c = null;
        insert cashDis;
        
        AcctSeed__AP_Disbursement__c apDisb = new AcctSeed__AP_Disbursement__c();
        apDisb.AcctSeed__Account_Payable__c = payable.Id;
        apDisb.AcctSeed__Cash_Disbursement__c = cashDis.Id;
        apDisb.AcctSeed__Accounting_Period__c = ap.Id;
        apDisb.AcctSeed__Paid_Amount__c = 0;
        
        Test.startTest();
        insert apDisb;
        TEst.stopTest();
        
    }
}
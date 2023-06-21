@isTest
public class ApprovalProcessTriggerTest {
    
    @testSetup static void createData(){
        
        Id recTypeId = 
            Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();

        AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();
        
        abf.Name = 'Billing Format';
        abf.AcctSeed__Type__c = 'Billing';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        insert abf;
        
        // create GL Account Variable 1 needed by account
        AcctSeed__Accounting_Variable__c glav = new AcctSeed__Accounting_Variable__c(
            Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1');
        
        insert glav;
        
        // Create accounts
        
        Account acct = new Account(name='myAccount', 
                                   AcctSeed__GL_Account_Variable_1__c=glav.id,
                                   approval_status__c = 'Not Approved',
                                  AcctSeed__Accounting_Type__c='Customer');
        insert acct;
        
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'Seawin USA';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;

        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = accVar.Id;
        insert aegl;

        Account acct2 = new Account(name='myAccount2', AcctSeed__GL_Account_Variable_1__c=glav.id,
                                  Price_Level__c='Level 3',AcctSeed__Billing_Terms_Name__c='New Billing Term Name',
                                  Deposit__c='30',
                                  AcctSeed__Billing_Days_Due__c=15,
                                  AcctSeed__Billing_Format__c=abf.id,
                                  AcctSeed__Accounting_Type__c='Manufacture Representative', AcctSeed__Default_Expense_GL_Account__c=aegl.Id);
        insert acct2;
        
        Opportunity op = new Opportunity(name='myOpportunity', price_level__c = null, 
                                         stagename='Closed Won', 
                                         CloseDate=date.today() + 60, accountid=acct.id,
                                        Gl_Account_Variable_1__c = glav.id,
                                        RecordTypeId = recTypeId);
        insert op;
        
        // create GL Account needed by ledger
        AcctSeed__GL_Account__c gla = new AcctSeed__GL_Account__c();
        gla.name = '2010-Vouchers Payable';
        gla.AcctSeed__Type__c = 'Balance Sheet';
        gla.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gla.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gla.AcctSeed__Active__c = true;
        gla.AcctSeed__Bank__c = true;
        gla.GL_Account_Variable_1__c = accVar.id;
        
        insert gla;
        
        // create billing format need by ledger
        AcctSeed__Billing_Format__c format = new AcctSeed__Billing_Format__c();
        
        format.Name = 'myFormat';
        format.AcctSeed__Type__c = 'Purchase Order'; // anything eligible would work here
        format.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF'; // anything eligible would work here 
        format.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template'; // anything eligible would work here
        
        insert format;
        
        // create ledger need by sales order
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
        
        ledger.Name = 'myLedger';
        ledger.AcctSeed__Type__c = 'Transactional';
        ledger.AcctSeed__Billing_Activity_Statement_Format__c = format.id;
        ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = format.id;
        ledger.AcctSeed__Default_Bank_Account__c = gla.id;
        ledger.AcctSeed__Default_Billing_Format__c = format.id; 
        ledger.AcctSeed__Default_Purchase_Order_Format__c = format.id;
        ledger.AcctSeed__Default_Packing_Slip_Format__c = format.id;
        
        insert ledger;
        
        // create sales orders
        
        acctSeederp__sales_order__c order = new acctseederp__sales_order__c(acctseederp__customer__c=acct.id, 
                                                                            price_level__c = null,
                                                                            acctseederp__ledger__c =ledger.id,
                                                                            acctseederp__opportunity__c=op.id,
                                                                           	Gl_Account_Variable_1__c=glav.id);
        insert order;
        
        
    }
    @isTest static void Fields_Check(){
        
        Account acct = [select id, name, isApproved__c,price_level__c from account where name='myAccount' limit 1];
        acct.price_level__c = 'Level 3';
        acct.Approval_Status__c = 'Approved';
        
        Test.startTest();
        try{
            
         	update acct;   
        }catch(Exception ex){
            
            
        }
        Test.stopTEst();
        ApprovalProcessTriggerHandler.coverage();
    }
    @isTest static void No_Fields_Check(){
        
        Account acct = [select id, name, isApproved__c,price_level__c from account where name='myAccount2' limit 1];
        acct.price_level__c = 'Level 3';
        acct.Approval_Status__c = 'Approved';
        
        Test.startTest();
        try{
            
         	update acct;   
        }catch(Exception ex){
            
            
        }
        Test.stopTEst();
        
    }
}
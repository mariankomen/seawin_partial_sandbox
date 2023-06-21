@isTest
public class SalesOrderStatusChangeHandlerTest {
    
    @testSetup static void createData(){
        
        // create GL Account Variable 1 needed by account
        AcctSeed__Accounting_Variable__c glav = new AcctSeed__Accounting_Variable__c(
            Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1');
        
        insert glav;
        
        // Create accounts
        
        Account acct = new Account(name='myAccount', AcctSeed__GL_Account_Variable_1__c=glav.id);
        
        insert acct;
        
        // Create Contacts
        
        List<Contact> contacts = new List<Contact>();
        
        Contact contct1 = new Contact(LastName='myContact1', LeadSource = 'AAOHA 2020');
        contacts.add(contct1);
        
        Contact contct2 = new Contact(LastName='myContact2', LeadSource = 'Customer Event');
        contacts.add(contct2);
        
        insert contacts;
        
        // Create opportunities
        
        Opportunity op = new Opportunity(name='myOpportunity', price_level__c = null, stagename='Closed Won',
                                         contactperson__c = contct1.id,
                                         CloseDate=date.today() + 60, accountid=acct.id);
        
        insert op;
        
        
        // create GL Account needed by ledger
        AcctSeed__GL_Account__c gla = new AcctSeed__GL_Account__c();
        gla.name = '2010-Vouchers Payable';
        gla.AcctSeed__Type__c = 'Balance Sheet';
        gla.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gla.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gla.AcctSeed__Active__c = true;
        gla.AcctSeed__Bank__c = true;
        
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
        
        List<acctSeederp__sales_order__c> orders = new List<acctSeederp__sales_order__c>();
        
        acctSeederp__sales_order__c order = new acctseederp__sales_order__c(acctseederp__customer__c=acct.id, 
                                                                            price_level__c = null,
                                                                            stage__c='Clearance',
                                                                            acctseederp__ledger__c =ledger.id,
                                                                            acctseederp__opportunity__c=op.id,
                                                                           contact__c = contct1.id);
        
        orders.add(order);
        
        acctSeederp__sales_order__c order2 = new acctseederp__sales_order__c(acctseederp__customer__c=acct.id, 
                                                                            price_level__c = null,
                                                                             stage__c='Pre-Production',
                                                                            acctseederp__ledger__c =ledger.id,
                                                                            acctseederp__opportunity__c=op.id,
                                                                           contact__c = contct1.id);
        
        orders.add(order2);
        
        insert orders;
		
    }
    @isTest static void run_Test(){

    }
}
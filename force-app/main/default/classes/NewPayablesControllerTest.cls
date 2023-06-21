@isTest 
public class NewPayablesControllerTest 
{
    @TestSetup static void MakeData(){
        // create GL Account Variable 1 needed by account
        AcctSeed__Accounting_Variable__c glav = new AcctSeed__Accounting_Variable__c(
            Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1');
        
        insert glav;
        
        // Accounting Period
        Date dt = date.today();
        
        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        ap.name = dt.year() + '-' + ((dt.month() < 10)?'0' + dt.month():String.ValueOf(dt.month()));
        ap.AcctSeed__Start_Date__c = Date.today() - (dt.day() - 1);
        ap.AcctSeed__End_Date__c = Date.today() + 28;
        ap.AcctSeed__Status__c = 'Open';
        insert ap;
        
        // Create accounts
        
        Account acct = new Account(name='myAccount', AcctSeed__GL_Account_Variable_1__c=glav.id);
        
        insert acct;
        
        // Create Contacts
        
        List<Contact> contacts = new List<Contact>();
        
        Contact cont = new Contact(LastName='myContact1', LeadSource = 'AAOHA 2020');
        insert cont;

        
        // Create opportunities
        
        Opportunity op = new Opportunity(name='myOpportunity', price_level__c = null, stagename='Closed Won',
                                         contactperson__c = cont.id,
                                         CloseDate=date.today() + 60, accountid=acct.id,
                                        GL_Account_Variable_1__c=glav.id);
        
        insert op;
        
        
        // create GL Account needed by ledger
        AcctSeed__GL_Account__c gla = new AcctSeed__GL_Account__c();
        gla.name = '2010-Vouchers Payable';
        gla.AcctSeed__Type__c = 'Balance Sheet';
        gla.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gla.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gla.AcctSeed__Active__c = true;
        gla.AcctSeed__Bank__c = true;
        gla.GL_Account_Variable_1__c = glav.id;
        
        insert gla;
        
        AcctSeed__GL_Account__c gla2 = new AcctSeed__GL_Account__c();
        gla2.name = '2010-Vouchers Payable';
        gla2.AcctSeed__Type__c = 'Balance Sheet';
        gla2.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gla2.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gla2.AcctSeed__Active__c = true;
        gla.GL_Account_Variable_1__c = glav.id;
        
        insert gla2;
        
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
        
        
        
        // create product
        Product2 prod = new Product2();
        
        prod.Name = 'myProduct';
        prod.ProductCode = 'ABC123';
        prod.Description = 'myDescription';
        prod.AcctSeed__Unit_Cost__c = 100;
        prod.IsActive = true;
        prod.Category__c = 'Shower Door';
        prod.Sub_Category__c = 'Single Sliding';
        prod.AcctSeed__Inventory_Type__c = 'Purchased';
        prod.AcctSeed__Expense_GL_Account__c = gla.id;
        prod.AcctSeed__Inventory_GL_Account__c = gla.id;
        prod.AcctSeed__Revenue_GL_Account__c = gla.id;
        prod.AcctSeed__Inventory_Product__c = true;
        //prod.type__c = 'Product';

        insert prod;

        // get the standard price book id
        Id pricebookId = Test.getStandardPricebookId();
        
        // create standard price book entry
        PricebookEntry pricebentry = new PricebookEntry();
        
        pricebentry.Pricebook2Id = pricebookId;
  		pricebentry.Product2Id = prod.Id;
        pricebentry.UnitPrice = 100;
        pricebentry.IsActive = true;
        
        insert pricebentry;
        
        // create sales orders
        
        acctSeederp__sales_order__c order = new acctseederp__sales_order__c(acctseederp__customer__c=acct.id, 
                                                                            price_level__c = null,
                                                                            acctseederp__ledger__c =ledger.id,
                                                                            acctseederp__opportunity__c=op.id,
                                                                            contact__c = cont.id,
                                                                            GL_Account_Variable_1__c=glav.id);
        
        insert order;
        
        AcctSeedERP__Sales_Order_Line__c sol = new AcctSeedERP__Sales_Order_Line__c(); 
        
        sol.AcctSeedERP__Sales_Order__c = order.id;
        sol.AcctSeedERP__Unit_Price__c = 1.1;
        sol.AcctSeedERP_Description__c = 'This is salesorder line item';
        sol.AcctSeedERP__Product__c = prod.id;
        sol.AcctSeedERP__Quantity_Ordered__c = 2;
        
        insert sol;
        
        acctseederp__purchase_order__c po = new acctseederp__purchase_order__c();
        
        po.AcctSeedERP__Order_Date__c = date.today();
        po.AcctSeedERP__Status__c = 'Open';
        po.AcctSeedERP__Type__c = 'Drop Shipment';
        po.Stage__c = 'In Transit';
        po.AcctSeedERP__Purchase_Order_Format__c = format.Id;
        po.AcctSeedERP__Ledger__c = ledger.Id;
        po.GL_Account_Variable_1__c = glav.id;
        po.Sales_Order__c = order.id;
        po.AcctSeedERP__Vendor_Contact__c = cont.id;
        po.AcctSeedERP__Vendor__c = acct.id;
        
        insert po;
        
        acctseederp__purchase_order_line__c pol = new acctseederp__purchase_order_line__c();
        
        pol.AcctSeedERP__Product__c = prod.id;
        pol.AcctSeedERP__Quantity__c = 2;
        pol.AcctSeedERP__Purchase_Order__c = po.id;
        pol.AcctSeedERP__Unit_Price__c = 1;
        
        insert pol;
        
        AcctSeed__Account_Payable__c payable = new AcctSeed__Account_Payable__c();
        
        payable.AcctSeed__Accounting_Period__c = ap.id;  
        payable.AcctSeed__Date__c  = date.today();
        payable.AcctSeed__Due_Date__c = date.today() + 7;
        payable.AcctSeed__Status__c = 'Approved';
        payable.AcctSeed__Vendor__c = po.AcctSeedERP__Vendor__c;
        payable.AcctSeed__Ledger__c = po.AcctSeedERP__Ledger__c;
        payable.AcctSeedERP__Purchase_Order__c = po.id;
        payable.AcctSeed__Payee_Reference__c = po.Name + ' - ' + System.Now().formatLong(); 
            
        insert payable;

        AcctSeed__Account_Payable_Line__c payline = new AcctSeed__Account_Payable_Line__c();
                
        payline.AcctSeed__Account_Payable__c = payable.id;
        payline.AcctSeed__Amount__c = 1;
        payline.AcctSeed__Date__c = date.today();
        payline.AcctSeed__Expense_GL_Account__c = gla2.id;
        payline.AcctSeed__GL_Account_Variable_1__c = glav.id;
        payline.AcctSeed__Quantity__c = 1;
        payline.AcctSeedERP__Purchase_Order_Line__c = pol.id;
        payline.Item_description__c = 'Test Description.';
        
        insert payline;
    }

    @isTest static void runTests(){

        Opportunity opp = [select id from opportunity where name='myOpportunity' limit 1];

        AcctSeedERP__Sales_Order__c so = [select id from AcctSeedERP__Sales_Order__c where 
        AcctSeedERP__Opportunity__c =: opp.id Limit 1];

        AcctSeedERP__Purchase_Order__c po = [select id from AcctSeedERP__Purchase_Order__c where sales_order__c =: so.id Limit 1];

        AcctSeed__Account_Payable__c payable = [select id from AcctSeed__Account_Payable__c where 
        AcctSeedERP__Purchase_Order__c =: po.id Limit 1];

        Test.startTest();
        
        PageReference pageRef = Page.NewPayablesPage;
		Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('count', '1');
        ApexPages.currentPage().getParameters().put('id0', payable.id);
        
        NewPayablesController npoc = new NewPayablesController();
        
        Test.stopTest();

    }
}
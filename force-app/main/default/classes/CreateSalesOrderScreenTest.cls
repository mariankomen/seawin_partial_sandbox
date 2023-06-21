@isTest
public class CreateSalesOrderScreenTest {
    
    @testSetup static void createData(){
         
         // Create Custom setting
        
        Referral_Fee__c fee = new Referral_Fee__c(SetupOwnerId=UserInfo.getOrganizationId(),
                                                Percentage__c = 15
                                               );
         insert fee;
        
        // create GL Account Variable 1 needed by account
        AcctSeed__Accounting_Variable__c glav = new AcctSeed__Accounting_Variable__c(
            Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1');
        
        insert glav;
        
        // Create accounts
        
        Account acct = new Account(name='myAccount', AcctSeed__GL_Account_Variable_1__c=glav.id);
        
        insert acct;
         
        // create sales rep
        
         SAles_rep__c sales = new Sales_rep__c(name='sales rep', email__c='xyz@test.com', user__c = UserInfo.getUserId(),
                                              Price_Level_13_20__c = 4, Price_Level_1_12__c = 3, 
                                               Price_Level_21_26__c = 2, Price_Level_27_30__c = 1);
         
         insert sales;
        
        // Create Contacts
        
        List<Contact> contacts = new List<Contact>();
        
        Contact contct1 = new Contact(LastName='myContact1', LeadSource = 'AAOHA 2020', 
                                      GL_Account_Variable_1__c = glav.id);
        contacts.add(contct1);
        
        Contact contct2 = new Contact(LastName='myContact2', LeadSource = 'Customer Event', 
                                      GL_Account_Variable_1__c = glav.id);
        contacts.add(contct2);
        
        insert contacts;
        
        // Create opportunities
        
        Opportunity op = new Opportunity(name='myOpportunity', price_level__c = null, stagename='Closed Won',
                                         contactperson__c = contct1.id,sales_rep_o__c = sales.id,
                                         GL_Account_Variable_1__c = glav.id,
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
        gla.GL_Account_Variable_1__c = glav.id;
        
        insert gla;
        
        // create billing format need by ledger
        AcctSeed__Billing_Format__c format = new AcctSeed__Billing_Format__c();
        
        format.Name = 'myFormat';
        format.AcctSeed__Type__c = 'Sales Order'; // anything eligible would work here
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
        //prod.Type__c = 'Part';

        insert prod;
        
        Product2 kit = new Product2();
        
        kit.Name = 'myProduct';
        kit.ProductCode = 'ABC123';
        kit.Description = 'myDescription';
        kit.AcctSeed__Unit_Cost__c = 100;
        kit.IsActive = true;
        kit.Category__c = 'Shower Door';
        kit.Sub_Category__c = 'Single Sliding';
        kit.AcctSeed__Inventory_Type__c = 'Kit';
        kit.AcctSeed__Expense_GL_Account__c = gla.id;
        kit.AcctSeed__Inventory_GL_Account__c = gla.id;
        kit.AcctSeed__Revenue_GL_Account__c = gla.id;
        kit.AcctSeed__Inventory_Product__c = false;
        
        insert kit;

        // get the standard price book id
        Id pricebookId = Test.getStandardPricebookId();
        
        // create standard price book entry
        PricebookEntry pricebentry = new PricebookEntry();
        
        pricebentry.Pricebook2Id = pricebookId;
  		pricebentry.Product2Id = prod.Id;
        pricebentry.UnitPrice = 100;
        pricebentry.IsActive = true;
        
        insert pricebentry;
        
        opportunitylineitem oli = new opportunitylineitem();
        
        oli.Quantity = 2;
        oli.UnitPrice = 2;
        oli.Product2Id = prod.id;
        oli.PricebookEntryId = pricebentry.id;
        oli.OpportunityId = op.id;
        
        insert oli;
        
        opportunitylineitem oli2 = new opportunitylineitem();
        
        oli2.Quantity = 2;
        oli2.UnitPrice = 2;
        oli2.Product2Id = kit.id;
        oli2.PricebookEntryId = pricebentry.id;
        oli2.OpportunityId = op.id;
        
        insert oli2;
        
        AcctSeed__Product_Part__c part = new AcctSeed__Product_Part__c();
        
        part.AcctSeed__Quantity__c = 1;
        part.Kit_Children__c = prod.id;
        part.Kit_Product__c = kit.id;
        
        insert part;

		
    }
    
    @isTest static void CreateSO() {
        
        String fields = AllFields.Fields('Opportunity', new list<String>{'ContactId'});
        
        Opportunity opp = Database.query('SELECT ' + fields + 
                                         ' FROM Opportunity where name=\'myOpportunity\' Limit 1'); 
        
        opportunitylineitem lineitem = [select PricebookEntryId, OpportunityId, Product2Id, Quantity, UnitPrice,
                                                                  Item_Description__c,Size__c,
                                        AcctSeed__GL_Account_Variable_2__c,AcctSeed__GL_Account_Variable_3__c,
                                        AcctSeed__GL_Account_Variable_4__c
                                        from opportunitylineitem where
                                        opportunityid =:opp.id limit 1];
        CreateSalesOrderScreenExtension.childrenWrapper wrapp = new CreateSalesOrderScreenExtension.childrenWrapper(lineitem.id, lineitem.id, 4);
        
        AcctSeed__Ledger__c ledger = [select id from AcctSeed__Ledger__c where name='myLedger' limit 1];

         // create the linewrapper list
        createSalesOrderScreenExtension.LinesWrapper linw = 
            new createSalesOrderScreenExtension.LinesWrapper(lineitem, true);
        //linw.quantity = 7;
        
        list<createSalesOrderScreenExtension.LinesWrapper> linewlist = 
            new list<createSalesOrderScreenExtension.LinesWrapper>{linw};
          

        test.startTest(); 

        // Instantiate the standard controller
        PageReference pageRef = Page.createSalesOrderScreenPage;
        Test.setCurrentPage(pageRef);

        // For Non empty scenario
        
        // put the lead id as a parameter
        ApexPages.currentPage().getParameters().put('id',opp.id);
        Apexpages.StandardController sc = new Apexpages.standardController(opp);

        // Instantiate the extension
        createSalesOrderScreenExtension ext = new createSalesOrderScreenExtension(sc);
        
         
        ext.linesList = linewlist;
        
        system.assert(ext.linesList != null);
        
        ext.TryCreate();
        ext.handleQuantity();
        
        ext.showError = false;
        system.assert(ext.showError != null);
        
        ext.getLedgerList();
        ext.selectedledger = ledger.id;
        
        system.assert(ext.selectedledger != null);
        
        ext.create();
        ext.back();
        
        system.assert(ext.ChinaRecordTypeId == null);
        system.assert(ext.USArecordTypeId == null);
        system.assert(ext.validKeys == null);
        system.assert(ext.hasSalesOrder == null);
       
        test.stopTest();
    }
}
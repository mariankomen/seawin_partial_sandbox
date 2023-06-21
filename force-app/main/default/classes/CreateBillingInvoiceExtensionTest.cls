@isTest
public class CreateBillingInvoiceExtensionTest {
    
    @TestSetup
  static void MakeData() {
    AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
    accVar.Name = 'GL acc var1';
    accVar.AcctSeed__Type__c = 'GL Account Variable 1';
    insert accVar;

    list<AcctSeed__GL_Account__c> glList = new List<AcctSeed__GL_Account__c>();

    AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();

    gl.name = 'GL Account First';
    gl.AcctSeed__type__c = 'Balance Sheet';
    gl.AcctSeed__Sub_Type_1__c = 'Liabilities';
    gl.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
    gl.AcctSeed__Active__c = true;
    gl.GL_Account_Variable_1__c = accVar.Id;

    glList.add(gl);

    // ledger creation
    AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
    aegl.name = 'glaccount';
    aegl.AcctSeed__Type__c = 'Expense';
    aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
    aegl.AcctSeed__Sub_Type_2__c = 'Rent';
    aegl.AcctSeed__Bank__c = true;
    aegl.GL_Account_Variable_1__c = accVar.Id;

    glList.add(aegl);
	
    insert glList;

    // Accounting Period
    Date dt = date.today();

    AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
    ap.name =
      dt.year() +
      '-' +
      ((dt.month() < 10) ? '0' + dt.month() : String.ValueOf(dt.month()));
    ap.AcctSeed__Start_Date__c = Date.today() - (dt.day() - 1);
    ap.AcctSeed__End_Date__c = Date.today() + 28;
    ap.AcctSeed__Status__c = 'Open';
    insert ap;

    // create account
    Account acct = new Account();
    //acct.Sales_Rep_O__c = sr.id;
    acct.Name = 'myAccount';
    acct.Type = 'Designer';
    acct.AcctSeed__Accounting_Type__c = 'Customer';
    acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
    insert acct;

    // create account
    Account acct2 = new Account();
    acct2.Name = 'Manufacturer Representative';
    acct2.Type = 'Designer';
    acct2.AcctSeed__Accounting_Type__c = 'Manufacturer Representative';
    acct2.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
    acct2.Price_Level_1_12__c = 1;
    acct2.Price_Level_13_20__c = 1;
    acct2.Price_Level_21_26__c = 1;
    acct2.Price_Level_27_30__c = 1;

    insert acct2;

    // create contact
    Contact cont = new Contact();
    cont.LastName = 'myLastName';
    cont.AccountId = acct.Id;
    cont.LeadSource = 'AAOHA 2020';
    cont.GL_Account_Variable_1__c = accVar.Id;
    insert cont;

    AcctSeed__GL_Account__c glAccount2 = new AcctSeed__GL_Account__c();
    glAccount2.name = 'glaccount';
    glAccount2.AcctSeed__Type__c = 'Expense';
    glAccount2.AcctSeed__Sub_Type_1__c = 'Facilities';
    glAccount2.AcctSeed__Sub_Type_2__c = 'Rent';
    glAccount2.AcctSeed__Bank__c = false;
    glAccount2.GL_Account_Variable_1__c = accVar.Id;
    insert glAccount2;

    // create product
    Product2 prod = new Product2();
    prod.Name = 'myProduct';
    prod.ProductCode = 'ABC123';
    prod.AcctSeed__Unit_Cost__c = 100;
    prod.IsActive = true;
    prod.AcctSeed__Inventory_Type__c = 'Purchased';
    prod.AcctSeed__Expense_GL_Account__c = aegl.id;
    prod.AcctSeed__Inventory_GL_Account__c = aegl.id;
    prod.AcctSeed__Revenue_GL_Account__c = aegl.id;

    insert prod;

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

    // insert to standard price book
    Id pricebookId = Test.getStandardPricebookId();

    // create standard price book entry
    PricebookEntry pricebentry = new PricebookEntry();

    pricebentry.Pricebook2Id = pricebookId;
    pricebentry.Product2Id = prod.Id;
    pricebentry.UnitPrice = 100;
    pricebentry.IsActive = true;

    insert pricebentry;

    // create opportunity line item

    OpportunityLineItem oli = new OpportunityLineItem();

    oli.OpportunityId = opp.Id;
    oli.Product2Id = prod.Id;
    oli.PricebookEntryId = pricebentry.Id;
    oli.Quantity = 10;
    oli.UnitPrice = 100;
    oli.Description = 'myDescription';

    insert oli;

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
    ledger.AcctSeed__Default_Bank_Account__c = aegl.id;
    ledger.AcctSeed__Default_Billing_Format__c = abf.id;
    ledger.AcctSeed__Default_Purchase_Order_Format__c = abf.id;
    ledger.AcctSeed__Default_Packing_Slip_Format__c = abf.id;

    insert ledger;

    Id RecordTypeIdSO = Schema.SObjectType.AcctSeedERP__Sales_Order__c.getRecordTypeInfosByName()
      .get('Seawin USA Hospitality')
      .getRecordTypeId();

    // create a sales order
    AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c();

    //salesorder.name = 'testSalesOrder';
    salesorder.RecordTypeId = RecordTypeIdSO;
    salesorder.AcctSeedERP__Customer__c = acct.Id;
    salesorder.AcctSeedERP__Opportunity__c = opp.Id;
    salesorder.Manufacturer_Rep__c = acct2.id;
    salesorder.Contact__c = cont.Id;
    salesorder.Price_Level__c = 'Level 3';
    salesorder.AcctSeedERP__Status__c = 'Open';
    salesorder.AcctSeedERP__Ledger__c = ledger.id;
    salesorder.GL_Account_Variable_1__c = accVar.Id;
    salesorder.Commission_Rate_Sales_Rep__c = 1;
    salesorder.Commission_Rate_Referral_Sales_Rep__c = 1;
    salesorder.Commission_Rate_Manufacturer_Rep__c = 1;
    insert salesorder;

    // create a sales order
    AcctSeedERP__Sales_Order_Line__c soline = new AcctSeedERP__Sales_Order_Line__c();

    soline.AcctSeedERP__Sales_Order__c = salesorder.id;
    soline.AcctSeedERP__Unit_Price__c = 100;
    soline.AcctSeedERP_Description__c = 'This is salesorder line item';
    soline.AcctSeedERP__Product__c = prod.id;
    soline.AcctSeedERP__Quantity_Ordered__c = 1;

    insert soline;

    // Billing

    AcctSeed__Billing__c bill = new AcctSeed__Billing__c();

    bill.AcctSeed__Status__c = 'Approved';
    bill.AcctSeed__PDF_Email_Status__c = 'Unsent';
    bill.AcctSeed__Billing_Format__c = abf.id;
    bill.AcctSeedERP__Sales_Order__c = salesorder.id;
    bill.AcctSeed__Date__c = Date.Today();
    bill.AcctSeed__Due_Date2__c = Date.Today();
    bill.AcctSeed__Ledger__c = salesorder.AcctSeedERP__Ledger__c;
    bill.AcctSeed__Opportunity__c = salesorder.AcctSeedERP__Opportunity__c;
    bill.AcctSeed__Customer__c = salesorder.AcctSeedERP__Customer__c;
    bill.AcctSeed__Accounting_Period__c = ap.id;

    insert bill;
  }
    
    @isTest static void BillingProcess(){
        Opportunity opp = [select id from opportunity where name='myOpportunity' limit 1];
        
        acctseederp__sales_order__c so = [select id from acctseederp__sales_order__c 
                                          where acctseederp__opportunity__c =:opp.id limit 1];
        
        // get the sales order lines list
        list<acctseederp__sales_order_line__c> solinelist = new list<acctseederp__sales_order_line__c>([SELECT Id, Name, AcctSeedERP__Sales_Order__c,
                                                        AcctSeedERP__Product__r.Name,
                                                        Item_Description__c,
                                                        AcctSeedERP__Comment__c, AcctSeedERP__GL_Account_Variable_1__c, 
                                                        AcctSeedERP__GL_Account_Variable_2__c, 
                                                        AcctSeedERP__GL_Account_Variable_3__c, 
                                                        AcctSeedERP__GL_Account_Variable_4__c, 
                                                        AcctSeedERP__Opportunity_Product_Id__c, 
                                                        AcctSeedERP__Product__c, 
                                                        AcctSeedERP__Purchase_Order_Line__c, 
                                                        AcctSeedERP__Quantity_Manufactured__c, 
                                                        AcctSeedERP__Quantity_Needed__c, 
                                                        AcctSeedERP__Quantity_Ordered_Manufacturing__c, 
                                                        AcctSeedERP__Quantity_Ordered_Supplier__c, 
                                                        AcctSeedERP__Quantity_Ordered__c, 
                                                        AcctSeedERP__Quantity_Received_Supplier__c, 
                                                        AcctSeedERP__Total__c, AcctSeedERP__Unit_Price__c, 
                                                        AcctSeedERP__Quantity_Allocated__c, 
                                                        AcctSeedERP__Quantity_Shipped__c, 
                                                        AcctSeedERP_Description__c, Size__c, 
                                                        SortOrder__c, ProductCode__c, IsAllocated__c, 
                                                        QuantityFormula__c, Quantity_Allocated_Formula__c, 
                                                        Quantity_Shipped_Formula__c, Total_Price__c, 
                                                        Sales_Price__c, Quantity_Needed_Formula__c, 
                                                        CreatedDate FROM AcctSeedERP__Sales_Order_Line__c where 
                                                        AcctSeedERP__Sales_Order__c =: so.id]);
        
        PageReference pageRef = Page.CreateBillingInvoicePage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdset = new ApexPages.StandardController(so);
        
        CreateBillingInvoiceExtension cbf = new CreateBillingInvoiceExtension(stdset);
        
        system.assert(cbf.billType == null);
        system.assert(cbf.Amount != null);

        CreateBillingInvoiceExtension.Wrapper w = 
            new CreateBillingInvoiceExtension.Wrapper(solinelist[0], 0, 0, 0, 1, 0);
        list<CreateBillingInvoiceExtension.Wrapper> wlist = 
            new list<CreateBillingInvoiceExtension.Wrapper>{w};
        cbf.solWrapper = wlist;
        
        cbf.createBilling();
        
       	system.assert(cbf.solWrapper.size() > 0);
        
        
    }
    @isTest static void BillingProcessWithOtherCustomer(){
        Opportunity opp = [select id from opportunity where name='myOpportunity' limit 1];
        
        acctseederp__sales_order__c so = [select id from acctseederp__sales_order__c 
                                          where acctseederp__opportunity__c =:opp.id limit 1];
        
       	Account acct = new Account(name = 'newAccount');
        
        insert acct;
        
        Contact ct = new Contact(lastname = 'newContact');
        
        insert ct;
        
        so.Shipping_Account__c = acct.id;
		so.Shipping_Name__c = ct.id;

		update so;        
        // get the sales order lines list
        list<acctseederp__sales_order_line__c> solinelist = new list<acctseederp__sales_order_line__c>([SELECT Id, Name, AcctSeedERP__Sales_Order__c,
                                                        AcctSeedERP__Product__r.Name,
                                                        Item_Description__c,
                                                        AcctSeedERP__Comment__c, AcctSeedERP__GL_Account_Variable_1__c, 
                                                        AcctSeedERP__GL_Account_Variable_2__c, 
                                                        AcctSeedERP__GL_Account_Variable_3__c, 
                                                        AcctSeedERP__GL_Account_Variable_4__c, 
                                                        AcctSeedERP__Opportunity_Product_Id__c, 
                                                        AcctSeedERP__Product__c, 
                                                        AcctSeedERP__Purchase_Order_Line__c, 
                                                        AcctSeedERP__Quantity_Manufactured__c, 
                                                        AcctSeedERP__Quantity_Needed__c, 
                                                        AcctSeedERP__Quantity_Ordered_Manufacturing__c, 
                                                        AcctSeedERP__Quantity_Ordered_Supplier__c, 
                                                        AcctSeedERP__Quantity_Ordered__c, 
                                                        AcctSeedERP__Quantity_Received_Supplier__c, 
                                                        AcctSeedERP__Total__c, AcctSeedERP__Unit_Price__c, 
                                                        AcctSeedERP__Quantity_Allocated__c, 
                                                        AcctSeedERP__Quantity_Shipped__c, 
                                                        AcctSeedERP_Description__c, Size__c, 
                                                        SortOrder__c, ProductCode__c, IsAllocated__c, 
                                                        QuantityFormula__c, Quantity_Allocated_Formula__c, 
                                                        Quantity_Shipped_Formula__c, Total_Price__c, 
                                                        Sales_Price__c, Quantity_Needed_Formula__c, 
                                                        CreatedDate FROM AcctSeedERP__Sales_Order_Line__c where 
                                                        AcctSeedERP__Sales_Order__c =: so.id]);
        
        PageReference pageRef = Page.CreateBillingInvoicePage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdset = new ApexPages.StandardController(so);
        
        CreateBillingInvoiceExtension cbf = new CreateBillingInvoiceExtension(stdset);
        
        system.assert(cbf.billType == null);
        system.assert(cbf.Amount != null);

        CreateBillingInvoiceExtension.Wrapper w = 
            new CreateBillingInvoiceExtension.Wrapper(solinelist[0], 0, 0, 0, 1, 0);
        list<CreateBillingInvoiceExtension.Wrapper> wlist = 
            new list<CreateBillingInvoiceExtension.Wrapper>{w};
        cbf.solWrapper = wlist;
        
        cbf.createBilling();
        
       	system.assert(cbf.solWrapper.size() > 0);
        
        
    }
}
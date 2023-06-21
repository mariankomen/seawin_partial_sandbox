@IsTest
public with sharing class OpportunityHelperTest {
    
    @TestSetup
    static void makeData(){
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'Seawin USA';
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
        
        AcctSeed__GL_Account__c vch = new AcctSeed__GL_Account__c();
        vch.name = '2010-Vouchers Payable';
        vch.AcctSeed__Type__c = 'Balance Sheet';
        vch.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch.AcctSeed__Active__c = true;
        vch.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(vch);
        
        AcctSeed__GL_Account__c vch1 = new AcctSeed__GL_Account__c();
        vch1.name = '2010-Vouchers Payable1';
        vch1.AcctSeed__Type__c = 'Balance Sheet';
        vch1.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch1.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch1.AcctSeed__Active__c = true;
        vch1.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(vch1);
        
        AcctSeed__GL_Account__c vch2 = new AcctSeed__GL_Account__c();
        vch2.name = '2010-Vouchers Payable2';
        vch2.AcctSeed__Type__c = 'Balance Sheet';
        vch2.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch2.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch2.AcctSeed__Active__c = true;
        vch2.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(vch2);
        
        AcctSeed__GL_Account__c vch3 = new AcctSeed__GL_Account__c();
        vch3.name = '2010-Vouchers Payable3';
        vch3.AcctSeed__Type__c = 'Balance Sheet';
        vch3.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch3.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch3.AcctSeed__Active__c = true;
        vch3.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(vch3);
        
        AcctSeed__GL_Account__c gl1 = new AcctSeed__GL_Account__c();
        gl1.name = '2010-Vouchers Payable1';
        gl1.AcctSeed__Type__c = 'Balance Sheet';
        gl1.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl1.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl1.AcctSeed__Active__c = true;
        gl1.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(gl1);
        
        AcctSeed__GL_Account__c gl2 = new AcctSeed__GL_Account__c();
        gl2.name = '2010-Vouchers Payable2';
        gl2.AcctSeed__Type__c = 'Balance Sheet';
        gl2.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl2.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl2.AcctSeed__Active__c = true;
        gl2.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(gl2);
        
        AcctSeed__GL_Account__c gl3 = new AcctSeed__GL_Account__c();
        gl3.name = '2010-Vouchers Payable3';
        gl3.AcctSeed__Type__c = 'Balance Sheet';
        gl3.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl3.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl3.AcctSeed__Active__c = true;
        gl3.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(gl3);
        
        AcctSeed__GL_Account__c gl4 = new AcctSeed__GL_Account__c();
        gl4.name = '2010-Vouchers Payable4';
        gl4.AcctSeed__Type__c = 'Balance Sheet';
        gl4.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl4.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl4.AcctSeed__Active__c = true;
        gl4.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(gl4);
        
        insert glList;

        AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();

        abf.Name = 'newPDF Format';
        abf.AcctSeed__Type__c = 'Purchase Order';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';

        insert abf;
        AcctSeed__Billing_Format__c bil_f = new AcctSeed__Billing_Format__c();

        bil_f.Name = 'newPDF Format';
        bil_f.AcctSeed__Type__c = 'Billing';
        bil_f.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        bil_f.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';

        insert bil_f;

        

        // ledger creation
        

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
        acct.AcctSeed__Billing_Format__c = bil_f.Id;
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct;

        // create account
        Account acct2 = new Account();
        acct2.Name = 'Sales Represantative';
        acct2.Type = 'Designer';
        acct2.AcctSeed__Accounting_Type__c = 'Sales Represantative';
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
        prod.AcctSeed__Inventory_Product__c = true;

        insert prod;

        Acctseed__project__c p = new Acctseed__project__c();    
        p.name = 'myProject2';
        p.AcctSeed__Account__c = acct.id;
        p.AcctSeed__Status__c = 'Closed';
        insert p;
        
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
        opp.Project__c = p.Id;
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

        AcctSeed__GL_Account__c expense = new AcctSeed__GL_Account__c();
        expense.Name = 'Expense GL Account';
        expense.AcctSeed__Active__c = true;
        expense.AcctSeed__Type__c = 'Expense';
        expense.AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold';
        expense.AcctSeed__Sub_Type_2__c = 'Materials';
        expense.GL_Account_Variable_1__c = accVar.Id;
        
        insert expense;

        AcctSeed__GL_Account__c inventory = new AcctSeed__GL_Account__c();
        inventory.Name = 'Inventory GL Account';
        inventory.AcctSeed__Active__c = true;
        inventory.AcctSeed__Type__c = 'Balance Sheet';
        inventory.AcctSeed__Sub_Type_1__c = 'Assets';
        inventory.AcctSeed__Sub_Type_2__c = 'Current Assets';
        inventory.GL_Account_Variable_1__c = accVar.Id;
        
        insert inventory;
        
        AcctSeed__GL_Account__c revenue = new AcctSeed__GL_Account__c();
        revenue.Name = 'Revenue GL Account';
        revenue.AcctSeed__Active__c = true;
        revenue.AcctSeed__Type__c = 'Revenue';
        revenue.AcctSeed__Sub_Type_1__c = 'Product Revenue';
        revenue.AcctSeed__Sub_Type_2__c = null;
        revenue.GL_Account_Variable_1__c = accVar.Id;
        
        insert revenue;
        

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

        Credit_Order__c co = new Credit_Order__c();
        co.Sales_Order__c = salesorder.Id;
        co.Customer__c = acct.Id;
        co.Ledger__c = ledger.Id;
        insert co;

        Credit_Order_Line__c col = new Credit_Order_Line__c();
        col.Credit_Order__c = co.Id;
        col.Sales_Order_Line__c = soline.Id;
        col.Quantity_Ordered__c = 50;
        col.Unit_Price__c = 35;
        col.Sales_Order__c = salesorder.Id;
        insert col;



        AcctSeed__Billing__c billin = new AcctSeed__Billing__c();
        
        billin.AcctSeed__Status__c = 'Approved';
        billin.AcctSeed__PDF_Email_Status__c = 'Unsent';
        billin.AcctSeed__Billing_Format__c = abf.id;
        billin.AcctSeed__Date__c = Date.Today();
        billin.AcctSeed__Due_Date2__c = Date.Today();
        billin.AcctSeed__Ledger__c = co.Ledger__c;
        billin.AcctSeed__Customer__c = co.Customer__c;
        billin.AcctSeed__Accounting_Period__c = ap.id;
        billin.Credit_Order__c = co.Id;
        insert billin;

        AcctSeed__Billing_Line__c bline = new AcctSeed__Billing_Line__c();
        bline.AcctSeed__Billing__c = billin.id;
        bline.AcctSeed__Date__c = date.today();
        bline.AcctSeed__Hours_Units__c = 1;
        bline.AcctSeed__Product__c = col.Product__c;
        bline.AcctSeedERP__Sales_Order_Line__c = col.Sales_Order_Line__c;
        bline.AcctSeed__Rate__c = 0;
        bline.Item_Description__c = col.Description__c;
        bline.AcctSeed__Expense_GL_Account__c = expense.id;
        bline.AcctSeed__Inventory_GL_Account__c = inventory.id;
        bline.AcctSeed__Revenue_GL_Account__c = revenue.id;
        bline.Credit_Order_Line__c = col.Id;
        bline.AcctSeed__Opportunity_Product_Id__c = oli.Id;
        insert bline;
    }

    @isTest
    public static void beforeInsertTest(){
        Map<String, Schema.SObjectField> fieldMap = Opportunity.sObjectType.getDescribe().fields.getMap();
          
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
                
        // Dynamic Query String.
        List<Opportunity> lstOpportunity = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM Opportunity');
        OpportunityHelper.beforeInsert(lstOpportunity);

    }

    @isTest
    public static void afterInsertTest(){
        Map<String, Schema.SObjectField> fieldMap = Opportunity.sObjectType.getDescribe().fields.getMap();
          
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
                
        // Dynamic Query String.
        List<Opportunity> lstOpportunity = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ', RecordType.Name FROM Opportunity');
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>(lstOpportunity);
        OpportunityHelper.afterInsert(lstOpportunity, mapOpportunity);

    }

    @isTest
    public static void beforeUpdateTest(){
        Map<String, Schema.SObjectField> fieldMap = Opportunity.sObjectType.getDescribe().fields.getMap();
          
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
                
        // Dynamic Query String.
        List<Opportunity> lstOpportunity = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ', RecordType.Name FROM Opportunity');
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>(lstOpportunity);
        OpportunityHelper.beforeUpdate(lstOpportunity, mapOpportunity,lstOpportunity, mapOpportunity);

    }
    @isTest
    public static void afterUpdateTest(){
        Map<String, Schema.SObjectField> fieldMap = Opportunity.sObjectType.getDescribe().fields.getMap();
          
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
                
        // Dynamic Query String.
        List<Opportunity> lstOpportunity = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ', RecordType.Name FROM Opportunity');
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>(lstOpportunity);
        OpportunityHelper.afterUpdate(lstOpportunity, mapOpportunity,lstOpportunity, mapOpportunity);

    }
    @isTest
    public static void beforeDeleteTest(){
        Map<String, Schema.SObjectField> fieldMap = Opportunity.sObjectType.getDescribe().fields.getMap();
          
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
                
        // Dynamic Query String.
        List<Opportunity> lstOpportunity = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ', RecordType.Name FROM Opportunity');
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>(lstOpportunity);
        OpportunityHelper.beforeDelete(lstOpportunity, mapOpportunity);

    }
    @isTest
    public static void afterDeleteTest(){
        Map<String, Schema.SObjectField> fieldMap = Opportunity.sObjectType.getDescribe().fields.getMap();
          
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
                
        // Dynamic Query String.
        List<Opportunity> lstOpportunity = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ', RecordType.Name FROM Opportunity');
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>(lstOpportunity);
        OpportunityHelper.afterDelete(lstOpportunity, mapOpportunity);

    }



    @isTest
    public static void coverage(){
        OpportunityHelper.coverage();
    }
}
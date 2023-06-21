@isTest
public class SalesOrderPDFControllerTest {
    
    @TestSetup
    static void MakeData() {
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
        
        // Accounting Period
        Date dt = date.today();
        
        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        ap.name =
            dt.year() +
            '-' +
            ((dt.month() < 10) ? '0' + dt.month() : String.ValueOf(dt.month()));
        system.debug(
            dt.year() +
            '-' +
            ((dt.month() < 9) ? Integer.ValueOf('0' + dt.month()) : dt.month())
        );
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
        
        Sales_Rep__c sr = new Sales_Rep__c();
        
        sr.name = 'Test Team';
        sr.Email__c = 'team@test.com';
        sr.Team__c = UserInfo.getUserId();
        sr.Price_Level_1_12__c = 1;
        sr.Price_Level_13_20__c = 1;
        sr.Price_Level_21_26__c = 1;
        sr.Price_Level_27_30__c = 1;
        sr.Man_Rep_Price_Level_1_12__c = 1;
        sr.Man_Rep_Price_Level_13_20__c = 1;
        sr.Man_Rep_Price_Level_21_26__c = 1;
        sr.Man_Rep_Price_Level_27_30__c = 1;
        sr.GL_Account_Variable_to_Sales_Rep__c = accVar.Id;
        
        insert sr;
        
        // create account
        Account acct2 = new Account();
        acct2.Name = 'Sales Representative';
        acct2.Sales_Rep_O__c = sr.id;
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
        prod.Commissionable_Product__c = true;
        
        insert prod;
        
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
        Test.startTest();
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
        salesorder.Referral_Sales_Rep__c = UserInfo.getUserId();
        salesorder.Sales_Rep_O__c = sr.id;
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
        
        // GL Account
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
        
        AcctSeed__Accounting_Settings__c custm = new AcctSeed__Accounting_Settings__c();
        
        custm.AcctSeed__Vouchers_Payable_GL_Account__c = glList[3].id;
        custm.AcctSeed__AP_Control_GL_Account__c = glList[6].id;
        custm.AcctSeed__AR_Control_GL_Account__c = glList[4].id;
        custm.AcctSeed__Current_Year_Earnings_GL_Account__c = glList[7].id;
        custm.AcctSeed__Default_Ledger__c = ledger.id;
        custm.AcctSeed__Retained_Earnings_GL_Account__c = glList[8].id;
        custm.AcctSeed__Revenue_GL_Account__c = glList[5].id;
        custm.AcctSeed__Unapplied_Cash_GL_Account__c = glList[9].id;
        
        insert custm;
        
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
        
        AcctSeed__Billing_Line__c bline = new AcctSeed__Billing_Line__c();
        bline.AcctSeed__Billing__c = bill.id;
        bline.AcctSeed__Date__c = date.today();
        bline.AcctSeed__Hours_Units__c = 1;
        bline.AcctSeed__Product__c = soline.AcctSeedERP__Product__c;
        bline.AcctSeedERP__Sales_Order_Line__c = soline.id;
        bline.AcctSeed__Rate__c = soline.AcctSeedERP__Unit_Price__c;
        bline.Item_Description__c = soline.Item_Description__c;
        bline.AcctSeed__Expense_GL_Account__c = expense.id;
        bline.AcctSeed__Inventory_GL_Account__c = inventory.id;
        bline.AcctSeed__Revenue_GL_Account__c = revenue.id;
        
        insert bline;
        
        AcctSeed__Cash_Receipt__c cr = new AcctSeed__Cash_Receipt__c();
        
        cr.AcctSeed__Receipt_Date__c = Date.today();
        cr.AcctSeed__Account__c = acct.id;
        cr.AcctSeed__Amount__c = 30;
        cr.AcctSeed__Payment_Reference__c = 'Reference Test';
        cr.AcctSeed__GL_Account_Variable_1__c = accVar.id;
        
        insert cr;
        
        AcctSeed__Billing_Cash_Receipt__c br = new AcctSeed__Billing_Cash_Receipt__c();
        
        br.AcctSeed__Applied_Amount__c = 30;
        br.AcctSeed__Billing__c = bill.id;
        br.AcctSeed__Cash_Receipt__c = cr.id;
        //br.AcctSeed__Period_Applied__c = ap.id;
        
        insert br;
        
        // credit memo
        
        AcctSeed__Billing__c bill2 = new AcctSeed__Billing__c();
        
        bill2.AcctSeed__Status__c = 'Approved';
        bill2.AcctSeed__PDF_Email_Status__c = 'Unsent';
        bill2.AcctSeed__Billing_Format__c = abf.id;
        bill2.AcctSeedERP__Sales_Order__c = salesorder.id;
        bill2.AcctSeed__Date__c = Date.Today();
        bill2.AcctSeed__Due_Date2__c = Date.Today();
        bill2.AcctSeed__Ledger__c = salesorder.AcctSeedERP__Ledger__c;
        bill2.AcctSeed__Opportunity__c = salesorder.AcctSeedERP__Opportunity__c;
        bill2.AcctSeed__Customer__c = salesorder.AcctSeedERP__Customer__c;
        bill2.AcctSeed__Accounting_Period__c = ap.id;
        
        insert bill2;
        
        AcctSeed__Billing_Line__c bline2 = new AcctSeed__Billing_Line__c();
        bline2.AcctSeed__Billing__c = bill2.id;
        bline2.AcctSeed__Date__c = date.today();
        bline2.AcctSeed__Hours_Units__c = 1;
        bline2.AcctSeed__Product__c = soline.AcctSeedERP__Product__c;
        bline2.AcctSeedERP__Sales_Order_Line__c = soline.id;
        bline2.AcctSeed__Rate__c = -25;
        bline2.Item_Description__c = soline.Item_Description__c;
        bline2.AcctSeed__Expense_GL_Account__c = expense.id;
        bline2.AcctSeed__Inventory_GL_Account__c = inventory.id;
        bline2.AcctSeed__Revenue_GL_Account__c = revenue.id;
        
        insert bline2;
        
        AcctSeed__Billing_Credit_Memo__c memo = new AcctSeed__Billing_Credit_Memo__c();
        
        memo.AcctSeed__Applied_Date__c = Date.today();
        memo.AcctSeed__Billing_Invoice__c = bill.id;
        memo.AcctSeed__Billing_Credit_Memo__c = bill2.id;
        //memo.AcctSeed__Applied_Date__c = ap.id;
        memo.AcctSeed__Accounting_Period__c = ap.id;
        memo.AcctSeed__Amount__c = -25;
        
        insert memo;
        Test.stopTest();
    }
    
    @isTest static void SalesOrderController(){
        acctseederp__sales_order__c so = [select id,contact__c,acctseederp__customer__c, 
                                          Sales_Order_Format__r.AcctSeed__Default_Email_Template__c  
                                          from acctseederp__sales_order__c limit 1];
 
        
        Test.startTest();
        
        PageReference pageRef = Page.SalesOrderPDFInvoice;
        Test.setCurrentPage(pageRef);
		
        ApexPages.currentPage().getParameters().put('id', so.id);
        
        SalesOrderPDFController sls = new SalesOrderPDFController();
        sls.getImageURL('<img src="test"/>');
        Test.stopTest();
        

    }
}
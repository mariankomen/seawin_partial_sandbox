@isTest
public class SalesDashboardControllerTest {

    @TestSetup static void createData(){
        
        Date d = Date.today();
        
        list<AcctSeed__Accounting_Variable__c> avList = new list<AcctSeed__Accounting_Variable__c>();
        
    	avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin China',AcctSeed__Type__c = 'GL Account Variable 1'));
        
        avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1'));
        insert avList;
        
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
        
        Id RecordTypeIdSO = Schema.SObjectType.AcctSeedERP__Sales_Order__c.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();

        List<Lead> leads = new List<Lead>();
        
        leads.add(new Lead(LastName='myLead', Company='myCompany', Status='New', LeadSource='AAOHA 2020'));
        leads.add(new Lead(LastName='myLead1', Company='myCompany1', Status='New', LeadSource='AAOHA 2019'));
        leads.add(new Lead(LastName='myLead2', Company='myCompany2', Status='New', LeadSource='AAOHA 2020'));
        leads.add(new Lead(LastName='myLead3', Company='myCompany3', Status='New', LeadSource='AAOHA 2021'));
        leads.add(new Lead(LastName='myLead4', Company='myCompany4', Status='New',LeadSource='AAOHA 2021'));
        leads.add(new Lead(LastName='myLead5', Company='myCompany5', Status='New',LeadSource='Alibaba Marketing'));
        
        insert leads;
        
        Test.setCreatedDate(leads[0].id, Date.newInstance(d.year()-1, d.month(), d.day()));
        Test.setCreatedDate(leads[1].id, Date.newInstance(d.year()-1, d.month(), d.day()));
        Test.setCreatedDate(leads[2].id, Date.newInstance(d.year()-1, d.month(), d.day()));
        
        // Accounting Period

        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        
        Integer year = d.year();
        String month = d.month() > 9 ? '' + d.month() : '0' + d.month();

        ap.Name = year + '-' + month;
        ap.AcctSeed__Start_Date__c = Date.NewInstance(year, d.month(), 1);
        ap.AcctSeed__End_Date__c = Date.NewInstance(year, d.month(), Date.DaysInMonth(year, d.month()));
        ap.AcctSeed__Status__c = 'Open';
            
        insert ap;
        
    	// create account
    	list<Account> acctList = new list<Account>();

        Account acct = new Account();
        
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__Billing_Terms_Name__c = 'Example terms';
        acct.AcctSeed__GL_Account_Variable_1__c = avList[1].id;
        
        acctList.add(acct);
        
        Account acct2 = new Account();
        
        acct2.Name = 'myAccount2';
        acct2.Type = 'Customer';
        acct2.AcctSeed__GL_Account_Variable_1__c = avList[0].id;
        
        acctList.add(acct2);
        
        Account accto = new Account();
        
        accto.Name = 'myAccount';
        accto.Type = 'Customer';
        accto.AcctSeed__Billing_Terms_Name__c = 'Example terms';
        accto.AcctSeed__GL_Account_Variable_1__c = avList[1].id;
        accto.Industry = 'Hospitality';
        
        acctList.add(accto);
        
        insert acctList;
        Test.setCreatedDate(accto.id, Date.newInstance(d.year()-1, d.month(), d.day()));
        Test.setCreatedDate(acct2.id, Date.newInstance(d.year()-1, d.month(), d.day()));
		
        // create contact
        Contact cont = new Contact();
        
        cont.LastName = 'myLastName';
        cont.AccountId = acctList[0].Id;
        cont.GL_Account_Variable_1__c = avList[1].id;
        
        insert cont;
        
        list<AcctSeed__GL_Account__c> glList = new list<AcctSeed__GL_Account__c>();
        
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        
        gl.name = 'GL Account First';
        gl.AcctSeed__type__c = 'Balance Sheet';
        gl.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl.AcctSeed__Active__c = true;
        gl.GL_Account_Variable_1__c = avList[1].id;
        
        glList.add(gl);
        
        		
        // ledger creation
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = avList[1].id;
        
        glList.add(aegl);
        
        AcctSeed__GL_Account__c vch = new AcctSeed__GL_Account__c();
        vch.name = '2010-Vouchers Payable';
        vch.AcctSeed__Type__c = 'Balance Sheet';
        vch.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch.AcctSeed__Active__c = true;
        vch.GL_Account_Variable_1__c = avList[1].id;
        
        glList.add(vch);
        
        AcctSeed__GL_Account__c vch1 = new AcctSeed__GL_Account__c();
        vch1.name = '2010-Vouchers Payable1';
        vch1.AcctSeed__Type__c = 'Balance Sheet';
        vch1.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch1.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch1.AcctSeed__Active__c = true;
        vch1.GL_Account_Variable_1__c = avList[1].id;
        
        glList.add(vch1);
        
        AcctSeed__GL_Account__c vch2 = new AcctSeed__GL_Account__c();
        vch2.name = '2010-Vouchers Payable2';
        vch2.AcctSeed__Type__c = 'Balance Sheet';
        vch2.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch2.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch2.AcctSeed__Active__c = true;
        vch2.GL_Account_Variable_1__c = avList[1].id;
        
        glList.add(vch2);
        
        AcctSeed__GL_Account__c vch3 = new AcctSeed__GL_Account__c();
        vch3.name = '2010-Vouchers Payable3';
        vch3.AcctSeed__Type__c = 'Balance Sheet';
        vch3.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch3.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch3.AcctSeed__Active__c = true;
        vch3.GL_Account_Variable_1__c = avList[1].id;
        
        glList.add(vch3);
        
        AcctSeed__GL_Account__c gl1 = new AcctSeed__GL_Account__c();
        gl1.name = '2010-Vouchers Payable1';
        gl1.AcctSeed__Type__c = 'Balance Sheet';
        gl1.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl1.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl1.AcctSeed__Active__c = true;
        gl1.GL_Account_Variable_1__c = avList[1].id;
        
        glList.add(gl1);
        
        AcctSeed__GL_Account__c gl2 = new AcctSeed__GL_Account__c();
        gl2.name = '2010-Vouchers Payable2';
        gl2.AcctSeed__Type__c = 'Balance Sheet';
        gl2.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl2.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl2.AcctSeed__Active__c = true;
        gl2.GL_Account_Variable_1__c = avList[1].id;
        
        glList.add(gl2);
        
        AcctSeed__GL_Account__c gl3 = new AcctSeed__GL_Account__c();
        gl3.name = '2010-Vouchers Payable3';
        gl3.AcctSeed__Type__c = 'Balance Sheet';
        gl3.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl3.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl3.AcctSeed__Active__c = true;
        gl3.GL_Account_Variable_1__c = avList[1].id;
        
        glList.add(gl3);
        
        AcctSeed__GL_Account__c gl4 = new AcctSeed__GL_Account__c();
        gl4.name = '2010-Vouchers Payable4';
        gl4.AcctSeed__Type__c = 'Balance Sheet';
        gl4.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl4.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl4.AcctSeed__Active__c = true;
        gl4.GL_Account_Variable_1__c = avList[1].id;
        
        glList.add(gl4);
        
        insert glList;
        
        list<sales_rep__c> salesrepList = new list<sales_rep__c>();
        
        sales_rep__c salesrep = new sales_rep__c();
        
        salesrep.User__c = Userinfo.getUserId();
        salesrep.Active__c = 'Yes';
        salesrep.Name = 'Murtaza Ashraf';
        salesrep.Price_Level_1_12__c = 1;
        salesrep.Price_Level_13_20__c = 2;
        salesrep.Price_Level_21_26__c = 3;
        salesrep.Price_Level_27_30__c = 4;
        salesrep.Monthly_Quota__c = 1000;
        
        salesrepList.add(salesrep);
        
        sales_rep__c salesrep2 = new sales_rep__c();
        
        salesrep2.User__c = Userinfo.getUserId();
        salesrep2.Active__c = 'Yes';
        salesrep2.Name = 'New User 2';
        salesrep2.Price_Level_1_12__c = 1;
        salesrep2.Price_Level_13_20__c = 2;
        salesrep2.Price_Level_21_26__c = 3;
        salesrep2.Price_Level_27_30__c = 4;
        salesrep2.Monthly_Quota__c = 2000;
        
        salesrepList.add(salesrep2);
        
        insert salesrepList;
        
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
        prod.AcctSeed__Expense_GL_Account__c = glList[0].id;
        prod.AcctSeed__Inventory_GL_Account__c = glList[0].id;
        prod.AcctSeed__Revenue_GL_Account__c = glList[0].id;
        prod.AcctSeed__Inventory_Product__c = true;
        //prod.Type__c = 'Product';

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
        
        // create opportunity
        list<Opportunity> oppList = new list<Opportunity>();
        
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.AccountId = acctList[0].Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Proposal';
        opp.CloseDate = Date.newInstance(d.year(), d.month() + 5, Date.daysInMonth(d.year(), d.month() + 5));
        opp.Closed_Date__c = DAte.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = avList[1].id;
        opp.RecordTypeId = RecordTypeIdOpportunity;
        opp.Pricebook2Id = pricebookId;
        //opp.IsApproved__c= false;
        opp.Newly_Submitted_Quote_First_Date__c = Date.newInstance(d.year(), d.month() - 1, 12);
        opp.Sales_Rep_O__c = salesrepList[0].id;
        opp.amount = 100;
        
        insert opp;
        
        List<task> tasks = new list<task>();
        
        tasks.add(new Task(subject='t1', whatid=opp.id,activitydate=date.today() + 3,ownerid=Userinfo.getUserId(),
                           status='Open'));
        tasks.add(new Task(subject='t2', whatid=opp.id,activitydate=null,ownerid=Userinfo.getUserId(),
                           status='Open'));
        tasks.add(new Task(subject='t3', whatid=opp.id,activitydate=date.today() - 3,ownerid=Userinfo.getUserId(), 
                           status='Open'));
        tasks.add(new Task(subject='t4', whatid=opp.id,activitydate=date.today() - 3,ownerid=Userinfo.getUserId(), 
                           status='Open'));
        
        insert tasks;
        
        Opportunity ClonedOpp = opp.clone(false, false, false, false);
        ClonedOpp.GL_Account_Variable_1__c = avList[1].id;
        ClonedOpp.Name = 'Cloned Opportunity';
        
        oppList.add(ClonedOpp);
        
        Opportunity opp1 = new Opportunity();
        
        opp1.Name = 'myOpportunity0';
        opp1.AccountId = acctList[0].Id;
        opp1.Type = 'Actual Order';
        opp1.StageName = 'Closed Lost';
        opp1.CloseDate = Date.newInstance(d.year(), d.month(), d.day());
        opp1.Closed_Date__c = Date.newInstance(d.year(), d.month(), d.day());
        opp1.ContactPerson__c = cont.Id;
        opp1.GL_Account_Variable_1__c = avList[1].id;
        opp1.Pricebook2Id = pricebookId;
        opp1.Sales_Rep_O__c = salesrepList[0].id;
        opp1.Newly_Submitted_Quote_First_Date__c = Date.newInstance(d.year(), d.month(), d.day());
        
        oppList.add(opp1);
        
        // create opportunity
        Opportunity opp2 = new Opportunity();
        
        opp2.Name = 'myOpportunity2';
        opp2.AccountId = acctList[0].Id;
        opp2.Type = 'Actual Order';
        opp2.StageName = 'Follow up';
        opp2.CloseDate = Date.newInstance(d.year()-1, d.month(), d.day());
        opp2.ContactPerson__c = cont.Id;
        opp2.GL_Account_Variable_1__c = avList[1].id;
        opp2.Pricebook2Id = pricebookId;
        opp2.Sales_Rep_O__c = salesrepList[0].id;
        opp2.LeadSource = leads[0].id;
        
        oppList.add(opp2);
        
        Opportunity opp3 = new Opportunity();
        
        opp3.Name = 'myOpportunity3';
        opp3.AccountId = acctList[0].Id;
        opp3.Type = 'Actual Order';
        opp3.StageName = 'Closed Won';
        opp3.CloseDate = Date.newInstance(d.year()-1, d.month(), d.day());
        opp3.Closed_Date__c = Date.newInstance(d.year()-1, d.month(), d.day());
        opp3.ContactPerson__c = cont.Id;
        opp3.GL_Account_Variable_1__c = avList[1].id;
        opp3.Pricebook2Id = pricebookId;
        opp3.Sales_Rep_O__c = salesrepList[0].id;
        opp3.Newly_Submitted_Quote_First_Date__c = Date.newInstance(d.year(), d.month() - 1, 12);
        opp3.Parent_Opportunity__c = opp.id;
        opp3.LeadSource = leads[0].id;
        
        oppList.add(opp3);

        Opportunity opp4 = new Opportunity();
        
        opp4.Name = 'myOpportunity4';
        opp4.AccountId = acctList[0].Id;
        opp4.Type = 'Actual Order';
        opp4.StageName = 'Closed Won';
        opp4.CloseDate = Date.newInstance(d.year()-1, d.month() + 3, d.day());
        opp4.Closed_Date__c = Date.newInstance(d.year()-1, d.month() + 3, d.day());
        opp4.ContactPerson__c = cont.Id;
        opp4.GL_Account_Variable_1__c = avList[1].id;
        opp4.Pricebook2Id = pricebookId;
        opp4.Sales_Rep_O__c = salesrepList[0].id;
        opp4.Newly_Submitted_Quote_First_Date__c = Date.newInstance(d.year(), d.month() - 1, 12);
        opp4.Parent_Opportunity__c = opp.id;
        opp4.LeadSource = leads[0].id;
        
        oppList.add(opp4);

        insert oppList;
        
        Test.setCreatedDate(opp1.id, DAte.newInstance(d.year(), d.month()-2, 10));
        
        list<opportunitylineitem> OppLineList = new list<opportunitylineitem>();
        
        opportunitylineitem oppLine = new opportunitylineitem();

        oppLine.Quantity = 2;
        oppLine.UnitPrice = 2;
        oppLine.Product2Id = prod.id;
        oppLine.PricebookEntryId = pricebentry.id;
        oppLine.OpportunityId = opp.id;
        
        OppLineList.add(oppLine);
        
        
        oppLine = new opportunitylineitem();
        
        oppLine.Quantity = 2;
        oppLine.UnitPrice = 2;
        oppLine.Product2Id = prod.id;
        oppLine.PricebookEntryId = pricebentry.id;
        oppLine.OpportunityId = oppList[0].id;
        
        OppLineList.add(oppLine);

        oppLine = new opportunitylineitem();
        
        oppLine.Quantity = 2;
        oppLine.UnitPrice = 2;
        oppLine.Product2Id = prod.id;
        oppLine.PricebookEntryId = pricebentry.id;
        oppLine.OpportunityId = oppList[1].id;
        
        OppLineList.add(oppLine);
        
        oppLine = new opportunitylineitem();
        
        oppLine.Quantity = 2;
        oppLine.UnitPrice = 2;
        oppLine.Product2Id = prod.id;
        oppLine.PricebookEntryId = pricebentry.id;
        oppLine.OpportunityId = oppList[2].id;
        
        OppLineList.add(oppLine);

        oppLine = new opportunitylineitem();
        
        oppLine.Quantity = 2;
        oppLine.UnitPrice = 2;
        oppLine.Product2Id = prod.id;
        oppLine.PricebookEntryId = pricebentry.id;
        oppLine.OpportunityId = oppList[3].id;
        
        OppLineList.add(oppLine);

        insert OppLineList;
        
        list<AcctSeed__Billing_Format__c> abfList = new list<AcctSeed__Billing_Format__c>();
        
        AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();
        
        abf.Name = 'newPDF Format';
        abf.AcctSeed__Type__c = 'Purchase Order';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        abfList.add(abf);

        AcctSeed__Billing_Format__c abf2 = new AcctSeed__Billing_Format__c();
        
        abf2.Name = 'Default Purchase Order';
        abf2.AcctSeed__Type__c = 'Purchase Order';
        abf2.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf2.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        abfList.add(abf2);
        
        insert abfList;

        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
        
        ledger.Name = 'myLedger';
        ledger.AcctSeed__Type__c = 'Transactional';
        ledger.AcctSeed__Billing_Activity_Statement_Format__c = abfList[0].id;
        ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = abfList[0].id;
        ledger.AcctSeed__Default_Bank_Account__c = glList[1].id;
        ledger.AcctSeed__Default_Billing_Format__c = abfList[0].id; 
        ledger.AcctSeed__Default_Purchase_Order_Format__c = abfList[0].id;
        ledger.AcctSeed__Default_Packing_Slip_Format__c = abfList[0].id;
        
        insert ledger;
        
        // create a sales order
        
        // This month
        list<AcctSeedERP__Sales_Order__c> salesorderList = new list<AcctSeedERP__Sales_Order__c>();  
        
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c(); 
        
        salesorder.AcctSeedERP__Customer__c = acctList[0].Id;
        //salesorder.AcctSeedERP__Opportunity__c = oppList[0].Id;
        salesorder.Contact__c = cont.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
       	salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.GL_Account_Variable_1__c = avList[1].id;
        salesorder.Stage__c = 'In Transit';
        salesorder.RecordTypeId = RecordTypeIdSO;
        salesorder.Sales_Rep_O__c = salesrepList[1].id;

        salesorderList.add(salesorder);
        
        
        // -----------------------
        // Last Year Current Month
        AcctSeedERP__Sales_Order__c salesorder2 = new AcctSeedERP__Sales_Order__c(); 
        
        salesorder2.AcctSeedERP__Customer__c = acctList[0].Id;
        //salesorder2.AcctSeedERP__Opportunity__c = oppList[1].Id;
        salesorder2.Contact__c = cont.Id;
        salesorder2.AcctSeedERP__Status__c = 'Open';
       	salesorder2.AcctSeedERP__Ledger__c = ledger.id;
        salesorder2.GL_Account_Variable_1__c = avList[1].id;
        salesorder2.Stage__c = 'In Transit';
        salesorder2.RecordTypeId = RecordTypeIdSO;
        salesorder2.Sales_Rep_O__c = salesrepList[0].id;

        salesorderList.add(salesorder2);
        
        // Last Year Current Month
        AcctSeedERP__Sales_Order__c salesorder3 = new AcctSeedERP__Sales_Order__c(); 
        // hippo
        salesorder3.AcctSeedERP__Customer__c = acctList[0].Id;
        //salesorder3.AcctSeedERP__Opportunity__c = oppList[1].Id;
        salesorder3.Contact__c = cont.Id;
        salesorder3.AcctSeedERP__Status__c = 'Open';
       	salesorder3.AcctSeedERP__Ledger__c = ledger.id;
        salesorder3.GL_Account_Variable_1__c = avList[1].id;
        salesorder3.Stage__c = 'In Transit';
        salesorder3.RecordTypeId = RecordTypeIdSO;
        salesorder3.Sales_Rep_O__c = salesrepList[0].id;

        salesorderList.add(salesorder3);
        
        insert salesorderList;
        Test.setCreatedDate(salesorder2.id, DAte.newInstance(d.year()-1, d.month() + 3, 10));

        list<AcctSeedERP__Sales_Order_Line__c> solinesList = new list<AcctSeedERP__Sales_Order_Line__c>(); 
        
        // create a sales order lines
        AcctSeedERP__Sales_Order_Line__c solines = new AcctSeedERP__Sales_Order_Line__c(); 
        
        solines.AcctSeedERP__Sales_Order__c = salesorderList[0].id;
        solines.AcctSeedERP__Unit_Price__c = 1.1;
        solines.AcctSeedERP_Description__c = 'This is salesorder line item';
        solines.AcctSeedERP__Product__c = prod.id;
        solines.AcctSeedERP__Quantity_Ordered__c = 2;
        
        solinesList.add(solines);

        // create a sales order lines
        AcctSeedERP__Sales_Order_Line__c solines2 = new AcctSeedERP__Sales_Order_Line__c(); 
        
        solines2.AcctSeedERP__Sales_Order__c = salesorderList[1].id;
        solines2.AcctSeedERP__Unit_Price__c = 1.1;
        solines2.AcctSeedERP_Description__c = 'This is salesorder line item';
        solines2.AcctSeedERP__Product__c = prod.id;
        solines2.AcctSeedERP__Quantity_Ordered__c = 2;
        
        solinesList.add(solines2);
        
        // create a sales order lines
        AcctSeedERP__Sales_Order_Line__c solines3 = new AcctSeedERP__Sales_Order_Line__c(); 
        
        solines3.AcctSeedERP__Sales_Order__c = salesorderList[2].id;
        solines3.AcctSeedERP__Unit_Price__c = 1.1;
        solines3.AcctSeedERP_Description__c = 'This is salesorder line item';
        solines3.AcctSeedERP__Product__c = prod.id;
        solines3.AcctSeedERP__Quantity_Ordered__c = 2;
        
        solinesList.add(solines3);
        
        insert solinesList;
    }

    @isTest static void runTests(){

        Test.startTest();
			
			SalesDashboardController.Active_Opportunities_By_Stage();
			SalesDashboardController.Loss_Reasons();
			SalesDashboardController.Lost_Opportunities();
			SalesDashboardController.Monthly_Sales_Last_12_Months();
			SalesDashboardController.Neglected_Opportunities();
			SalesDashboardController.Newly_Submitted_Opportunities();
			SalesDashboardController.Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source();
			SalesDashboardController.Pipeline_Last_12_Months();
			SalesDashboardController.Quota_YTD_Check();
			SalesDashboardController.Quota_YTD();
			SalesDashboardController.Sales_By_Lead_Source_Last_12_Months();
			SalesDashboardController.Sales_Forecast_Pipeline();
			SalesDashboardController.Sales_Forecast_Pipeline_By_Lead_Source();
			SalesDashboardController.Tasks_Completion();
			SalesDashboardController.Your_WinRate();        
        
        Test.stopTest();
    }
}
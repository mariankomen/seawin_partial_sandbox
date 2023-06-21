@isTest
public class ChinaSalesManagerDashboardsTest {
    
    @TestSetup static void createData(){
        
        AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c(Name = 'Seawin China',
                                                                                   AcctSeed__Type__c = 
                                                                                   'GL Account Variable 1');
        insert av;
        
        List<User> users = new List<User>();
        
        Profile pf = [Select Id from profile where Name = 'System Administrator']; 
        
        String orgId = UserInfo.getOrganizationId(); 
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName = orgId+dateString+RandomId; 
        User usr = new User(firstname = 'Test FirstName', 
                            lastName = 'Test SecondName', 
                            email = uniqueName + '@test' + orgId + '.org', 
                            Username = uniqueName + '@test' + orgId + '.org', 
                            EmailEncodingKey = 'ISO-8859-1', 
                            Alias = uniqueName.substring(18, 23), 
                            TimeZoneSidKey = 'America/Los_Angeles',
                            default_gl_account_variable__c = 'Seawin China',
                            LocaleSidKey = 'en_US', 
                            LanguageLocaleKey = 'en_US', 
                            ProfileId = pf.Id,
                            isactive = true
                           ); 

        // insert usr;
        users.add(usr);
         
        dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        RandomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        uniqueName = orgId+dateString+RandomId; 
        
        User usr2 = new User(firstname = 'Sample FirstName', 
                            lastName = 'Sample SecondName', 
                            email = uniqueName + '@test' + orgId + '.org', 
                            Username = uniqueName + '@test' + orgId + '.org', 
                            EmailEncodingKey = 'ISO-8859-1', 
                            Alias = uniqueName.substring(18, 23), 
                            TimeZoneSidKey = 'America/Los_Angeles',
                            default_gl_account_variable__c = 'Seawin China',
                            LocaleSidKey = 'en_US', 
                            LanguageLocaleKey = 'en_US', 
                            ProfileId = pf.Id,
                            isactive = true
                           ); 
        
        users.add(usr2);

        insert users;

                
        list<AcctSeed__GL_Account__c> glList = new list<AcctSeed__GL_Account__c>();
        
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        
        gl.name = 'GL Account First';
        gl.AcctSeed__type__c = 'Balance Sheet';
        gl.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl.AcctSeed__Active__c = true;
        gl.GL_Account_Variable_1__c = av.id;
        
        glList.add(gl);
        
        		
        // ledger creation
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = av.id;
        
        glList.add(aegl);
        
        AcctSeed__GL_Account__c vch = new AcctSeed__GL_Account__c();
        vch.name = '2010-Vouchers Payable';
        vch.AcctSeed__Type__c = 'Balance Sheet';
        vch.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch.AcctSeed__Active__c = true;
        vch.GL_Account_Variable_1__c = av.id;
        
        glList.add(vch);
        
        AcctSeed__GL_Account__c vch1 = new AcctSeed__GL_Account__c();
        vch1.name = '2010-Vouchers Payable1';
        vch1.AcctSeed__Type__c = 'Balance Sheet';
        vch1.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch1.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch1.AcctSeed__Active__c = true;
        vch1.GL_Account_Variable_1__c = av.id;
        
        glList.add(vch1);
        
        AcctSeed__GL_Account__c vch2 = new AcctSeed__GL_Account__c();
        vch2.name = '2010-Vouchers Payable2';
        vch2.AcctSeed__Type__c = 'Balance Sheet';
        vch2.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch2.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch2.AcctSeed__Active__c = true;
        vch2.GL_Account_Variable_1__c = av.id;
        
        glList.add(vch2);
        
        AcctSeed__GL_Account__c vch3 = new AcctSeed__GL_Account__c();
        vch3.name = '2010-Vouchers Payable3';
        vch3.AcctSeed__Type__c = 'Balance Sheet';
        vch3.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch3.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch3.AcctSeed__Active__c = true;
        vch3.GL_Account_Variable_1__c = av.id;
        
        glList.add(vch3);
        
        AcctSeed__GL_Account__c gl1 = new AcctSeed__GL_Account__c();
        gl1.name = '2010-Vouchers Payable1';
        gl1.AcctSeed__Type__c = 'Balance Sheet';
        gl1.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl1.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl1.AcctSeed__Active__c = true;
        gl1.GL_Account_Variable_1__c = av.id;
        
        glList.add(gl1);
        
        AcctSeed__GL_Account__c gl2 = new AcctSeed__GL_Account__c();
        gl2.name = '2010-Vouchers Payable2';
        gl2.AcctSeed__Type__c = 'Balance Sheet';
        gl2.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl2.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl2.AcctSeed__Active__c = true;
        gl2.GL_Account_Variable_1__c = av.id;
        
        glList.add(gl2);
        
        AcctSeed__GL_Account__c gl3 = new AcctSeed__GL_Account__c();
        gl3.name = '2010-Vouchers Payable3';
        gl3.AcctSeed__Type__c = 'Balance Sheet';
        gl3.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl3.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl3.AcctSeed__Active__c = true;
        gl3.GL_Account_Variable_1__c = av.id;
        
        glList.add(gl3);
        
        AcctSeed__GL_Account__c gl4 = new AcctSeed__GL_Account__c();
        gl4.name = '2010-Vouchers Payable4';
        gl4.AcctSeed__Type__c = 'Balance Sheet';
        gl4.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl4.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl4.AcctSeed__Active__c = true;
        gl4.GL_Account_Variable_1__c = av.id;
        
        glList.add(gl4);
        
        insert glList;
        
        Date d = Date.today();
        
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin China Hospitality').getRecordTypeId();
        
        Id RecordTypeIdSO = Schema.SObjectType.AcctSeedERP__Sales_Order__c.getRecordTypeInfosByName().get('Seawin China Hospitality').getRecordTypeId();
		Id RecordTypeIdSO2 = Schema.SObjectType.AcctSeedERP__Sales_Order__c.getRecordTypeInfosByName().get('Seawin China OEM').getRecordTypeId();
        
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
        Date dt = date.today();
        
        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        ap.name = dt.year() + '-' + ((dt.month() < 10)?'0' + dt.month():String.ValueOf(dt.month()));

        ap.AcctSeed__Start_Date__c = Date.today() - (dt.day() - 1);
        ap.AcctSeed__End_Date__c = Date.today() + 28;
        ap.AcctSeed__Status__c = 'Open';
        insert ap;
        
        
        list<sales_rep__c> salesrepList = new list<sales_rep__c>();
        
        sales_rep__c salesrep = new sales_rep__c();
        
        salesrep.Active__c = 'Yes';
        salesrep.Name = 'Murtaza Ashraf';
        salesrep.Price_Level_1_12__c = 1;
        salesrep.Price_Level_13_20__c = 2;
        salesrep.Price_Level_21_26__c = 3;
        salesrep.Price_Level_27_30__c = 4;
        salesrep.Monthly_Quota__c = 1000;
        
        salesrepList.add(salesrep);
        
        sales_rep__c salesrep2 = new sales_rep__c();
        
        salesrep2.Active__c = 'Yes';
        salesrep2.Name = 'user sales rep';
        salesrep2.Price_Level_1_12__c = 1;
        salesrep2.Price_Level_13_20__c = 2;
        salesrep2.Price_Level_21_26__c = 3;
        salesrep2.Price_Level_27_30__c = 4;
        salesrep2.Monthly_Quota__c = 2000;
        
        salesrepList.add(salesrep2);
        
        sales_rep__c salesrep3 = new sales_rep__c();
        
        salesrep3.Active__c = 'Yes';
        salesrep3.Name = 'user sales rep 2';
        salesrep3.Price_Level_1_12__c = 1;
        salesrep3.Price_Level_13_20__c = 2;
        salesrep3.Price_Level_21_26__c = 3;
        salesrep3.Price_Level_27_30__c = 4;
        salesrep3.Monthly_Quota__c = 2000;
        
        salesrepList.add(salesrep3);


        sales_rep__c salesrep4 = new sales_rep__c();
        
        salesrep4.Active__c = 'Yes';
        salesrep4.Name = 'Hospitality Team';
        salesrep4.Price_Level_1_12__c = 1;
        salesrep4.Price_Level_13_20__c = 2;
        salesrep4.Price_Level_21_26__c = 3;
        salesrep4.Price_Level_27_30__c = 4;
        salesrep4.Monthly_Quota__c = 2000;
        
        salesrepList.add(salesrep4);
        
        sales_rep__c salesrep5 = new sales_rep__c();
        
        salesrep5.Active__c = 'Yes';
        salesrep5.Name = 'Installer Team';
        salesrep5.Price_Level_1_12__c = 1;
        salesrep5.Price_Level_13_20__c = 2;
        salesrep5.Price_Level_21_26__c = 3;
        salesrep5.Price_Level_27_30__c = 4;
        salesrep5.Monthly_Quota__c = 2000;
        
        salesrepList.add(salesrep5);
        
        insert salesrepList;
        
        Test.setCreatedDate(salesrep.id, Date.newInstance(d.year(), 1, 1));
        
        Integer Months_Passed = d.month();
        
        Integer TM_Start_Year = (Months_Passed < 12) ? d.year() - 1 : d.year();
    	Integer TM_Start_Month = d.month() < 12 ? d.month() + 1 : 1;
        
    	// create account
    	list<Account> acctList = new list<Account>();

        Account acct = new Account();
        
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__Accounting_Type__c = 'Customer And Vendor';
        acct.AcctSeed__Billing_Terms_Name__c = 'Example terms1';
        acct.AcctSeed__GL_Account_Variable_1__c = av.id;
        acct.Sales_Rep_O__c = salesrep2.id;
        acct.AcctSeed__Default_Expense_GL_Account__C = aegl.id;
        acct.Industry = 'Hospitality';
        
        acctList.add(acct);
        
        Account acct2 = new Account();
        
        acct2.Name = 'myAccount2';
        acct2.Type = 'Customer';
        acct2.billingCountry = 'Pakistan';
        acct2.billingCity = 'Rawalpindi';
        acct2.billingState = 'Punjab';
        acct2.billingPostalCode = '46000';
        acct2.billingstreet = 'Satellite Town';
        acct2.AcctSeed__GL_Account_Variable_1__c = av.id;
        
        acctList.add(acct2);
        
        Account acct3 = new Account();
        
        acct3.Name = 'myAccount3';
        acct3.Type = 'Designer';
        acct3.AcctSeed__Accounting_Type__c = 'Customer';
        acct3.AcctSeed__Billing_Terms_Name__c = 'New Terms';
        acct3.AcctSeed__GL_Account_Variable_1__c = av.id;
        acct3.Industry = 'Hospitality';
        acct3.Sales_Rep_O__c = salesrep3.id;
        
        acctList.add(acct3);
        
        insert acctList;
        Test.setCreatedDate(acct3.id, Date.newInstance(TM_Start_Year, TM_Start_Month, 10));
        Test.setCreatedDate(acct2.id, Date.newInstance(TM_Start_Year, TM_Start_Month, 15));
		
        // create contact
        Contact cont = new Contact();
        
        cont.LastName = 'myLastName';
        cont.AccountId = acctList[0].Id;
        cont.GL_Account_Variable_1__c = av.id;
        
        insert cont;

        
        
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
        prod.Type__c = 'Product';

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
        opp.StageName = 'Closed Lost';
        // opp.CloseDate = Date.newInstance(d.year(), d.month() + 5, Date.daysInMonth(d.year(), d.month() + 5));
        opp.CloseDate = Date.newInstance(d.year(), d.month(), 1);
        opp.Closed_Date__c = DAte.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = av.id;
        opp.RecordTypeId = RecordTypeIdOpportunity;
        opp.Pricebook2Id = pricebookId;
        //opp.IsApproved__c= false;
        opp.quote_submitted_date__c = Date.newInstance(d.year(), d.month() - 1, 12);
        opp.Sales_Rep_O__c = salesrep2.id;
        
        insert opp;
        Test.setCreatedDate(opp.Id, Datetime.now().addDays(-31));
        
        List<task> tasks = new list<task>();
        
        tasks.add(new Task(subject='t1', whatid=opp.id,activitydate=date.today() + 3,ownerid=usr.id,status='Open'));
        tasks.add(new Task(subject='t2', whatid=opp.id,activitydate=null,ownerid=usr.id,status='Open'));
        tasks.add(new Task(subject='t3', whatid=opp.id,activitydate=date.today() - 3,ownerid=usr.id,status='Open'));
        tasks.add(new Task(subject='t4', whatid=opp.id,activitydate=date.today() - 3,ownerid=usr2.id,status='Open'));
        
        insert tasks;

        Opportunity ClonedOpp = opp.clone(false, false, false, false);
        ClonedOpp.GL_Account_Variable_1__c = av.id;
        ClonedOpp.Name = 'Cloned Opportunity';
        ClonedOpp.CloseDate = Date.newInstance(d.year(), d.month() + 5, Date.daysInMonth(d.year(), d.month() + 5));
        ClonedOpp.StageName = 'Negotiation';
        ClonedOpp.ForecastCategoryName = 'Pipeline';
        ClonedOpp.Sales_Rep_O__c = salesrep.id;

        oppList.add(ClonedOpp);
        
        //oppList.add(opp);
        
        // create opportunity
        Opportunity opp2 = new Opportunity();
        
        opp2.Name = 'myOpportunity2';
        opp2.AccountId = acctList[0].Id;
        opp2.Type = 'Actual Order';
        opp2.StageName = 'Follow up';
        opp2.ForecastCategoryName = 'Pipeline';
        opp2.CloseDate = Date.newInstance(d.year()-1, d.month(), d.day());
        opp2.ContactPerson__c = cont.Id;
        opp2.GL_Account_Variable_1__c = av.id;
        opp2.Pricebook2Id = pricebookId;
        opp2.Sales_Rep_O__c = salesrep2.id;
        opp2.RecordTypeId = RecordTypeIdOpportunity;
        
        oppList.add(opp2);
        
        Opportunity opp3 = new Opportunity();
        
        opp3.Name = 'myOpportunity3';
        opp3.AccountId = acctList[0].Id;
        opp3.Type = 'Actual Order';
        opp3.StageName = 'Closed Won';
        opp3.CloseDate = Date.newInstance(d.year()-1, d.month(), d.day());
        opp.Closed_Date__c = Date.newInstance(d.year()-1, d.month(), d.day());
        opp3.ContactPerson__c = cont.Id;
        opp3.GL_Account_Variable_1__c = av.id;
        opp3.Pricebook2Id = pricebookId;
        opp3.Sales_Rep_O__c = salesrep2.id;
        opp3.quote_submitted_date__c = Date.newInstance(d.year(), d.month() - 1, 12);
        opp3.Parent_Opportunity__c = opp.id;
        opp3.RecordTypeId = RecordTypeIdOpportunity;
        
        oppList.add(opp3);
        
        Opportunity opp4 = new Opportunity();
        
        opp4.Name = 'myOpportunity4';
        opp4.AccountId = acctList[0].Id;
        opp4.Type = 'Actual Order';
        opp4.StageName = 'Follow up';
        opp4.ForecastCategoryName = 'Pipeline';
        opp4.CloseDate = Date.newInstance(d.year()-1, d.month(), d.day());
        opp4.ContactPerson__c = cont.Id;
        opp4.GL_Account_Variable_1__c = av.id;
        opp4.Pricebook2Id = pricebookId;
        opp4.Sales_Rep_O__c = salesrep2.id;
        opp4.RecordTypeId = RecordTypeIdOpportunity;
        
        oppList.add(opp4);
        
        Opportunity opp5 = new Opportunity();
        
        opp5.Name = 'myOpportunity5';
        opp5.AccountId = acctList[0].Id;
        opp5.Type = 'Actual Order';
        opp5.StageName = 'Closed Lost';
        opp5.Closed_Date__c = Date.newInstance(d.year(), d.month() - 3, d.day());
        opp5.CloseDate = Date.newInstance(d.year(), d.month() + 5, d.day());
        opp5.ContactPerson__c = cont.Id;
        opp5.GL_Account_Variable_1__c = av.id;
        opp5.Pricebook2Id = pricebookId;
        opp5.Sales_Rep_O__c = salesrep.id;
        opp5.RecordTypeId = RecordTypeIdOpportunity;
        
        oppList.add(opp5);

        Opportunity opp6 = new Opportunity();
        
        opp6.Name = 'myOpportunity6';
        opp6.AccountId = acctList[0].Id;
        opp6.Type = 'Actual Order';
        opp6.StageName = 'Follow up';
        opp6.ForecastCategoryName = 'Pipeline';
        opp6.CloseDate = Date.newInstance(d.year()-1, d.month(), d.day());
        opp6.ContactPerson__c = cont.Id;
        opp6.GL_Account_Variable_1__c = av.id;
        opp6.Pricebook2Id = pricebookId;
        opp6.Sales_Rep_O__c = salesrep4.id;
        opp6.LeadSource = 'HD Expo 2020';
        opp6.RecordTypeId = RecordTypeIdOpportunity;
        
        oppList.add(opp6);
        
        Opportunity opp7 = new Opportunity();
        
        opp7.Name = 'myOpportunity7';
        opp7.AccountId = acctList[0].Id;
        opp7.Type = 'Actual Order';
        opp7.StageName = 'Follow up';
        opp7.ForecastCategoryName = 'Pipeline';
        opp7.CloseDate = Date.newInstance(d.year()-1, d.month(), d.day());
        opp7.ContactPerson__c = cont.Id;
        opp7.GL_Account_Variable_1__c = av.id;
        opp7.Pricebook2Id = pricebookId;
        opp7.Sales_Rep_O__c = salesrep4.id;
        opp6.LeadSource = 'Brand Approved';
        opp7.RecordTypeId = RecordTypeIdOpportunity;
        
        oppList.add(opp7);


        Opportunity opp8 = new Opportunity();
        
        opp8.Name = 'myOpportunity8';
        opp8.AccountId = acctList[0].Id;
        opp8.Type = 'Actual Order';
        opp8.StageName = 'Follow up';
        opp8.ForecastCategoryName = 'Pipeline';
        opp8.CloseDate = Date.newInstance(d.year()-1, d.month(), d.day());
        opp8.ContactPerson__c = cont.Id;
        opp8.GL_Account_Variable_1__c = av.id;
        opp8.Pricebook2Id = pricebookId;
        opp8.Sales_Rep_O__c = salesrep5.id;
        opp8.RecordTypeId = RecordTypeIdOpportunity;
        
        oppList.add(opp8);


        Opportunity opp9 = new Opportunity();
        opp9.Name = 'myOpportunity9';
        opp9.AccountId = acctList[0].Id;
        opp9.Type = 'Actual Order';
        opp9.StageName = 'Follow up';
        opp9.ForecastCategoryName = 'Pipeline';
        opp9.CloseDate = Date.newInstance(d.year()-1, d.month(), d.day());
        opp9.ContactPerson__c = cont.Id;
        opp9.GL_Account_Variable_1__c = av.id;
        opp9.Pricebook2Id = pricebookId;
        opp9.Sales_Rep_O__c = salesrep5.id;
        opp9.RecordTypeId = RecordTypeIdOpportunity;       
        oppList.add(opp9);


        Opportunity opp10 = new Opportunity();
        
        opp10.Name = 'myOpportunity10';
        opp10.AccountId = acctList[0].Id;
        opp10.Type = 'Actual Order';
        opp10.StageName = 'Sleep';
        opp10.CloseDate = Date.newInstance(d.year()-1, d.month(), d.day());
        opp10.ContactPerson__c = cont.Id;
        opp10.GL_Account_Variable_1__c = av.id;
        opp10.Pricebook2Id = pricebookId;
        opp10.Sales_Rep_O__c = salesrep4.id;
        opp10.LeadSource = 'Brand Approved';
        opp10.RecordTypeId = RecordTypeIdOpportunity;
        
        oppList.add(opp10);

        //System.runAs(usr) {
        	insert oppList;
            
            Datetime oldDate = Datetime.now().addDays(-31);
            Test.setCreatedDate(opp4.Id, oldDate);
            
            Datetime oldCreatedDate = Datetime.now().addDays(-70);
            Test.setCreatedDate(opp6.Id, oldCreatedDate);

        //}
        
        list<opportunitylineitem> l1List = new list<opportunitylineitem>();
        
        opportunitylineitem l1 = new opportunitylineitem();
        
        l1.Quantity = 2;
        l1.UnitPrice = 2;
        l1.Product2Id = prod.id;
        l1.PricebookEntryId = pricebentry.id;
        l1.OpportunityId = opp.id;
        
        l1List.add(l1);

        opportunitylineitem l2 = new opportunitylineitem();
        
        l2.Quantity = 2;
        l2.UnitPrice = 2;
        l2.Product2Id = prod.id;
        l2.PricebookEntryId = pricebentry.id;
        l2.OpportunityId = oppList[0].id;
        
        l1List.add(l2);
        
        opportunitylineitem l3 = new opportunitylineitem();
        
        l3.Quantity = 2;
        l3.UnitPrice = 2;
        l3.Product2Id = prod.id;
        l3.PricebookEntryId = pricebentry.id;
        l3.OpportunityId = oppList[1].id;
        
        l1List.add(l3);

        opportunitylineitem l4 = new opportunitylineitem();
        
        l4.Quantity = 2;
        l4.UnitPrice = 2;
        l4.Product2Id = prod.id;
        l4.PricebookEntryId = pricebentry.id;
        l4.OpportunityId = oppList[2].id;
        
        l1List.add(l4);
        
        opportunitylineitem l5 = new opportunitylineitem();
        
        l5.Quantity = 2;
        l5.UnitPrice = 2;
        l5.Product2Id = prod.id;
        l5.PricebookEntryId = pricebentry.id;
        l5.OpportunityId = oppList[3].id;
        
        l1List.add(l5);
        
        opportunitylineitem l6 = new opportunitylineitem();
        
        l6.Quantity = 2;
        l6.UnitPrice = 2;
        l6.Product2Id = prod.id;
        l6.PricebookEntryId = pricebentry.id;
        l6.OpportunityId = oppList[4].id;
        
        l1List.add(l6);

        insert l1List;
        
        // create quote
        Quote qt = new Quote();
        
        qt.OpportunityId = opp2.Id;
        //qt.AccountId = acct.Id;
        qt.Name = 'myQuote';
        qt.Quote_Date__c = Date.today();
        qt.Pricebook2Id = pricebookId;
        qt.Status = 'Presented';
        
        insert qt;
        
        //----------------------- Quote Line Items

        quotelineitem qlis = new quotelineitem();
        
        qlis.QuoteId = qt.id;
        qlis.Product2Id = prod.id;
        qlis.Quantity = 1;
        qlis.UnitPrice = 1;
        qlis.PricebookEntryId = pricebentry.id;

        insert qlis;
        
        update prod;
        
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
        
        list<AcctSeedERP__Sales_Order__c> salesorderList = new list<AcctSeedERP__Sales_Order__c>();  
        
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c(); 
        
        salesorder.AcctSeedERP__Customer__c = acctList[0].Id;
        //salesorder.AcctSeedERP__Opportunity__c = oppList[0].Id;
        salesorder.Contact__c = cont.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
       	salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.GL_Account_Variable_1__c = av.id;
        salesorder.Stage__c = 'In Transit';
        salesorder.RecordTypeId = RecordTypeIdSO;
        salesorder.Sales_Rep_O__c = salesrep2.id;

        salesorderList.add(salesorder);
        
        
        // -----------------------
        AcctSeedERP__Sales_Order__c salesorder2 = new AcctSeedERP__Sales_Order__c(); 
        
        salesorder2.AcctSeedERP__Customer__c = acctList[0].Id;
        //salesorder2.AcctSeedERP__Opportunity__c = oppList[1].Id;
        salesorder2.Contact__c = cont.Id;
        salesorder2.AcctSeedERP__Status__c = 'Cancelled';
       	salesorder2.AcctSeedERP__Ledger__c = ledger.id;
        salesorder2.GL_Account_Variable_1__c = av.id;
        salesorder2.Stage__c = 'In Transit';
        salesorder2.RecordTypeId = RecordTypeIdSO;
        salesorder2.Sales_Rep_O__c = salesrep2.id;

        salesorderList.add(salesorder2);

        // --------- sales order
        
        AcctSeedERP__Sales_Order__c salesorder3 = new AcctSeedERP__Sales_Order__c();  
        salesorder3.AcctSeedERP__Customer__c = acctList[0].Id;
        //salesorder2.AcctSeedERP__Opportunity__c = oppList[1].Id;
        salesorder3.Contact__c = cont.Id;
        salesorder3.AcctSeedERP__Status__c = 'Cancelled';
       	salesorder3.AcctSeedERP__Ledger__c = ledger.id;
        salesorder3.GL_Account_Variable_1__c = av.id;
        salesorder3.Stage__c = 'In Transit';
        salesorder3.RecordTypeId = RecordTypeIdSO;
        salesorder3.Sales_Rep_O__c = salesrep2.id;
        
        salesorderList.add(salesorder3);

        AcctSeedERP__Sales_Order__c salesorder4 = new AcctSeedERP__Sales_Order__c();  
        salesorder4.AcctSeedERP__Customer__c = acctList[0].Id;
        salesorder4.Contact__c = cont.Id;
        salesorder4.AcctSeedERP__Status__c = 'Cancelled';
       	salesorder4.AcctSeedERP__Ledger__c = ledger.id;
        salesorder4.GL_Account_Variable_1__c = av.id;
        salesorder4.Stage__c = 'In Transit';
        salesorder4.RecordTypeId = RecordTypeIdSO2;
        salesorder4.Sales_Rep_O__c = salesrep2.id;

        salesorderList.add(salesorder4);
        
        AcctSeedERP__Sales_Order__c salesorder40 = new AcctSeedERP__Sales_Order__c();  
        salesorder40.AcctSeedERP__Customer__c = acctList[0].Id;
        salesorder40.Contact__c = cont.Id;
        salesorder40.AcctSeedERP__Status__c = 'Cancelled';
       	salesorder40.AcctSeedERP__Ledger__c = ledger.id;
        salesorder40.GL_Account_Variable_1__c = av.id;
        salesorder40.Stage__c = 'In Transit';
        salesorder40.RecordTypeId = RecordTypeIdSO2;
        salesorder40.Sales_Rep_O__c = salesrep2.id;

        salesorderList.add(salesorder40);


        AcctSeedERP__Sales_Order__c salesorder5 = new AcctSeedERP__Sales_Order__c();  
        salesorder5.AcctSeedERP__Customer__c = acctList[0].Id;
        salesorder5.Contact__c = cont.Id;
        salesorder5.AcctSeedERP__Status__c = 'Cancelled';
       	salesorder5.AcctSeedERP__Ledger__c = ledger.id;
        salesorder5.GL_Account_Variable_1__c = av.id;
        salesorder5.Stage__c = 'In Transit';
        salesorder5.RecordTypeId = RecordTypeIdSO2;
        salesorder5.Sales_Rep_O__c = salesrep2.id;

        salesorderList.add(salesorder5);
        
        AcctSeedERP__Sales_Order__c salesorder50 = new AcctSeedERP__Sales_Order__c();  
        salesorder50.AcctSeedERP__Customer__c = acctList[0].Id;
        salesorder50.Contact__c = cont.Id;
        salesorder50.AcctSeedERP__Status__c = 'Cancelled';
       	salesorder50.AcctSeedERP__Ledger__c = ledger.id;
        salesorder50.GL_Account_Variable_1__c = av.id;
        salesorder50.Stage__c = 'In Transit';
        salesorder50.RecordTypeId = RecordTypeIdSO2;
        salesorder50.Sales_Rep_O__c = salesrep2.id;

        salesorderList.add(salesorder50);

        
        insert salesorderList;
        Test.setCreatedDate(salesorder2.id, DAte.newInstance(d.year()-1, d.month() + 1, 5));
        Test.setCreatedDate(salesorder3.id, DAte.newInstance(d.year(), d.month() - 1, 2));
        Test.setCreatedDate(salesorder4.id, DAte.newInstance(d.year()-1, d.month() + 1, 8));
        Test.setCreatedDate(salesorder5.id, DAte.newInstance(d.year()-1, d.month()+3, 1));

        list<AcctSeedERP__Sales_Order_Line__c> solinesList = new list<AcctSeedERP__Sales_Order_Line__c>(); 
        
        // create a sales order lines
        AcctSeedERP__Sales_Order_Line__c solines = new AcctSeedERP__Sales_Order_Line__c(); 
        
        solines.AcctSeedERP__Sales_Order__c = salesorder.id;
        solines.AcctSeedERP__Unit_Price__c = 1.1;
        solines.AcctSeedERP_Description__c = 'This is salesorder line item';
        solines.AcctSeedERP__Product__c = prod.id;
        solines.AcctSeedERP__Quantity_Ordered__c = 2;
        
        solinesList.add(solines);

        // create a sales order lines
        AcctSeedERP__Sales_Order_Line__c solines2 = new AcctSeedERP__Sales_Order_Line__c(); 
        
        solines2.AcctSeedERP__Sales_Order__c = salesorder2.id;
        solines2.AcctSeedERP__Unit_Price__c = 1.1;
        solines2.AcctSeedERP_Description__c = 'This is salesorder line item';
        solines2.AcctSeedERP__Product__c = prod.id;
        solines2.AcctSeedERP__Quantity_Ordered__c = 2;
        
        solinesList.add(solines2);


        AcctSeedERP__Sales_Order_Line__c solines3 = new AcctSeedERP__Sales_Order_Line__c();         
        solines3.AcctSeedERP__Sales_Order__c = salesorder3.id;
        solines3.AcctSeedERP__Unit_Price__c = 1.1;
        solines3.AcctSeedERP_Description__c = 'This is salesorder line item';
        solines3.AcctSeedERP__Product__c = prod.id;
        solines3.AcctSeedERP__Quantity_Ordered__c = 2;     
        solinesList.add(solines3);
        
        
        AcctSeedERP__Sales_Order_Line__c solines4 = new AcctSeedERP__Sales_Order_Line__c();         
        solines4.AcctSeedERP__Sales_Order__c = salesorder4.id;
        solines4.AcctSeedERP__Unit_Price__c = 1.1;
        solines4.AcctSeedERP_Description__c = 'This is salesorder line item';
        solines4.AcctSeedERP__Product__c = prod.id;
        solines4.AcctSeedERP__Quantity_Ordered__c = 2;     
        solinesList.add(solines4);
        
        AcctSeedERP__Sales_Order_Line__c solines5 = new AcctSeedERP__Sales_Order_Line__c();         
        solines5.AcctSeedERP__Sales_Order__c = salesorder5.id;
        solines5.AcctSeedERP__Unit_Price__c = 1.1;
        solines5.AcctSeedERP_Description__c = 'This is salesorder line item';
        solines5.AcctSeedERP__Product__c = prod.id;
        solines5.AcctSeedERP__Quantity_Ordered__c = 2;     
        solinesList.add(solines5);

        insert solinesList;
        
        List<AcctSeed__Billing__c> billList = new List<AcctSeed__Billing__c>();
        
        AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
        
        bill.AcctSeed__Status__c = 'Approved';
        bill.AcctSeed__PDF_Email_Status__c = 'Unsent';
        bill.AcctSeed__Billing_Format__c = abfList[0].id;
        bill.AcctSeedERP__Sales_Order__c = salesorderList[0].id; 
        bill.AcctSeed__Date__c = Date.Today();
        bill.AcctSeed__Due_Date2__c = Date.Today();
        bill.AcctSeed__Ledger__c = salesorderList[0].AcctSeedERP__Ledger__c;
        bill.AcctSeed__Opportunity__c = salesorderList[0].AcctSeedERP__Opportunity__c;
        bill.AcctSeed__Customer__c = salesorderList[0].AcctSeedERP__Customer__c;
        bill.AcctSeed__Accounting_Period__c = ap.id;

        billList.add(bill);

        // credit memo
        AcctSeed__Billing__c bill2 = new AcctSeed__Billing__c();
        
        bill2.AcctSeed__Status__c = 'Approved';
        bill2.AcctSeed__PDF_Email_Status__c = 'Unsent';
        bill2.AcctSeed__Billing_Format__c = abfList[0].id;
        bill2.AcctSeedERP__Sales_Order__c = salesorderList[0].id; 
        bill2.AcctSeed__Date__c = Date.Today();
        bill2.AcctSeed__Due_Date2__c = Date.Today();
        bill2.AcctSeed__Ledger__c = salesorderList[0].AcctSeedERP__Ledger__c;
        bill2.AcctSeed__Opportunity__c = salesorderList[0].AcctSeedERP__Opportunity__c;
        bill2.AcctSeed__Customer__c = salesorderList[0].AcctSeedERP__Customer__c;
        bill2.AcctSeed__Accounting_Period__c = ap.id;
        
        billList.add(bill2);

        insert billList;
        
        List<AcctSeed__Billing_Line__c> blineList = new List<AcctSeed__Billing_Line__c>();
        
        AcctSeed__Billing_Line__c bline = new AcctSeed__Billing_Line__c();
        bline.AcctSeed__Billing__c = billList[0].id;
        bline.AcctSeed__Date__c = date.today();
        bline.AcctSeed__Hours_Units__c = 1;
        bline.AcctSeed__Product__c = solinesList[0].AcctSeedERP__Product__c;
        bline.AcctSeedERP__Sales_Order_Line__c = solinesList[0].id;
        bline.AcctSeed__Rate__c = solinesList[0].AcctSeedERP__Unit_Price__c;
        bline.Item_Description__c = solinesList[0].Item_Description__c;
        
        blineList.add(bline);
        
        AcctSeed__Billing_Line__c bline2 = new AcctSeed__Billing_Line__c();
        bline2.AcctSeed__Billing__c = billList[1].id;
        bline2.AcctSeed__Date__c = date.today();
        bline2.AcctSeed__Hours_Units__c = 1;
        bline2.AcctSeed__Product__c = solinesList[0].AcctSeedERP__Product__c;
        bline2.AcctSeedERP__Sales_Order_Line__c = solinesList[0].id;
        bline2.AcctSeed__Rate__c = -solinesList[0].AcctSeedERP__Unit_Price__c;
        bline2.Item_Description__c = solinesList[0].Item_Description__c;
        
        blineList.add(bline2);
        
        insert blineList;
    }
    @isTest static void BillingAgingDashboardCHK(){
        Test.startTest();
        
        BillingAgingDashboardChinaController.Billing_Aging();
        BillingAgingDashboardChinaController.Billing_Collection_Performance();

        Test.stopTest();
    }
    @isTest static void HospitalityDashboardCHK(){
         
        Test.startTest();
        
        HospitalityDashboardChinaController.Monthly_Sales_Last_12_Months();
        HospitalityDashboardChinaController.Sales_By_Lead_Source_Last_12_Months();
        HospitalityDashboardChinaController.Current_Sales_Contest_QTD();
        HospitalityDashboardChinaController.Current_Sales_Contest_TM();
        HospitalityDashboardChinaController.Current_Sales_Contest_YTD();
        HospitalityDashboardChinaController.Negotiation_WinRate();
        HospitalityDashboardChinaController.Win_Rate();
        HospitalityDashboardChinaController.Team_Quota_YTD();
        HospitalityDashboardChinaController.Team_Quota_Percent();
        HospitalityDashboardChinaController.Active_Opportunities_By_Stage();
        HospitalityDashboardChinaController.Sales_Forecast_Pipeline();
        HospitalityDashboardChinaController.Sales_Forecast_Pipeline_By_Lead_Source();
        
        HospitalityDashboardChinaController.Lost_Opportunities();
        HospitalityDashboardChinaController.Lost_Opportunities_by_Sales_Rep_Team();
        HospitalityDashboardChinaController.Loss_Reasons();
        HospitalityDashboardChinaController.Newly_Submitted_Opportunities();
        HospitalityDashboardChinaController.Newly_Submitted_Opportunities_Last_Twelve_Months_By_Sales_Rep_Team();
        HospitalityDashboardChinaController.Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source();
        
        HospitalityDashboardChinaController.New_Customers_Last_12_Months_By_Type();
        HospitalityDashboardChinaController.Tasks_Completion();
        HospitalityDashboardChinaController.Neglected_Opportunities();
        HospitalityDashboardChinaController.NewLeads();
        HospitalityDashboardChinaController.Activity_Graph_Last_12_Months();
        HospitalityDashboardChinaController.Company_Total_Pipeline_Last_12_Months();
        HospitalityDashboardChinaController.Sales_Reps_Total_Pipeline_Last_12_Months();
        HospitalityDashboardChinaController.Pipeline_Last_12_Months_By_Lead_Source();

        Test.stopTest();
    }
    @isTest static void OEMDashboardChina(){
        Test.startTest();
     	OEMDashboardChinaController ext = new OEMDashboardChinaController();
        
        OEMDashboardChinaController.Monthly_Sales_Last_12_Months_OEM();
        ext.Top_Ten_Accounts_OEM();
        ext.Top_Ten_Shipped_OEM();

        Test.stopTest();
    }

}
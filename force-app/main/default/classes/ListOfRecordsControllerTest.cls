@isTest
public class ListOfRecordsControllerTest {
	
	@TestSetup static void createData(){
		
		list<AcctSeed__Accounting_Variable__c> avList = new list<AcctSeed__Accounting_Variable__c>();
		
		avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin China',
                                                        AcctSeed__Type__c = 'GL Account Variable 1'));
		
		avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',
                                                        AcctSeed__Type__c = 'GL Account Variable 1'));
		insert avList;
		
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
		
		// --------- Create User
		// User usr = [select id from user where name='House Account' limit 1];
		Profile pf = [Select Id from profile where Name = 'System Administrator'];
        
        String orgId = UserInfo.getOrganizationId(); 
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName = orgId + dateString + RandomId; 
		User usr = new User(firstname = 'House', 
                            lastName = 'Account', 
                            email = uniqueName + '@test' + orgId + '.org', 
                            Username = uniqueName + '@test' + orgId + '.org', 
                            EmailEncodingKey = 'ISO-8859-1', 
                            Alias = uniqueName.substring(18, 23), 
                            TimeZoneSidKey = 'America/Los_Angeles', 
                            LocaleSidKey = 'en_US', 
                            LanguageLocaleKey = 'en_US', 
                            ProfileId = pf.Id
                           ); 
		insert usr;
		Date d = Date.today();
		
		Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
		
		Id RecordTypeIdSO = Schema.SObjectType.AcctSeedERP__Sales_Order__c.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
		id RecordTypeIdSo2 = Schema.SObjectType.AcctSeedERP__Sales_Order__c.getRecordTypeInfosByName().get('Seawin USA Online/Drop Shipment').getRecordTypeId();
		id RecordTypeIdSo3 = Schema.SObjectType.AcctSeedERP__Sales_Order__c.getRecordTypeInfosByName().get('Seawin USA Wholesale Distribution').getRecordTypeId();
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

        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        
        Integer year = d.year();
        String month = d.month() > 9 ? '' + d.month() : '0' + d.month();

        ap.Name = year + '-' + month;
        ap.AcctSeed__Start_Date__c = Date.NewInstance(year, d.month(), 1);
        ap.AcctSeed__End_Date__c = Date.NewInstance(year, d.month(), Date.DaysInMonth(year, d.month()));
        ap.AcctSeed__Status__c = 'Open';
            
        insert ap;
		
		
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
		salesrep.Default_Record_Type__c = 'Seawin USA Hospitality';
		
		salesrepList.add(salesrep);
		
		sales_rep__c salesrep2 = new sales_rep__c();
		
		salesrep2.User__c = Usr.id;
		salesrep2.Active__c = 'Yes';
		salesrep2.Name = 'user sales rep';
		salesrep2.Price_Level_1_12__c = 1;
		salesrep2.Price_Level_13_20__c = 2;
		salesrep2.Price_Level_21_26__c = 3;
		salesrep2.Price_Level_27_30__c = 4;
		salesrep2.Monthly_Quota__c = 2000;
		salesrep2.Default_Record_Type__c = 'Seawin USA Hospitality';
		
		salesrepList.add(salesrep2);
		
		sales_rep__c salesrep3 = new sales_rep__c();
		
		salesrep3.User__c = Usr.id;
		salesrep3.Active__c = 'Yes';
		salesrep3.Name = 'user sales rep 2';
		salesrep3.Price_Level_1_12__c = 1;
		salesrep3.Price_Level_13_20__c = 2;
		salesrep3.Price_Level_21_26__c = 3;
		salesrep3.Price_Level_27_30__c = 4;
		salesrep3.Monthly_Quota__c = 2000;
		salesrep3.Default_Record_Type__c = 'Seawin China Hospitality';
		
		salesrepList.add(salesrep3);
		
		insert salesrepList;
		
		// create account
		list<Account> acctList = new list<Account>();
		
		Account acct = new Account();
		
		acct.Name = 'myAccount';
		acct.Type = 'Customer';
		acct.AcctSeed__Accounting_Type__c = 'Customer And Vendor';
		acct.AcctSeed__Billing_Terms_Name__c = 'Example terms1';
		acct.AcctSeed__GL_Account_Variable_1__c = avList[1].id;
		acct.Sales_Rep_O__c = salesrep2.id;
		acct.AcctSeed__Default_Expense_GL_Account__c = aegl.id;
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
		acct2.AcctSeed__GL_Account_Variable_1__c = avList[0].id;
		
		acctList.add(acct2);
		
		Account acct3 = new Account();
		
		acct3.Name = 'myAccount3';
		acct3.Type = 'Designer';
		acct3.AcctSeed__Accounting_Type__c = 'Customer';
		acct3.AcctSeed__Billing_Terms_Name__c = 'New Terms';
		acct3.AcctSeed__GL_Account_Variable_1__c = avList[1].id;
		acct3.Industry = 'Hospitality';
		acct3.Sales_Rep_O__c = salesrep3.id;
		
		acctList.add(acct3);
		
		insert acctList;
		
		Integer Months_Passed = d.month();
		
		Integer TM_Start_Year = (Months_Passed < 12) ? d.year() - 1 : d.year();
		Integer TM_Start_Month = d.month() < 12 ? d.month() + 1 : 1;
		
		
		Test.setCreatedDate(acct3.id, Date.newInstance(TM_Start_Year, TM_Start_Month, 10));
		Test.setCreatedDate(acct2.id, Date.newInstance(TM_Start_Year, TM_Start_Month, 15));
		
		// create contact
		Contact cont = new Contact();
		
		cont.LastName = 'myLastName';
		cont.AccountId = acctList[0].Id;
		cont.GL_Account_Variable_1__c = avList[1].id;
		
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
		opp.StageName = 'Closed Won';
		opp.CloseDate = Date.newInstance(d.year(), d.month() + 5, Date.daysInMonth(d.year(), d.month() + 5));
		opp.Closed_Date__c = DAte.today();
		opp.ContactPerson__c = cont.Id;
		opp.GL_Account_Variable_1__c = avList[1].id;
		opp.RecordTypeId = RecordTypeIdOpportunity;
		opp.Pricebook2Id = pricebookId;
		//opp.IsApproved__c= false;
		opp.quote_submitted_date__c = Date.newInstance(d.year(), d.month() - 1, 12);
		opp.Sales_Rep_O__c = salesrep2.id;
		
		insert opp;
		
		List<task> tasks = new list<task>();
		
        tasks.add(new Task(subject='t1', whatid=opp.id,activitydate=date.today() - 2,ownerid=Userinfo.getuserid(),status='Open'));
		tasks.add(new Task(subject='t2', whatid=opp.id,activitydate=null,ownerid=Userinfo.getuserid(),status='Open'));
		tasks.add(new Task(subject='t3', whatid=opp.id,activitydate=date.today() - 3,ownerid=Userinfo.getuserid(),status='Open'));
		
		insert tasks;
		
		
		
		Opportunity ClonedOpp = opp.clone(false, false, false, false);
		ClonedOpp.Name = 'Cloned Opportunity';
		ClonedOpp.GL_Account_Variable_1__c = avList[1].id;
		
		oppList.add(ClonedOpp);
		
		//oppList.add(opp);
		
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
		opp3.GL_Account_Variable_1__c = avList[1].id;
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
		opp4.CloseDate = Date.newInstance(d.year()-1, d.month(), d.day());
		opp4.ContactPerson__c = cont.Id;
		opp4.GL_Account_Variable_1__c = avList[1].id;
		opp4.Pricebook2Id = pricebookId;
		opp4.Sales_Rep_O__c = salesrep3.id;
		opp4.RecordTypeId = RecordTypeIdOpportunity;
		
		oppList.add(opp4);
		
		insert oppList;
		
		Test.setCreatedDate(opp2.id, Date.newInstance(2020, 11, 10));
		Test.setCreatedDate(opp4.id, Date.newInstance(TM_Start_Year, TM_Start_Month, 10));
		
		List<Opportunity> opps = [SELECT Id, Name, AccountId, Type, StageName, CloseDate, ContactPerson__c, GL_Account_Variable_1__c, Sales_Rep_O__c, RecordType.Name FROM Opportunity LIMIT 50];
		List<Opportunity_Dashboard__c> opp_dashb = new List<Opportunity_Dashboard__c>();

		for(Opportunity opportu :opps){
			Opportunity_Dashboard__c op_d = new Opportunity_Dashboard__c();
			op_d.Opportunity__c = opportu.Id;
			op_d.Account__c = opportu.AccountId;
			op_d.Opportunity_Type__c = opportu.Type;
			op_d.Opportunity_StageName__c = opportu.StageName;
			op_d.Close_Date__c = opportu.CloseDate;
			op_d.Opportunity_ContactPerson__c = opportu.ContactPerson__c;
			op_d.Opportunity_GL_Var_1__c = opportu.GL_Account_Variable_1__c;
			op_d.Sales_Rep_Team__c = opportu.Sales_Rep_O__c;
			op_d.RecordTypeName__c = opportu.RecordType.Name;
			opp_dashb.add(op_d);
		}
		insert opp_dashb;





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
		salesorder.GL_Account_Variable_1__c = avList[1].id;
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
		salesorder2.GL_Account_Variable_1__c = avList[1].id;
		salesorder2.Stage__c = 'In Transit';
		salesorder2.RecordTypeId = RecordTypeIdSO;
		salesorder2.Sales_Rep_O__c = salesrep2.id;
		
		salesorderList.add(salesorder2);
		
		insert salesorderList;
		Test.setCreatedDate(salesorder2.id, DAte.newInstance(d.year()-1, d.month(), 10));
		
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
		
		insert solinesList;
		
		List<AcctSeed__Billing__c> billList = new List<AcctSeed__Billing__c>();
		
		AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
		
		bill.AcctSeed__Status__c = 'Approved';
		bill.AcctSeed__PDF_Email_Status__c = 'Unsent';
		bill.AcctSeed__Billing_Format__c = abfList[0].id;
		bill.AcctSeedERP__Sales_Order__c = salesorderList[1].id; 
		bill.AcctSeed__Date__c = Date.Today();
		bill.AcctSeed__Due_Date2__c = Date.Today();
		bill.AcctSeed__Ledger__c = salesorderList[0].AcctSeedERP__Ledger__c;
		bill.AcctSeed__Opportunity__c = salesorderList[0].AcctSeedERP__Opportunity__c;
		bill.AcctSeed__Customer__c = salesorderList[0].AcctSeedERP__Customer__c;
		bill.AcctSeed__Shipping_City__c = salesorderList[0].AcctSeedERP__Shipping_City__c;
		bill.AcctSeed__Shipping_Contact__c = salesorderList[0].Contact__c;
		bill.AcctSeed__Shipping_Country__c = salesorderList[0].AcctSeedERP__Shipping_Country__c;
		bill.AcctSeed__Shipping_PostalCode__c = salesorderList[0].AcctSeedERP__Shipping_PostalCode__c;
		bill.AcctSeed__Shipping_State__c = salesorderList[0].AcctSeedERP__Shipping_State__c;
		bill.AcctSeed__Shipping_Street__c = salesorderList[0].AcctSeedERP__Shipping_Street__c;
		bill.AcctSeed__Billing_Contact__c = salesorderList[0].Contact__c;
		bill.AcctSeed__Billing_Country__c = salesorderList[0].AcctSeedERP__Billing_Country__c;
		bill.AcctSeed__Billing_PostalCode__c = salesorderList[0].AcctSeedERP__Billing_PostalCode__c;
		bill.AcctSeed__Billing_State__c = salesorderList[0].AcctSeedERP__Billing_State__c;
		bill.AcctSeed__Billing_Street__c = salesorderList[0].AcctSeedERP__Billing_Street__c;
		bill.AcctSeed__Billing_City__c = salesorderList[0].AcctSeedERP__Billing_City__c;
		bill.AcctSeed__Accounting_Period__c = ap.id;
		
		billList.add(bill);
		
		// credit memo
		AcctSeed__Billing__c bill2 = new AcctSeed__Billing__c();
		
		bill2.AcctSeed__Status__c = 'Approved';
		bill2.AcctSeed__PDF_Email_Status__c = 'Unsent';
		bill2.AcctSeed__Billing_Format__c = abfList[0].id;
		bill2.AcctSeedERP__Sales_Order__c = salesorderList[1].id; 
		bill2.AcctSeed__Date__c = Date.Today();
		bill2.AcctSeed__Due_Date2__c = Date.Today();
		bill2.AcctSeed__Ledger__c = salesorderList[0].AcctSeedERP__Ledger__c;
		bill2.AcctSeed__Opportunity__c = salesorderList[0].AcctSeedERP__Opportunity__c;
		bill2.AcctSeed__Customer__c = salesorderList[0].AcctSeedERP__Customer__c;
		bill2.AcctSeed__Shipping_City__c = salesorderList[0].AcctSeedERP__Shipping_City__c;
		bill2.AcctSeed__Shipping_Contact__c = salesorderList[0].Contact__c;
		bill2.AcctSeed__Shipping_Country__c = salesorderList[0].AcctSeedERP__Shipping_Country__c;
		bill2.AcctSeed__Shipping_PostalCode__c = salesorderList[0].AcctSeedERP__Shipping_PostalCode__c;
		bill2.AcctSeed__Shipping_State__c = salesorderList[0].AcctSeedERP__Shipping_State__c;
		bill2.AcctSeed__Shipping_Street__c = salesorderList[0].AcctSeedERP__Shipping_Street__c;
		bill2.AcctSeed__Billing_Contact__c = salesorderList[0].Contact__c;
		bill2.AcctSeed__Billing_Country__c = salesorderList[0].AcctSeedERP__Billing_Country__c;
		bill2.AcctSeed__Billing_PostalCode__c = salesorderList[0].AcctSeedERP__Billing_PostalCode__c;
		bill2.AcctSeed__Billing_State__c = salesorderList[0].AcctSeedERP__Billing_State__c;
		bill2.AcctSeed__Billing_Street__c = salesorderList[0].AcctSeedERP__Billing_Street__c;
		bill2.AcctSeed__Billing_City__c = salesorderList[0].AcctSeedERP__Billing_City__c;
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
	
	@isTEst static void BillingAgingFD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Billing_Aging_FD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'FD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void BillingAgingFD2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Billing_Aging_FD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('dashboard', 'FD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Tasks_Completion(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Tasks_Completion');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ApexPages.currentPage().getParameters().put('duration', 'ODT');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Tasks_Completion2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Tasks_Completion');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ApexPages.currentPage().getParameters().put('duation', 'OTT');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}

	@isTEst static void Tasks_Completion3(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Tasks_Completion');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ApexPages.currentPage().getParameters().put('duation', 'NDT');
		ListOfRecordsController sdc = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('duation', 'OTT');
		ListOfRecordsController sdc1 = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('duation', 'NDT');
		ListOfRecordsController sdc2 = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Neglected_Opportunities(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Neglected_Opportunities');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ApexPages.currentPage().getParameters().put('str', '31 - 60 days');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('str', 'Over 120 days');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('str', '91 - 120 days');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('str', '61 - 90 days');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	
	@isTEst static void Active_Opportunities_By_Stage(){
		
		Test.startTest();

		ApexPages.currentPage().getParameters().put('chart', 'Active_Opportunities_By_Stage');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('duration', 'TM');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('chart', 'Active_Opportunities_By_Stage');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('duration', 'TM');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc1 = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('chart', 'Active_Opportunities_By_Stage');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ApexPages.currentPage().getParameters().put('duration', 'TM');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('chart', 'Active_Opportunities_By_Stage');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'left');
		ApexPages.currentPage().getParameters().put('duration', 'TM');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	
	@isTEst static void Sales_Forecast_Pipeline(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Forecast_Pipeline');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Sales_Forecast_Pipeline2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Forecast_Pipeline');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Sales_Forecast_Pipeline3(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Forecast_Pipeline');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Lost_Opportunities(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Lost_Opportunities');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		ApexPages.currentPage().getParameters().put('click', 'point');
		Test.stopTest();
		
	}
	@isTEst static void Lost_Opportunities2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Lost_Opportunities');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		ApexPages.currentPage().getParameters().put('click', 'point');
		Test.stopTest();
		
	}
	 @isTEst static void YourWinRate_SD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'YourWinRate_SD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('str', 'Negotiation');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Neg_Win_Rate_SD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Neg_Win_Rate_SD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		ApexPages.currentPage().getParameters().put('click', 'point');
		Test.stopTest();
		
	}
	@isTEst static void Neg_Win_Rate_SD2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Neg_Win_Rate_SD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('duration', 'TM');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Win_Rate_SD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Win_Rate_SD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Win_Rate_SD2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Win_Rate_SD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('duration', 'TM');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Win_Rate_SD3(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Win_Rate_SD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		//ApexPages.currentPage().getParameters().put('duration', 'TM');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Monthly_Sales_Last_12_Months(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Monthly_Sales_Last_12_Months');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Monthly_Sales_Last_12_Months2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Monthly_Sales_Last_12_Months');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Monthly_Sales_Last_12_Months3(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Monthly_Sales_Last_12_Months');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Quota_YTD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Quota_YTD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void SalesRep_Pipeline_Last_12_Months(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'SalesRep_Pipeline_Last_12_Months');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		ApexPages.currentPage().getParameters().put('click', 'bar');
		Test.stopTest();
		
	}
	@isTEst static void SalesRep_Pipeline_Last_12_Months2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'SalesRep_Pipeline_Last_12_Months');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		 ApexPages.currentPage().getParameters().put('click', 'bar');
		Test.stopTest();
		
	}
	@isTEst static void SalesRep_Pipeline_Last_12_Months3(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'SalesRep_Pipeline_Last_12_Months');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	
	// Sales Manager Dashboard tests
	@isTEst static void BillingAging(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Billing_Aging_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void BillingAging2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Billing_Aging_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void CollectionPerformance_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Collection_Performance_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	// starts here
	
	@isTEst static void Activity_Graph_Last_12_Months_SMD_USA(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Activity_Graph_Last_12_Months_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Activity_Graph_Last_12_Months_SMD_USA2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Activity_Graph_Last_12_Months_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Activity_Graph_Last_12_Months_SMD_USA3(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Activity_Graph_Last_12_Months_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	// ends here
	// 
	@isTEst static void Company_Total_Pipeline_SMD_USA(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Company_Total_Pipeline_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Company_Total_Pipeline_SMD_USA2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Company_Total_Pipeline_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Sales_Reps_Total_Pipeline_SMD_USA(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Reps_Total_Pipeline_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}

	@isTEst static void MontlySales_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Monthly_Sales_Last_12_Months_SMD_H');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void MontlySales_SMD2(){
		
		Test.startTest();
		
		ApexPages.currentPage().getParameters().put('chart', 'Monthly_Sales_Last_12_Months_SMD_H');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc2 = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc3 = new ListOfRecordsController();
		
		Test.stopTest();
		
	}
	
	@isTEst static void CurrentSalesContest_YTD_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Current_Sales_Contest_YTD_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('duration', 'TM');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void CurrentSalesContest_YTD_SMD2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Current_Sales_Contest_YTD_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('duration', 'TM');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void CurrentSalesContest_QTD_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Current_Sales_Contest_QTD_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void CurrentSalesContest_TM_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Current_Sales_Contest_TM_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Team_Quota_YTD_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Team_Quota_YTD_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Team_Quota_Percent_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Team_Quota_Percent_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Active_Opportunities_By_Stage_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Active_Opportunities_By_Stage_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();
		
		Test.stopTest();
		
	}
	
	@isTEst static void Sales_Forecast_Pipeline_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Forecast_Pipeline_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Lost_Opportunities_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Lost_Opportunities_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Lost_Opportunities_SMD2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Lost_Opportunities_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc2 = new ListOfRecordsController();
		ApexPages.currentPage().getParameters().put('click', 'month-point');
		ListOfRecordsController sdc3 = new ListOfRecordsController();
		
		Test.stopTest();
		
	}
	
	@isTEst static void Sales_By_Lead_Source_Last_12_Months_SMD_H(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_By_Lead_Source_Last_12_Months_SMD_H');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Sales_By_Lead_Source_Last_12_Months_SMD_H2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_By_Lead_Source_Last_12_Months_SMD_H');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc2 = new ListOfRecordsController();
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc3 = new ListOfRecordsController();
		
		Test.stopTest();
		
	}
	
   @isTEst static void Sales_Forecast_Pipeline_By_Lead_Source_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Forecast_Pipeline_By_Lead_Source_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Sales_Forecast_Pipeline_By_Lead_Source_SMD2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Forecast_Pipeline_By_Lead_Source_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc2 = new ListOfRecordsController();
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc3 = new ListOfRecordsController();
		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();
		
		Test.stopTest();
		
	}
   @isTEst static void Loss_Reasons_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Loss_Reasons_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Newly_Submitted_Opportunities_Last_12_Months_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Opportunities_Last_12_Months_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source_SMD_point(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
	}
	@isTEst static void Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source_SMD_legend(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
	}
	@isTEst static void New_Customers_Last_12_Months_by_Type_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'New_Customers_Last_12_Months_by_Type_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Win_Rate_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Win_Rate_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Neg_Win_Rate_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Neg_Win_Rate_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Neg_Win_Rate_SMD2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Neg_Win_Rate_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Newly_Submitted_Quotes_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Quotes_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Tasks_Completion_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Tasks_Completion_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc1 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc2 = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc3 = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Neglected_Opportunities_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Neglected_Opportunities_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void New_Leads_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'New_Leads_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void New_Customers_By_Industry_SMD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'New_Customers_By_Industry_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Monthly_Sales_Last_12_Months_SMD_OD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Monthly_Sales_Last_12_Months_SMD_OD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void TopTenAccounts_OD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'TopTenAccounts_OD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void TopTenShipped_OD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'TopTenShipped_OD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Monthly_Sales_Last_12_Months_SMD_WD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Monthly_Sales_Last_12_Months_SMD_WD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void TopTenAccounts_WD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'TopTenAccounts_WD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void TopTenShipped_WD(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'TopTenShipped_WD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	
	
	// Sales Manager Dashboard China/Hong Kong tests
	@isTEst static void BillingAging_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Billing_Aging_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void BillingAging2_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Billing_Aging_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	// starts here
	
	@isTEst static void Activity_Graph_Last_12_Months_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Activity_Graph_Last_12_Months_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Activity_Graph_Last_12_Months_SMD_CHK2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Activity_Graph_Last_12_Months_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Activity_Graph_Last_12_Months_SMD_CHK3(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Activity_Graph_Last_12_Months_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	
	@isTEst static void New_Customers_Last_12_Months_by_Type_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'New_Customers_Last_12_Months_by_Type_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	

		@isTEst static void Company_Total_Pipeline_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Company_Total_Pipeline_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Company_Total_Pipeline_SMD_CHK2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Company_Total_Pipeline_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	// ends here
	@isTEst static void Sales_Reps_Total_Pipeline_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Reps_Total_Pipeline_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Sales_Reps_Total_Pipeline_SMD_CHK2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Reps_Total_Pipeline_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Sales_Reps_Total_Pipeline_SMD_CHK3(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Reps_Total_Pipeline_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void CollectionPerformance_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Collection_Performance_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void MontlySales_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Monthly_Sales_Last_12_Months_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void MontlySales_SMD2_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Monthly_Sales_Last_12_Months_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void CurrentSalesContest_YTD_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Current_Sales_Contest_YTD_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('duration', 'TM');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void CurrentSalesContest_YTD_SMD2_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Current_Sales_Contest_YTD_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('duration', 'TM');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void CurrentSalesContest_QTD_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Current_Sales_Contest_QTD_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void CurrentSalesContest_TM_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Current_Sales_Contest_TM_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Neg_Win_Rate_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Neg_Win_Rate_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Neg_Win_Rate_SMD_CHK2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Neg_Win_Rate_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Win_Rate_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Win_Rate_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Sales_Forecast_Pipeline_By_Lead_Source_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Forecast_Pipeline_By_Lead_Source_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	
	@isTEst static void Team_Quota_YTD_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Team_Quota_YTD_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Team_Quota_Percent_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Team_Quota_Percent_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Active_Opportunities_By_Stage_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Active_Opportunities_By_Stage_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Sales_Forecast_Pipeline_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Forecast_Pipeline_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Lost_Opportunities_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Lost_Opportunities_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Lost_Opportunities_SMD_CHK2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Lost_Opportunities_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Newly_Submitted_Quotes_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Quotes_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Tasks_Completion_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Tasks_Completion_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Neglected_Opportunities_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Neglected_Opportunities_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void New_Leads_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'New_Leads_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();
		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();
		Test.stopTest();
		
	}
	
	@isTEst static void Monthly_Sales_Last_12_Months_SMD_OEM_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Monthly_Sales_Last_12_Months_SMD_OEM_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Monthly_Sales_Last_12_Months_SMD_OEM_CHK2(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Monthly_Sales_Last_12_Months_SMD_OEM_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void Monthly_Sales_Last_12_Months_SMD_OEM_CHK3(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Monthly_Sales_Last_12_Months_SMD_OEM_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}


	@isTEst static void Sales_Pipeline_Last_12_Months(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Pipeline_Last_12_Months');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('chart', 'Sales_Pipeline_Last_12_Months');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc1 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('chart', 'Sales_Pipeline_Last_12_Months');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		Test.stopTest();      
	}
	
	
	@isTEst static void Newly_Submitted_Opportunities_Last_12_Months(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Opportunities_Last_12_Months');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Opportunities_Last_12_Months');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc1 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Opportunities_Last_12_Months');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'month-point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc2 = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Opportunities_Last_12_Months');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		Test.stopTest();      
	}
	
	
	@isTEst static void Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc1 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'month-point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc2 = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		Test.stopTest();      
	}
	
	
	@isTEst static void Lost_Opportunities_Loss_Reasons(){
		
		Test.startTest();

		ApexPages.currentPage().getParameters().put('chart', 'Lost_Opportunities_Loss_Reasons');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc1 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('chart', 'Lost_Opportunities_Loss_Reasons');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'month-point');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc2 = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('chart', 'Lost_Opportunities_Loss_Reasons');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		Test.stopTest();      
	}
	
	
	@isTEst static void Sales_By_Lead_Source_Last_12_Months(){
		
		Test.startTest();

		ApexPages.currentPage().getParameters().put('chart', 'Sales_By_Lead_Source_Last_12_Months');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('chart', 'Sales_By_Lead_Source_Last_12_Months');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc1 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('chart', 'Sales_By_Lead_Source_Last_12_Months');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc2 = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('chart', 'Sales_By_Lead_Source_Last_12_Months');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'left');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		Test.stopTest();      
	}
	
	
	@isTEst static void Sales_Forecast_Pipeline_By_Lead_Source(){
		
		Test.startTest();

		ApexPages.currentPage().getParameters().put('chart', 'Sales_Forecast_Pipeline_By_Lead_Source');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Forecast_Pipeline_By_Lead_Source');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'bar');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc1 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('chart', 'Sales_Forecast_Pipeline_By_Lead_Source');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'legend');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc2 = new ListOfRecordsController();
		
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Forecast_Pipeline_By_Lead_Source');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'left');
		ApexPages.currentPage().getParameters().put('dashboard', 'SD');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		Test.stopTest();      
	}

	
	@isTEst static void TopTenAccounts_SMD_OEM_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'TopTenAccounts_SMD_OEM_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}
	@isTEst static void TopTenShipped_SMD_OEM_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'TopTenShipped_SMD_OEM_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ListOfRecordsController sdc = new ListOfRecordsController();
		Test.stopTest();
		
	}

	@isTEst static void Total_Pipeline_By_Lead_Source_SMD_USA(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Total_Pipeline_By_Lead_Source_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	
	@isTEst static void Total_Pipeline_By_Lead_Source_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Total_Pipeline_By_Lead_Source_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	
	
	@isTEst static void Newly_Submitted_Opportunities_Last_12_Months_SMD_USA(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Opportunities_Last_12_Months_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	

	@isTEst static void Newly_Submitted_Opportunities_Last_12_Months_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Opportunities_Last_12_Months_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	
	@isTEst static void Sales_By_Lead_Source_Last_12_Months_SMD_USA(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_By_Lead_Source_Last_12_Months_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Company_PreOrder_Pipeline_SMD_USATest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Company_PreOrder_Pipeline_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();


		ApexPages.currentPage().getParameters().put('click', 'poin');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Sales_Reps_PreOrder_Pipeline_SMD_USATest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Reps_PreOrder_Pipeline_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'poin');
		ApexPages.currentPage().getParameters().put('str', 'test');
		ListOfRecordsController sdc = new ListOfRecordsController();


		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void PreOrder_Pipeline_By_Lead_Source_SMD_USATest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'PreOrder_Pipeline_By_Lead_Source_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'poin');
		ApexPages.currentPage().getParameters().put('str', 'test');
		ListOfRecordsController sdc = new ListOfRecordsController();


		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Company_Negotiation_Pipeline_SMD_USATest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Company_Negotiation_Pipeline_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'poin');
		ApexPages.currentPage().getParameters().put('str', 'test');
		ListOfRecordsController sdc = new ListOfRecordsController();


		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Sales_Reps_Negotiation_Pipeline_SMD_USATest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Reps_Negotiation_Pipeline_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'poin');
		ApexPages.currentPage().getParameters().put('str', 'test');
		ListOfRecordsController sdc = new ListOfRecordsController();


		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Negotiation_Pipeline_By_Lead_Source_SMD_USATest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Negotiation_Pipeline_By_Lead_Source_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'poin');
		ApexPages.currentPage().getParameters().put('str', 'test');
		ListOfRecordsController sdc = new ListOfRecordsController();


		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Monthly_Sales_Last_12_Months_Spec_SMD_HTest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Monthly_Sales_Last_12_Months_Spec_SMD_H');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'poin');
		ApexPages.currentPage().getParameters().put('str', 'test');
		ListOfRecordsController sdc = new ListOfRecordsController();


		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Spec_Pre_Order_Pipeline_SMD_USATest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Spec_Pre_Order_Pipeline_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'poin');
		ApexPages.currentPage().getParameters().put('str', 'test');
		ListOfRecordsController sdc = new ListOfRecordsController();


		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Sales_Forecast_Pre_Order_Pipeline_SMDTest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Forecast_Pre_Order_Pipeline_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'poin');
		ApexPages.currentPage().getParameters().put('str', 'test');
		ListOfRecordsController sdc = new ListOfRecordsController();


		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Monthly_Sales_Last_12_Months_Refferral_HTest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Monthly_Sales_Last_12_Months_Refferral_H');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'poin');
		ApexPages.currentPage().getParameters().put('str', 'test');
		ListOfRecordsController sdc = new ListOfRecordsController();


		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Ref_Reps_Total_Pipeline_SMD_USATest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Ref_Reps_Total_Pipeline_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'poin');
		ApexPages.currentPage().getParameters().put('str', 'test');
		ListOfRecordsController sdc = new ListOfRecordsController();


		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Sales_Forecast_Reff_Pipeline_SMDTest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Forecast_Reff_Pipeline_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'poin');
		ApexPages.currentPage().getParameters().put('str', 'test');
		ListOfRecordsController sdc = new ListOfRecordsController();


		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	

	@isTEst static void Sales_By_Lead_Source_Last_12_Months_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_By_Lead_Source_Last_12_Months_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}

	@isTEst static void Loss_Reasons_SMD_USA(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Loss_Reasons_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	
	@isTEst static void Sales_Reps_Total_Pipeline_Manuf_USATest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Reps_Total_Pipeline_Manuf_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Sales_Forecast_Pipeline_Manuf_SMDTest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Sales_Forecast_Pipeline_Manuf_SMD');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Company_Total_Pipeline_Specified_SMD_USATest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Company_Total_Pipeline_Specified_SMD_USATest');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Pipeline_By_Specified_SMD_USATest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Pipeline_By_Specified_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Newly_Submitted_Opportunities_Last_12_Months_SpecifiedTest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Opportunities_Last_12_Months_Specified');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Lost_Opportunities_SpecifiedTest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Lost_Opportunities_Specified');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Win_Rate_SpecifiedTest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Win_Rate_Specified');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Company_Total_Pipeline_Referral_SMD_USATest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Company_Total_Pipeline_Referral_SMD_USA');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Referral_Pipeline_Last_12_Monthtest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Referral_Pipeline_Last_12_Month');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Newly_Submitted_Referral_Opportunities_Last_12_MonthTest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Referral_Opportunities_Last_12_Month');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Lost_Opportunities_ReferrallTest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Lost_Opportunities_Referrall');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Win_Rate_ReferrallTest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Lost_Opportunities_Referrall');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	
	@isTEst static void Loss_Reasons_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Loss_Reasons_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	
	@isTEst static void Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source_SMD_CHK(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source_SMD_CHK');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_CHK');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'bar');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void Monthly_Sales_Last_12_Month_by_Lead_SourceTest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'Monthly_Sales_Last_12_Month_by_Lead_Source');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'point');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void MonthlySalesLast12MonthsbyOwnerTest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'MonthlySalesLast12MonthsbyOwner');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'point');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
	@isTEst static void MonthlySalesLast12MonthBySalesRepTeamTest(){
		
		Test.startTest();
		ApexPages.currentPage().getParameters().put('chart', 'MonthlySalesLast12MonthBySalesRepTeam');
		ApexPages.currentPage().getParameters().put('Title', 'Example');
		ApexPages.currentPage().getParameters().put('dashboard', 'SMD_USA');
		ApexPages.currentPage().getParameters().put('click', 'chart');
		ListOfRecordsController sdc = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'point');
		ListOfRecordsController sdc2 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'legend');
		ListOfRecordsController sdc3 = new ListOfRecordsController();

		ApexPages.currentPage().getParameters().put('click', 'left');
		ListOfRecordsController sdc4 = new ListOfRecordsController();

		Test.stopTest();
		
	}
    
    @isTest static void MethodInvokes(){
        
        ListOfRecordsController ctrl = new ListOfRecordsController();
        
        ctrl.getAccounts();
        ctrl.getBillings();
        ctrl.getLeads();
        ctrl.getOpportunities();
        ctrl.getOrders();
        ctrl.UserData_From_Teams('House Account');
        ctrl.UserIds_From_Teams('House Account');
        ctrl.CheckUser(UserInfo.getUserId(), UserInfo.getUserId());
    }

	
	@isTest
	public static void heplerCoverage(){
		ListOfRecordsControllerHelper.coverage();
	}
}
@isTest
public class OpportunityPageExtensionTest {
    
    @testSetup static void createData(){
       
         //Profile pf = [Select Id from profile where Name = 'China Inside Sales Rep']; 
        //Profile pf = [Select Id from profile where Name = 'System Administrator']; 
        //Profile pf = [Select Id from profile where Name = 'Sales Rep'];
         
        String orgId = UserInfo.getOrganizationId(); 
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName = orgId + dateString + RandomId; 
        
        //User uu1 = new User(firstname = 'ABC', 
          //                   lastName = 'XYZ', 
            //                 email = uniqueName + '@test' + orgId + '.org', 
              //               Username = uniqueName + '@test' + orgId + '.org', 
                //             EmailEncodingKey = 'ISO-8859-1', 
                  //           Alias = uniqueName.substring(18, 23), 
                    //         TimeZoneSidKey = 'America/Los_Angeles', 
                      //       LocaleSidKey = 'en_US', 
                        //     LanguageLocaleKey = 'en_US', 
                          //   ProfileId = pf.Id
                            //); 

        //insert uu1;
        
        //Sales_rep__c sr = new Sales_rep__c();
        //sr.Active__c = 'Yes';
        //sr.Name = 'John Doe';
        //sr.User__c = uu1.id;
        
        //insert sr;
        
        //uu1.Sales_Rep_Id__c = sr.id;
        
        //update uu1;
        
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        // create account
        Account acct = new Account();
        //acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct;
		
        // create contact
        Contact cont = new Contact();
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.LeadSource = 'AAOHA 2020';
        cont.GL_Account_Variable_1__c = accVar.Id;
        insert cont;
        
        Contact cont2 = new Contact();
        cont2.LastName = 'myLastName2';
        cont2.AccountId = acct.Id;
        cont2.LeadSource = 'Customer Event';
        cont2.GL_Account_Variable_1__c = accVar.Id;
        insert cont2;        
        
        // create product
        Product2 prod = new Product2();
        
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = accVar.Id;
        insert aegl;
        
        prod.Name = 'myProduct';
        prod.ProductCode = 'ABC123';
        prod.AcctSeed__Unit_Cost__c = 100;
        prod.IsActive = true;
        prod.AcctSeed__Inventory_Type__c = 'Purchased';
        prod.AcctSeed__Expense_GL_Account__c = aegl.id;
        prod.AcctSeed__Inventory_GL_Account__c = aegl.id;
        prod.AcctSeed__Revenue_GL_Account__c = aegl.id;
        //prod.Type__c = 'Product';
        insert prod;
        
        // create opportunity
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        //opp.Sales_Rep_O__c = sr.id;
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Follow up';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = accVar.Id;
        opp.Run_Validation_Rule__c = true;
        insert opp;
        
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
        
        // create a sales order
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c(); 
        
        //salesorder.name = 'testSalesOrder';
        salesorder.AcctSeedERP__Customer__c = acct.Id;
        salesorder.AcctSeedERP__Opportunity__c = opp.Id;
        salesorder.Contact__c = cont.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
       	salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.GL_Account_Variable_1__c = accVar.Id;
        insert salesorder;
        
    }
    
    @isTest static void StartProcess(){
        Opportunity opp = [select id,Name, Account.name,LastModifiedDate,
                           LastViewedDate,LastReferencedDate,Show_Account_Message__c,Show_Contact_Message__c,
                           Show_Opportunity_Message__c,
                           ContactPerson__r.Name, ContactPerson__c from opportunity where name='myOpportunity' limit 1];
        
        //acctseederp__sales_order__c so = [select id from acctseederp__sales_order__c 
                                         // where acctseederp__opportunity__c =:opp.id limit 1];
        
        acctseederp__sales_order__c Newso = [select id,name,AcctSeedERP__Status__c,
                                             Stage__c, Status_Helper__c,Stage_Helper__c,
                                             Show_SalesOrder_Message__c from acctseederp__sales_order__c 
                                             where acctseederp__opportunity__c =:opp.id limit 1];
        
        acctseederp__sales_order__c Newwso = [select id,name,AcctSeedERP__Status__c,
                                          Stage__c, Status_Helper__c,Stage_Helper__c,
                                          Show_SalesOrder_Message__c from acctseederp__sales_order__c 
                                          where acctseederp__opportunity__c =:opp.id limit 1];
        
 		// Create attachments 
 		Attachment One = new Attachment();    
        One.Name = 'Attachment One';
        One.Body = Blob.valueOf('Sample Text.');
		One.ParentId = opp.id;
        insert One;
        
        test.startTest();
		        
        PageReference pageRef = Page.OpportunityPage;
        Test.setCurrentPage(pageRef);
		
        ApexPages.currentPage().getParameters().put('id', opp.id);
        
        ApexPages.StandardController std = new ApexPages.StandardController(opp);
        
        OpportunityPageExtension op = new OpportunityPageExtension(std);
        
        Attachment Two = new Attachment();
        Two.Name = 'Attachment Two';
        Two.Body = Blob.valueOf('Test Text.');
        Two.ParentId = Newso.id;
        insert Two;
        
        OpportunityPageExtension ope = new OpportunityPageExtension(std);
        
        delete Newso;
        
        // sorting test
        
        // ------------title
        ApexPages.currentPage().getParameters().put('sort', 'title');
        ope.checkSort();
		
        ope.TitleSortUp = false;
        ope.sortProcess = 'DESC';
        ApexPages.currentPage().getParameters().put('sort', 'title');
        ope.checkSort();
       
        // ---------created
        ApexPages.currentPage().getParameters().put('sort', 'created');
        ope.checkSort();
        
        ope.CreatedSortUp = false;
        ope.sortProcess = 'DESC';
        ApexPages.currentPage().getParameters().put('sort', 'created');
        ope.checkSort();
        
        // -------------last
        ApexPages.currentPage().getParameters().put('sort', 'last');
        ope.checkSort();
        
        ope.LastSortUp = false;
        ope.sortProcess = 'DESC';
        ApexPages.currentPage().getParameters().put('sort', 'last');
        ope.checkSort();
        
        // -------------- by
        ApexPages.currentPage().getParameters().put('sort', 'by');
        ope.checkSort();
        
        ope.BySortUp = false;
        ope.sortProcess = 'DESC';
        ApexPages.currentPage().getParameters().put('sort', 'by');
        ope.checkSort();
        
        ope.newAttachment();
        
        ApexPages.currentPage().getParameters().put('viewId', One.id);
        ope.viewAttachment();
        
        ApexPages.currentPage().getParameters().put('editId', Two.id);
        ope.editAttachment();
        
        ApexPages.currentPage().getParameters().put('deleteId', Two.id);
        ope.deleteAttachment();
        
        // for opportunity page
        
        Task firstTask = new task();
        
        firstTask.subject = 'sample task';
        firstTask.description = 'sample description';
        firstTask.WhatId =     opp.Id;    
        insert firstTask;
        
        // log a call
        ope.logCall();
        ope.mailMerge();
        ope.viewAll();
        ope.sendAnEmail();
        ope.ChangedMessage();
        ope.hideAccountChangeMessage();
        ope.hideContactChangeMessage();
        
        // editActivity test
        ApexPages.currentPage().getParameters().put('editActivityId', firstTask.id);
        ope.editActivity();
        
        // gotoActivity test
        ApexPages.currentPage().getParameters().put('gotoActivityId', firstTask.id);
        ope.gotoActivity();
        
        // editActivity test
        ApexPages.currentPage().getParameters().put('deleteActivityId', firstTask.id);
        ope.deleteActivity();
        ope.ResetFields();
        ope.hideOpportunityChangeMessage();
 		test.stopTest();
    }
    
}
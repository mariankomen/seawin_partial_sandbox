@isTest
public class EditProjectExtensionTest {
    
    @testSetup static void createData(){
        //testutility.createdata();
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'Seawin USA';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;

        Profile profile = [Select Id From Profile where Name = 'System Administrator' limit 1];
        // Profile pf = [Select Id from profile where Name = 'Sales Rep'];
        
        String orgId = UserInfo.getOrganizationId(); 
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName = orgId + dateString + RandomId; 
        
        User uu1 = new User(firstname = 'ABC', 
                             lastName = 'XYZ', 
                             email = uniqueName + '@test' + orgId + '.org', 
                             Username = uniqueName + '@test' + orgId + '.org', 
                             EmailEncodingKey = 'ISO-8859-1', 
                             Alias = uniqueName.substring(18, 23), 
                             TimeZoneSidKey = 'America/Los_Angeles', 
                             LocaleSidKey = 'en_US', 
                             LanguageLocaleKey = 'en_US', 
                             ProfileId = profile.Id
                            ); 

        insert uu1;
        
        Account acct = new Account();
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
       	acct.AcctSeed__Billing_Terms_Name__c = 'Example terms';
       	insert acct;
        
        Contact cont = new Contact();
       	cont.LastName = 'myLastName';
       	cont.AccountId = acct.Id;
       	insert cont;
    
        Opportunity opt = new Opportunity();
        opt.Name = 'myOpportunity';
       	opt.AccountId = acct.Id;
       	opt.Type = 'Actual Order';
       	opt.StageName = 'Closed Won';
       	opt.CloseDate = system.today();
       	opt.ContactPerson__c = cont.Id;
       	opt.GL_Account_Variable_1__c = accVar.Id;
       	
       	insert opt;
                
        
        AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();
        
        abf.Name = 'newPDF Format';
        abf.AcctSeed__Type__c = 'Purchase Order';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        insert abf;
        
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        gl.name = 'GL Account First';
        gl.AcctSeed__type__c = 'Balance Sheet';
        gl.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl.AcctSeed__Bank__c = true;
        gl.GL_Account_Variable_1__c = accVar.Id;
        insert gl;
        
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
        ledger.Name = 'myLedger';
        ledger.AcctSeed__Type__c = 'Transactional';
        ledger.AcctSeed__Billing_Activity_Statement_Format__c = abf.id;
        ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = abf.id;
        ledger.AcctSeed__Default_Bank_Account__c = gl.id;
        ledger.AcctSeed__Default_Billing_Format__c = abf.id;
		ledger.AcctSeed__Default_Purchase_Order_Format__c = abf.id;
		ledger.AcctSeed__Default_Packing_Slip_Format__c = abf.id;
        insert ledger;
        
        Id RecordTypeIdSO = Schema.SObjectType.AcctSeedERP__Sales_Order__c.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
        
		AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c();
        salesorder.AcctSeedERP__Customer__c = acct.Id;
        salesorder.AcctSeedERP__Opportunity__c = opt.Id;
        salesorder.Contact__c = cont.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
       	salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.GL_Account_Variable_1__c = accVar.id;
        salesorder.Stage__c = 'Production';
        salesorder.RecordTypeId = RecordTypeIdSO;
        insert salesorder;

        acctseederp__purchase_order__c po = new acctseederp__purchase_order__c();
        po.AcctSeedERP__Order_Date__c = date.today();
        po.AcctSeedERP__Status__c = 'Open';
        po.AcctSeedERP__Type__c = 'Drop Shipment';
        po.Stage__c = 'Production';
        po.AcctSeedERP__Purchase_Order_Format__c = abf.Id;
        po.AcctSeedERP__Ledger__c = ledger.Id;
        po.GL_Account_Variable_1__c = accVar.id;
        po.Sales_Order__c = salesorder.id;
        po.AcctSeedERP__Vendor_Contact__c = cont.id;
        po.AcctSeedERP__Vendor__c = acct.Id;
        insert po;
    }
    
    @isTest static void TestWithoutContactandAccount(){
        
        Account acct = [select id from Account where name = 'myAccount' limit 1];
        Contact ct = [select id from contact where lastname = 'myLastName' limit 1];
        Opportunity opp = [select id from opportunity where name='myOpportunity' limit 1];
        
        acctseederp__sales_order__c so = [select id,AcctSeederp__status__c from acctseederp__sales_order__c 
                                          where acctseederp__opportunity__c =:opp.id limit 1];
        
        Acctseed__project__c p = new Acctseed__project__c();
        p.name = 'myProject';
        p.AcctSeed__Status__c = 'Closed';
        insert p;
        
        PageReference pageRef = Page.EditProjectPage;
        Test.setCurrentPage(pageRef);
        
        Apexpages.currentPage().getParameters().put('retUrl', opp.id);
        
        apexpages.StandardController std = new apexpages.StandardController(p);
        
        EditProjectExtension epe = new EditProjectExtension(std);
        
        epe.saveRecord();
        epe.cancelOperation();
    }
    
    @isTest static void WithOpen(){
    
        Account acct = [select id from Account where name = 'myAccount' limit 1];
		Contact ct = [select id from contact where lastname = 'myLastName' limit 1];
        Opportunity opp = [select id, StageName from opportunity where name='myOpportunity' limit 1];

		acctseederp__sales_order__c so = [select id, project__c from acctseederp__sales_order__c 
                                          where acctseederp__opportunity__c =:opp.id limit 1];
        
        acctseederp__purchase_order__c po = [select id, project__c from acctseederp__purchase_order__c 
                                          where sales_order__c =:so.id limit 1];
        
        Acctseed__ledger__c ledger = [select id from AcctSeed__ledger__c where name = 'myLedger' limit 1];        
		
        Acctseed__project__c p = new Acctseed__project__c();    
        p.name = 'myProject2';
        p.AcctSeed__Account__c = acct.id;
        p.AcctSeed__Status__c = 'Closed';
        insert p;
        
        so.project__c = p.id;
        update so;
        
        // if(opp.StageName != 'Closed Won' || opp.StageName != 'Closed Lost'){
        //     opp.Project__c = p.id;
        
        //     update opp;
        // }
        
        
        po.Project__c = p.id;
        
        update po;
        
        PageReference pageRef = Page.EditProjectPage;
        Test.setCurrentPage(pageRef);
        
        Apexpages.currentPage().getParameters().put('retUrl', opp.id);
        
        apexpages.StandardController std = new apexpages.StandardController(p);
        
        EditProjectExtension epe = new EditProjectExtension(std);
        
        epe.saveRecord();
        epe.cancelOperation();
        
        
    }

    @isTest static void WithClosed(){
        AcctSeed__Accounting_Variable__c accVar = [SELECT Id FROM AcctSeed__Accounting_Variable__c WHERE Name='Seawin USA' LIMIT 1];
        Account acct = [select id from Account where name = 'myAccount' limit 1];
        Contact ct = [select id from contact where lastname = 'myLastName' limit 1];

        Acctseed__ledger__c ledger = [select id from AcctSeed__ledger__c where name = 'myLedger' limit 1];
        
        Acctseed__project__c p = new Acctseed__project__c();
        
        p.name = 'myProject3';
        p.AcctSeed__Account__c = acct.id;
        p.AcctSeed__Status__c = 'Closed';
        
        insert p;
        
        // create new opportunity
        Opportunity opt = new Opportunity();
        
        opt.Name = 'myOpportunity';
        opt.AccountId = acct.Id;
        opt.Type = 'Actual Order';
        opt.StageName = 'Closed Won';
        opt.CloseDate = system.today();
        opt.ContactPerson__c = ct.Id;
        opt.GL_Account_Variable_1__c = accVar.Id;
        insert opt;
        
        // sales order
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c(); 
        
        //salesorder.name = 'testSalesOrder';
        salesorder.AcctSeedERP__Customer__c = acct.Id;
        salesorder.AcctSeedERP__Opportunity__c = opt.Id;
        salesorder.Contact__c = ct.Id;
        salesorder.AcctSeedERP__Status__c = 'Closed';
        salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.AcctSeedERP__Shipping_City__c='Rawalpindi';
        salesorder.AcctSeedERP__Shipping_Country__c='Pakistan';
        salesorder.AcctSeedERP__Shipping_PostalCode__c='46000';
        salesorder.AcctSeedERP__Shipping_State__c='Punjab';
        salesorder.AcctSeedERP__Shipping_Street__c='Satellite Town';
        salesorder.AcctSeedERP__Billing_Country__c='Afghanistan';
        salesorder.AcctSeedERP__Billing_PostalCode__c='12345';
        salesorder.AcctSeedERP__Billing_State__c='Kabul';
        salesorder.AcctSeedERP__Billing_Street__c='Lake view';
        salesorder.AcctSeedERP__Billing_City__c='Kabul';
        salesorder.GL_Account_Variable_1__c = accVar.Id;
        
        insert salesorder;
        
        AcctSeed__Billing_Format__c abf = [select id from AcctSeed__Billing_Format__c
                                          where name='newPDF Format' limit 1];
        
        acctseederp__purchase_order__c po2 = new acctseederp__purchase_order__c();
        
        po2.AcctSeedERP__Order_Date__c = date.today();
        po2.AcctSeedERP__Status__c = 'Closed';
        po2.AcctSeedERP__Type__c = 'Standard';
        po2.AcctSeedERP__Purchase_Order_Format__c = abf.Id;
        po2.AcctSeedERP__Ledger__c = ledger.Id;
        po2.Sales_Order__c = salesorder.id;
        po2.GL_Account_Variable_1__c = accVar.Id;
        insert po2;
        
        Test.startTest();
        
        PageReference pageRef = Page.EditProjectPage;
        Test.setCurrentPage(pageRef);
        
        Apexpages.currentPage().getParameters().put('retUrl', opt.id);
        
        apexpages.StandardController std = new apexpages.StandardController(p);
        
        EditProjectExtension epe = new EditProjectExtension(std);
                
        epe.saveRecord();
        epe.cancelOperation();
        
        Test.stopTest();
        
    }
    
}
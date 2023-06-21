@isTest
public class AddPurchaseOrderPageExtensionTest {
    
    @isTest static void runTests(){
        
        Profile pf = [Select Id from profile where Name = 'System Administrator']; 
        
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
                            ProfileId = pf.Id
                           ); 
        
        insert uu1;
        
        
        // accounting  variable
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        // create account
        Account acct = new Account();
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
        
        // billing format
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
        
        
        // gl account
        list<AcctSeed__GL_Account__c> glList = new list<AcctSeed__GL_Account__c>();
        
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();  
        gl.name = 'GL Account First';
        gl.AcctSeed__type__c = 'Balance Sheet';
        gl.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl.AcctSeed__Active__c = true;
        gl.GL_Account_Variable_1__c = accVar.id;        
        glList.add(gl);
        
        // ledger creation
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = accVar.id;
        glList.add(aegl);
        
        insert glList;
        
        
        // ledger
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
        
        // create purchase order        
        acctseederp__purchase_order__c po = new acctseederp__purchase_order__c();
        po.AcctSeedERP__Order_Date__c = date.today();
        po.AcctSeedERP__Status__c = 'Open';
        po.AcctSeedERP__Type__c = 'Drop Shipment';
        po.AcctSeedERP__Ledger__c = ledger.id;
        po.AcctSeedERP__Purchase_Order_Format__c = abfList[0].Id;
        po.GL_Account_Variable_1__c = accVar.id;
        po.AcctSeedERP__Vendor_Contact__c = cont.id;
        po.AcctSeedERP__Vendor__c = acct.id;
        po.RecordTypeId = '0121I000000JpfGQAS';
        insert po;
        
        test.startTest();
        
        //ApexPages.currentPage().getParameters().put('RecordType', po.RecordTypeId);
       // ApexPages.currentPage().getParameters().put('glAccVar1Id', 'a0A1I000002Rti4UAC');
        //ApexPages.currentPage().getParameters().put('soId', 'a1H04000000CgIO');
        //ApexPages.currentPage().getParameters().put('poFormatId', po.AcctSeedERP__Purchase_Order_Format__c);
        //ApexPages.currentPage().getParameters().put('relatedOppId', opp.Id);
       //ApexPages.currentPage().getParameters().put('shipngCompanyId', po.AcctSeedERP__Shipping_Company__c);
        ApexPages.currentPage().getParameters().put('shipngContactId', po.AcctSeedERP__Shipping_Contact__c);
        ApexPages.currentPage().getParameters().put('projectId', po.Project__c);
        ApexPages.currentPage().getParameters().put('shpngStreet', po.AcctSeedERP__Shipping_Street__c);
        ApexPages.currentPage().getParameters().put('shipngCity', po.AcctSeedERP__Shipping_City__c);
        ApexPages.currentPage().getParameters().put('shipngStat', po.AcctSeedERP__Shipping_State__c);
        ApexPages.currentPage().getParameters().put('shipngPostalCode', po.AcctSeedERP__Shipping_Postal_Code__c);
        ApexPages.currentPage().getParameters().put('shipngCountry', po.AcctSeedERP__Shipping_Country__c);
        
        APexPages.StandardController std = new ApexPages.StandardController(po);  
        AddPurchaseOrderPageExtension apop = new AddPurchaseOrderPageExtension(std);
        
        apop.pageAction();
        apop.getGLAccountVariableForUser(uu1.Id);
        apop.getGLAccountVariableForUser(UserInfo.getUserId());
        Account accnt = AddPurchaseOrderPageExtension.getAccount(acct.Id);
        Contact contct = AddPurchaseOrderPageExtension.getContact(acct.Id);
        apop.saveOverride();
        
        //AddPurchaseOrderPageExtension.getAccount(acctList[0].id);
        //AddPurchaseOrderPageExtension.getContact(acctList[0].id);
        
        test.stopTest();
        
    }
    
}
/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 08-04-2023
 * @last modified by  : Marian Lyzhychka
**/
@isTest
public with sharing class OpportunityDetailPageControllerTest {
    
    @TestSetup
    static void makeData(){
        Profile pf = [Select Id from profile where Name = 'System Administrator']; 

        String orgId = UserInfo.getOrganizationId(); 
        String dateString2 = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId2 = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName2 = orgId + dateString2 + RandomId2; 
        
        User uu2 = new User(firstname = 'ABCd', 
                             lastName = 'XYZ1', 
                             email = uniqueName2 + '@test' + orgId + '.org', 
                             Username = uniqueName2 + '@test' + orgId + '.org', 
                             EmailEncodingKey = 'ISO-8859-1', 
                             Alias = uniqueName2.substring(18, 23), 
                             TimeZoneSidKey = 'America/Los_Angeles', 
                             LocaleSidKey = 'en_US', 
                             LanguageLocaleKey = 'en_US', 
                             ProfileId = pf.Id
                            ); 
        insert uu2;

        Sales_rep__c sr = new Sales_rep__c();  
        sr.Name = 'ABC XYZ';
        sr.User__c = uu2.id;
        sr.Active__c = 'Yes';
        sr.Team__c = uu2.id;       

        insert sr;
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

        Attachment attach = new Attachment();   	
    	attach.Name = 'Unit Test Attachment';
    	Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
    	attach.body = bodyBlob;
        attach.parentId = opp.id;
        attach.Description = 'Test';

        insert attach;


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

        Opportunity opp2 = new Opportunity();

        opp2.Name = 'Closed Won Opportunity';
        opp2.AccountId = acct.Id;
        opp2.Type = 'Actual Order';
        opp2.StageName = 'Closed Won';
        opp2.CloseDate = system.today();
        opp2.ContactPerson__c = cont.Id;
        opp2.GL_Account_Variable_1__c = accVar.Id;
        opp2.Run_Validation_Rule__c = true;
        opp2.sales_rep_o__c = sr.Id;
        insert opp2;

        OpportunityLineItem oli2 = new OpportunityLineItem();

        oli2.OpportunityId = opp2.Id;
        oli2.Product2Id = prod.Id;
        oli2.PricebookEntryId = pricebentry.Id;
        oli2.Quantity = 10;
        oli2.UnitPrice = 100;
        oli2.Description = 'myDescription';

        insert oli2;


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

        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c();
        
        //salesorder.name = 'testSalesOrder';
        salesorder.RecordTypeId = RecordTypeIdSO;
        salesorder.AcctSeedERP__Customer__c = acct.Id;
        salesorder.AcctSeedERP__Opportunity__c = opp.Id;
        //salesorder.Manufacturer_Rep__c = acct2.id;
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

    }

    @isTest
    static void getSobjectTypeTest(){
        AcctSeed__Ledger__c l = [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
        OpportunityDetailPageController.getSobjectType(l.Id);
    }

    @isTest
    static void getOpportunitySubStagesTest(){
        OpportunityDetailPageController.getOpportunitySubStages();
    }

    @isTest
    static void getOpportunityTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        OpportunityDetailPageController.getOpportunity(opp.Id);
    }

    @isTest
    static void getOpportunityStageValuesTest(){
        OpportunityDetailPageController.getOpportunityStageValues();
    }
    @isTest
    static void getOpportunityRecordTypesTest(){
        OpportunityDetailPageController.getOpportunityRecordTypes();
    }

    @isTest
    static void getPreparedLineForBillingOpportunityTest(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name='myOpportunity' LIMIT 1];

        OpportunityDetailPageController.getPreparedLineForBilling('Opportunity', opp.Id);
    }

    @isTest
    static void getPreparedLineForBillingSalesOrderTest(){
        AcctSeedERP__Sales_Order__c so = [SELECT Id FROM AcctSeedERP__Sales_Order__c LIMIT 1];

        OpportunityDetailPageController.getPreparedLineForBilling('Sales Order', so.Id);
    }

    @isTest
    static void createBillingOpportunityTest(){
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name='myOpportunity' LIMIT 1];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId=:opp.Id];
        AcctSeed__Ledger__c ledger = [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
        AcctSeed__Billing_Format__c bf = [SELECT Id FROM AcctSeed__Billing_Format__c LIMIT 1];

        List<OpportunityDetailPageService.CreateBillingLinesWrapper> wp = new List<OpportunityDetailPageService.CreateBillingLinesWrapper>{
            new OpportunityDetailPageService.CreateBillingLinesWrapper(
                oli.Id,
                1
            )
        };
        OpportunityDetailPageService.CreateBillingWrapper wrapper = new OpportunityDetailPageService.CreateBillingWrapper(
            opp.Id,
            system.today(),
            system.today(),
            ledger.Id,
            bf.Id,
            wp
        );

        OpportunityDetailPageController.createBilling(JSON.serialize(wrapper));
        Test.stopTest();
    }

    @isTest
    static void getAccountTest(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        OpportunityDetailPageController.getAccount(acc.Id);
        Test.stopTest();
    }
    @isTest
    static void getOpportunityLineItemsTest(){
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        OpportunityDetailPageController.getOpportunityLineItems(opp.Id);
        Test.stopTest();
    }
    @isTest
    static void deleteSObjectListTest(){
        Test.startTest();
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        List<Id> oliId = new List<Id>{oli.Id};
        OpportunityDetailPageController.deleteSObjectList(JSON.serialize(oliId));
        Test.stopTest();
    }

    @isTest
    static void getOptionalOpportunityLinesTest(){
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        OpportunityDetailPageController.getOptionalOpportunityLines(opp.Id);
        Test.stopTest();
    }

    @isTest
    static void getOpportunityAttachmentsTest(){
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        OpportunityDetailPageController.getOpportunityAttachments(opp.Id);
        Test.stopTest();
    }
    @isTest
    static void getPredefinedSalesOrderDataTest(){
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name='Closed Won Opportunity' LIMIT 1];
        try{
            OpportunityDetailPageController.getPredefinedSalesOrderData(opp.Id);
        }catch(Exception e){
        }
        Test.stopTest();
    }
    @isTest
    static void createSalesOrderTest(){
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name='Closed Won Opportunity' LIMIT 1];
        String data = OpportunityDetailPageController.getPredefinedSalesOrderData(opp.Id);

        OpportunityDetailPageService.CreateSalesOrderPreWrapper wrap = (OpportunityDetailPageService.CreateSalesOrderPreWrapper)JSON.deserialize(data, OpportunityDetailPageService.CreateSalesOrderPreWrapper.class);
        wrap.selectedGlVarId = wrap.glVariable.Id;
        wrap.selectedLedgerId = wrap.ledgers[0].Id;
        OpportunityDetailPageController.createSalesOrder(JSON.serialize(wrap), opp.Id);
        Test.stopTest();
    }

    @isTest
    static void getAttachmentRecordTets(){
        Test.startTest();
        Attachment att = [SELECT Id, Description FROM Attachment LIMIT 1];
        OpportunityDetailPageController.getAttachmentRecord(att.Id);
        Test.stopTest();
    }

    @isTest
    static void updateAttachmentRecordTest(){
        Test.startTest();
        Attachment att = [SELECT Id, Description FROM Attachment LIMIT 1];
        OpportunityDetailPageController.updateAttachmentRecord(JSON.serialize(att));
        Test.stopTest();
    }
    @isTest
    static void transferExecutedDocumentsToAttachmetsTest(){
        Test.startTest();
        List<Attachment> att = [SELECT Id, Description FROM Attachment ];
        OpportunityDetailPageController.transferExecutedDocumentsToAttachmets(JSON.serialize(att));
        Test.stopTest();
    }
    @isTest
    static void transferAttachmentsToExecutedDocumentsTest(){
        Test.startTest();
        List<Attachment> att = [SELECT Id, Description FROM Attachment ];
        OpportunityDetailPageController.transferAttachmentsToExecutedDocuments(JSON.serialize(att));
        Test.stopTest();
    }
}
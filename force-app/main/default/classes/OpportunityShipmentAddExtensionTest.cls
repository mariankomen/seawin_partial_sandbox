@isTest
public class OpportunityShipmentAddExtensionTest {

    @testSetup static void createData(){
         
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
        
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
        Id pricebookId = Test.getStandardPricebookId();
        
        LIST<Opportunity> oppList = new LIST<Opportunity>();
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'myOpportunity';
        opp1.AccountId = acct.Id;
        opp1.Type = 'Actual Order';
        opp1.StageName = 'Closed Won';
        opp1.CloseDate = system.today();
        opp1.ContactPerson__c = cont.Id;
        opp1.GL_Account_Variable_1__c = accVar.id;
        opp1.RecordTypeId = RecordTypeIdOpportunity;
        opp1.Pricebook2Id = pricebookId;
        oppList.Add(opp1);
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'myOpportunity';
        opp2.AccountId = acct.Id;
        opp2.Type = 'Actual Order';
        opp2.StageName = 'Closed Won';
        opp2.CloseDate = system.today();
        opp2.ContactPerson__c = cont.Id;
        opp2.GL_Account_Variable_1__c = accVar.id;
        opp2.RecordTypeId = RecordTypeIdOpportunity;
        opp2.Pricebook2Id = pricebookId;
        oppList.Add(opp2);
        insert oppList;
        
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
        gl.AcctSeed__Active__c = true;
        gl.AcctSeed__Bank__c = true;
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
        
        list<AcctSeedERP__Sales_Order__c> salesorderList = new list<AcctSeedERP__Sales_Order__c>();  
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c(); 
        salesorder.AcctSeedERP__Customer__c = acct.Id;
        salesorder.AcctSeedERP__Opportunity__c = oppList[0].Id;
        salesorder.Contact__c = cont.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
       	salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.GL_Account_Variable_1__c = accVar.id;
        salesorder.Stage__c = 'Production';
        salesorder.RecordTypeId = RecordTypeIdSO;
        salesorderList.add(salesorder);
        
        AcctSeedERP__Sales_Order__c salesorder2 = new AcctSeedERP__Sales_Order__c(); 
        salesorder2.AcctSeedERP__Customer__c = acct.Id;
        salesorder2.AcctSeedERP__Opportunity__c = oppList[0].Id;
        salesorder2.Contact__c = cont.Id;
        salesorder2.AcctSeedERP__Status__c = 'Open';
       	salesorder2.AcctSeedERP__Ledger__c = ledger.id;
        salesorder2.GL_Account_Variable_1__c = accVar.id;
        salesorder2.Stage__c = 'Production';
        salesorder2.RecordTypeId = RecordTypeIdSO;
        salesorderList.add(salesorder2);
        insert salesorderList;
        
        AcctSeed__Billing_Format__c PackingSlipFormat = new AcctSeed__Billing_Format__c();
        PackingSlipFormat.Name = 'Packing Slip Default';
        PackingSlipFormat.AcctSeed__Type__c = 'Packing Slip';
        PackingSlipFormat.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        PackingSlipFormat.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        insert PackingSlipFormat; 
        
        Opportunity_Shipment__c shipment = new Opportunity_Shipment__c();
        shipment.Opportunity__c = oppList[0].Id;
        shipment.Shipment_Date__c = Date.today();
        shipment.Status__c = 'Scheduled';
        insert shipment;
        
         
    }
    
    @isTest static void StartProcess(){
        
        LIST<Opportunity> oppList = [select id,name from Opportunity
                                     where name = 'myOpportunity' limit 2];
        
        AcctSeedERP__Sales_Order__c so = [select id from AcctSeedERP__Sales_Order__c
                                          where AcctSeedERP__Opportunity__c =: oppList[0].Id limit 1];
        
        Opportunity_Shipment__c Oppshipmnt = [select id from Opportunity_Shipment__c
                                              where Opportunity__c =: oppList[0].Id limit 1];
        
        test.startTest(); 
        PageReference pageRef = Page.OpportunityShipmentAddPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', Oppshipmnt.id);
        ApexPages.currentPage().getParameters().put('RetURL', 'id='+oppList[0].Id+'&sfdc=1');
        
        ApexPages.StandardController std = new ApexPages.StandardController(Oppshipmnt);
        OpportunityShipmentAddExtension obj = new OpportunityShipmentAddExtension(std);
        
        obj.AddProcess();
        obj.back();
        test.stopTest();
        
    }
    
}
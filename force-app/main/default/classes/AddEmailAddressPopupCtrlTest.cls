@isTest
public class AddEmailAddressPopupCtrlTest {
    
    @testSetup static void createData(){
       
        Profile pf = [Select Id from profile where Name = 'System Administrator']; 
        //Profile pf = [Select Id from profile where Name = 'Sales Rep'];
         
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
        
        Sales_rep__c sr = new Sales_rep__c();
        sr.Active__c = 'Yes';
        sr.Name = 'John Doe';
        sr.User__c = uu1.id;
        sr.Email__c = 'azhar.hilbi@gmail.com';
        
        insert sr;
        
        Sales_rep__c sr2 = new Sales_rep__c();
        sr2.Active__c = 'Yes';
        sr2.Name = 'John Doe Junior';
        sr2.User__c = uu1.id;
        sr2.Email__c = 'john.doe@gmail.com';
        
        insert sr2;
        
        uu1.Sales_Rep_Id__c = sr.id;
        
        update uu1;
        
        // create account
        Account acct = new Account();
        
        acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        
        insert acct;
		
        // create contact
        Contact cont = new Contact();
        
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.Email = 'hilbi.azhar@outlook.com';
        
        insert cont;
        
        Contact cont2 = new Contact();
        
        cont2.LastName = 'myLastName2';
        cont2.AccountId = acct.Id;
        cont2.Email = 'hilbi.azhar@gmail.com';
        
        insert cont2;
        
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        
        insert aegl;
        
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
        
        insert opp;
        
        // create pricebook2
        Pricebook2 priceb2 = new Pricebook2();
        
        priceb2.Name = 'myPriceBook';
        priceb2.Description = 'myPBDescription';
        priceb2.IsActive = true;
        //priceb2.IsStandard = true;
        
        insert priceb2;
        
        // insert to standard price book
        Id pricebookId = Test.getStandardPricebookId();
        
        // create standard price book entry
        PricebookEntry pricebentry1 = new PricebookEntry();
        
        pricebentry1.Pricebook2Id = pricebookId;
  		pricebentry1.Product2Id = prod.Id;
        pricebentry1.UnitPrice = 100;
        pricebentry1.IsActive = true;
        
        insert pricebentry1;
        
        // create pricebookentry
        PricebookEntry pricebentry2 = new PricebookEntry();
        
        pricebentry2.Pricebook2Id = priceb2.Id;
  		pricebentry2.Product2Id = prod.Id;
        pricebentry2.UnitPrice = 100;
        pricebentry2.IsActive = true;
        
        insert pricebentry2;
        
        // create opportunity line item
        
        OpportunityLineItem oli = new OpportunityLineItem();
        
        oli.OpportunityId = opp.Id;
        oli.Product2Id = prod.Id;
        oli.PricebookEntryId = pricebentry2.Id;
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

        insert salesorder;
        
        // create a sales order
        List<AcctSeedERP__Sales_Order_Line__c> solineList = new List<AcctSeedERP__Sales_Order_Line__c>();
        
        AcctSeedERP__Sales_Order_Line__c solines = new AcctSeedERP__Sales_Order_Line__c(); 
        
        solines.AcctSeedERP__Sales_Order__c = salesorder.id;
        solines.AcctSeedERP__Unit_Price__c = 1.1;
        solines.AcctSeedERP_Description__c = 'This is salesorder line item';
        solines.AcctSeedERP__Product__c = prod.id;
        solines.AcctSeedERP__Quantity_Ordered__c = 1;
        
        solineList.add(solines);
        
        insert solineList;
        
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'name';
        validEmailTemplate.DeveloperName = 'Shipment_Email_Template';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        
        system.runAs(uu1){
            insert validEmailTemplate;
        }

        AcctSeed__Billing_Format__c packingSlipFormat = new AcctSeed__Billing_Format__c();
        
        packingSlipFormat.Name = 'Default Packing Slip';
        packingSlipFormat.AcctSeed__Type__c = 'Packing Slip';
        packingSlipFormat.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        packingSlipFormat.AcctSeed__Default_Email_Template__c = 'Shipment_Email_Template';
        
        insert packingSlipFormat;
        
        AcctSeedERP__Shipment__c shipment = new AcctSeedERP__Shipment__c();
        
        shipment.AcctSeedERP__Sales_Order__c = salesorder.id;
        shipment.AcctSeedERP__Shipment_Date__c = Date.today();
        shipment.AcctSeedERP__Packing_Slip_Format__c = packingSlipFormat.id;
        
        insert shipment;

    }
    
    @isTest static void StartTestProcess(){
        
        account acct = [select id from account where name='myAccount' limit 1];
        Opportunity opp = [select id from opportunity where name='myOpportunity' limit 1];
        
        acctseederp__sales_order__c so = [select id from acctseederp__sales_order__c 
                                          where acctseederp__opportunity__c =:opp.id limit 1];
        
        // get the sales order lines list
        AcctSeedERP__Shipment__c shipment = [select id,AcctSeedERP__Sales_Order__r.Contact__r.Email,
                                             AcctSeedERP__Packing_Slip_Format__r.AcctSeed__Default_Email_Template__c,
                                             AcctSeedERP__Shipment_Date__c
                                             from AcctSeedERP__Shipment__c where 
                                             AcctSeedERP__Sales_order__c=:so.id limit 1];
        
        contact contct = [select id from contact where lastname='myLastName2' limit 1];
        
        sales_rep__c srep = [select id from sales_rep__c where name='John Doe Junior' limit 1];
        
        PageReference pageRef = Page.AddToRecipientsPopup;
        Test.setCurrentPage(pageRef);
		
        // ApexPages.currentPage().getParameters().put('id', shipment.id);
        
        // ApexPages.StandardController stdset = new ApexPages.StandardController(shipment);
        
        ApexPages.currentPage().getParameters().put('shipmentId', shipment.id);
        ApexPages.currentPage().getParameters().put('AccountId', acct.id);
        ApexPages.currentPage().getParameters().put('existingCc', 'azhar.hilbi@gmail.com;'+contct.id+';'+srep.id);
        ApexPages.currentPage().getParameters().put('existingTo', 'hilbi.azhar@outlook.com;'+srep.id+';'+contct.id);
        ApexPages.currentPage().getParameters().put('completeTo', 'hilbi.azhar@outlook.com;hilbi.azhar@gmail.com');
        ApexPages.currentPage().getParameters().put('completeCc', 'azhar.hilbi@gmail.com;john.doe@gmail.com');
        
        AddEmailAddressPopupCtrl AddEmailAddress = new AddEmailAddressPopupCtrl();
        
        AddEmailAddress.save();
        AddEmailAddress.cancel();

    }
}
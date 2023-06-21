@isTest
public class SalesOrderProjectTriggerTest {
    
    @testSetup static void createData(){
        
        list<AcctSeed__Accounting_Variable__c> avList = new list<AcctSeed__Accounting_Variable__c>();
        
    	avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin China',AcctSeed__Type__c = 'GL Account Variable 1'));
        
        avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1'));
        insert avList;
        
        // Profile pf = [Select Id from profile where Name = 'System Administrator']; 
        Profile pf = [Select Id from profile where Name = 'Sales Rep'];
        
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
        
        insert sr;
        
        uu1.Sales_Rep_Id__c = sr.id;
        
        update uu1;
        
        // create account
        Account acct = new Account();
        
        acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = avList[1].id;
        
        insert acct;
        
        // create contact
        Contact cont = new Contact();
        
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.GL_Account_Variable_1__c = avList[1].id;
        
        insert cont;
        
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        
        insert aegl;
        
        // Gl account with bank unchecked
        AcctSeed__GL_Account__c ga = new AcctSeed__GL_Account__c();
        ga.Name = 'GL Account Test';
        ga.AcctSeed__Active__c = true;
        ga.AcctSeed__Type__c = 'Revenue';
        ga.AcctSeed__Sub_Type_1__c = 'Product Revenue';
        ga.AcctSeed__Sub_Type_2__c = 'Product Family 1';
        ga.AcctSeed__Bank__c = false;
        
        insert ga;
        
        // create product
        Product2 prod = new Product2();
        
        prod.Name = 'myProduct';
        prod.ProductCode = 'ABC123';
        prod.AcctSeed__Unit_Cost__c = 100;
        prod.IsActive = true;
        prod.AcctSeed__Inventory_Type__c = 'Purchased';
        prod.AcctSeed__Expense_GL_Account__c = ga.id;
        prod.AcctSeed__Inventory_GL_Account__c = ga.id;
        prod.AcctSeed__Revenue_GL_Account__c = ga.id;
        
        insert prod;
        
        // create opportunity
        Opportunity opp = new Opportunity();
        
        opp.Name = 'myOpportunity';
        opp.Sales_Rep_O__c = sr.id;
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.GL_Account_Variable_1__c = avList[1].id;
        opp.StageName = 'Closed Won';
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
        
        AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();
        
        abf.Name = 'newPDF Format';
        abf.AcctSeed__Type__c = 'Purchase Order';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        insert abf;
        
        AcctSeed__Billing_Format__c packingSlipFormat = new AcctSeed__Billing_Format__c();
        
        packingSlipFormat.Name = 'newPacking Slip';
        packingSlipFormat.AcctSeed__Type__c = 'Packing Slip';
        packingSlipFormat.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        packingSlipFormat.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        insert packingSlipFormat;
        
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
        
        Acctseed__project__c p = new Acctseed__project__c();
        
        p.name = 'myProject1';
        p.AcctSeed__Account__c = acct.id;
        p.AcctSeed__Opportunity__c = opp.id;
        p.AcctSeed__Status__c = 'Active';
        
        insert p;
        
        // create a sales order
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c(); 
        
        //salesorder.name = 'testSalesOrder';
        salesorder.AcctSeedERP__Customer__c = acct.Id;
        salesorder.AcctSeedERP__Opportunity__c = opp.Id;
        salesorder.Contact__c = cont.Id;
        salesorder.GL_Account_Variable_1__c = avList[1].id;
        salesorder.AcctSeedERP__Status__c = 'Open';
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
        salesorder.Project__c = p.id;
        
        
        insert salesorder;
        
        // create shipments
        AcctSeedERP__Shipment__c shipment = new AcctSeedERP__Shipment__c();
        
        //shipment.name = 'myShipment';
        shipment.AcctSeedERP__Sales_Order__c = salesorder.id;
        shipment.AcctSeedERP__Packing_Slip_Format__c = packingSlipFormat.id;
        insert shipment;
        
        
        
        // create a sales order
        AcctSeedERP__Sales_Order__c salesorder2 = new AcctSeedERP__Sales_Order__c(); 
        
        //salesorder.name = 'testSalesOrder';
        salesorder2.AcctSeedERP__Customer__c = acct.Id;
        salesorder2.AcctSeedERP__Opportunity__c = opp.Id;
        salesorder2.Contact__c = cont.Id;
        salesorder2.AcctSeedERP__Status__c = 'Open';
        salesorder2.AcctSeedERP__Ledger__c = ledger.id;
        salesorder2.GL_Account_Variable_1__c = avList[1].id;
        salesorder2.AcctSeedERP__Shipping_City__c='Rawalpindi';
        salesorder2.AcctSeedERP__Shipping_Country__c='Pakistan';
        salesorder2.AcctSeedERP__Shipping_PostalCode__c='46000';
        salesorder2.AcctSeedERP__Shipping_State__c='Punjab';
        salesorder2.AcctSeedERP__Shipping_Street__c='Satellite Town';
        salesorder2.AcctSeedERP__Billing_Country__c='Afghanistan';
        salesorder2.AcctSeedERP__Billing_PostalCode__c='12345';
        salesorder2.AcctSeedERP__Billing_State__c='Kabul';
        salesorder2.AcctSeedERP__Billing_Street__c='Lake view';
        salesorder2.AcctSeedERP__Billing_City__c='Kabul';
        salesorder2.Project__c = p.id;
        
        
        insert salesorder2;
        
        
        acctseederp__purchase_order__c po = new acctseederp__purchase_order__c();
        
        po.AcctSeedERP__Order_Date__c = date.today();
        po.AcctSeedERP__Status__c = 'Open';
        po.AcctSeedERP__Type__c = 'Standard';
        po.AcctSeedERP__Purchase_Order_Format__c = abf.Id;
        po.GL_Account_Variable_1__c = avList[1].id;
        po.AcctSeedERP__Ledger__c = ledger.Id;
        po.Sales_Order__c = salesorder.id;
        po.Opportunity_Readonly__c = opp.id;
        po.AcctSeedERP__Vendor__c = acct.id;
        
        insert po;
        
    }
    
    @isTest static void StartProcess(){
        
        Account acct = [select id from Account where name = 'myAccount' limit 1];
        Contact ct = [select id from contact where lastname = 'myLastName' limit 1];
        Opportunity opp = [select id from opportunity where name='myOpportunity' limit 1];
        
        list<acctseederp__sales_order__c> so = [select id,project__c from acctseederp__sales_order__c 
                                          where acctseederp__opportunity__c =:opp.id];
        
        Acctseed__project__c p = new Acctseed__project__c();
        
		p.name = 'myProject';
        p.AcctSeed__Account__c = acct.id;
        p.AcctSeed__Opportunity__c = opp.id;
        p.AcctSeed__Status__c = 'Active';
        
        insert p;
        
        
        for(acctseederp__sales_order__c s : so){
            
            s.project__c = p.id;
        }
        
        update so;

    }
}
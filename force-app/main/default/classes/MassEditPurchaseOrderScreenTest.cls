@isTest 
public class MassEditPurchaseOrderScreenTest 
{
    @testsetup static void createdAta(){
        
        //TestUtility.CreateData();
        
		Profile pf = [Select Id From Profile where Name = 'System Administrator' limit 1];
        // Profile profile = [Select Id from profile where Name = 'Sales Rep'];
        
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
        
        Account acct = new Account();
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
       	acct.AcctSeed__Billing_Terms_Name__c = 'Example terms';
       	insert acct;
        
        Contact cont = new Contact();
       	cont.LastName = 'myLastName';
       	cont.AccountId = acct.Id;
       	insert cont;

        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;

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
        
        Product2 prod = new Product2();
        prod.Name = 'myProduct';
        prod.ProductCode = 'ABC123';
        prod.Description = 'myDescription';
        prod.AcctSeed__Unit_Cost__c = 100;
        prod.IsActive = true;
        prod.Category__c = 'Shower Door';
        prod.Sub_Category__c = 'Single Sliding';
        prod.AcctSeed__Inventory_Type__c = 'Purchased';
        prod.AcctSeed__Expense_GL_Account__c = gl.id;
        prod.AcctSeed__Inventory_GL_Account__c = gl.id;
        prod.AcctSeed__Revenue_GL_Account__c = gl.id;
        prod.AcctSeed__Inventory_Product__c = true;
        insert prod;

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
        //salesorder.GL_Account_Variable_1__c = avList[0].id;
        salesorder.Stage__c = 'Production';
        salesorder.RecordTypeId = RecordTypeIdSO;
        salesorder.GL_Account_Variable_1__c = accVar.Id;
        //salesorder.Sales_Rep_O__c = salesrepList[0].id;
        //salesorder.Sales_Rep_O_2__c = salesrepList[1].id;
        insert salesorder;
        
        acctseederp__purchase_order__c po = new acctseederp__purchase_order__c();
        po.AcctSeedERP__Order_Date__c = date.today();
        po.AcctSeedERP__Status__c = 'Open';
        po.AcctSeedERP__Type__c = 'Drop Shipment';
        po.Stage__c = 'Production';
        po.AcctSeedERP__Purchase_Order_Format__c = abf.Id;
        po.AcctSeedERP__Ledger__c = ledger.Id;
        po.GL_Account_Variable_1__c = accVar.Id;

        po.Sales_Order__c = salesorder.id;
        po.AcctSeedERP__Vendor_Contact__c = cont.id;
        po.AcctSeedERP__Vendor__c = acct.Id;
        insert po;
        
        acctseederp__purchase_order_line__c pol = new acctseederp__purchase_order_line__c();
        pol.AcctSeedERP__Product__c = prod.id;
        pol.AcctSeedERP__Quantity__c = 4;
        pol.AcctSeedERP__Purchase_Order__c = po.id;
        pol.AcctSeedERP__Unit_Price__c = 1;
        insert pol;
        
    }
    @isTest static void MassEditLines() 
 	{
        Account acc = [select id, name from Account where name = 'myAccount' limit 1];
        
        opportunity opp = [select id, name from opportunity where name='myOpportunity' limit 1];
        
        acctseederp__sales_order__c so = [select id, name from AcctseedERP__Sales_Order__c where 
                                          AcctSeedERP__opportunity__c =:opp.id limit 1];
        
        acctseederp__purchase_order__c po = [select id,name from Acctseederp__purchase_order__c
                                            where sales_order__c =:so.id limit 1];
        
        acctseederp__purchase_order_line__c pol = [select id from acctseederp__purchase_order_line__c
                                                  where acctseederp__purchase_order__c =:po.id limit 1];
        
        list<acctseederp__purchase_order_line__c> polist = new list<acctseederp__purchase_order_line__c>{pol};
        
        product2 prod = [select id from product2 where name ='myProduct' limit 1];
        
        test.startTest();
        
        PageReference pageRef = Page.MassEditPurchaseOrderScreenPage;//Observe how we set the Page here
        Test.setCurrentPage(pageRef);
		
        ApexPages.currentPage().getParameters().put('id', po.id);

        ApexPages.StandardSetController stdset = new ApexPages.StandardSetController(polist);
        
        MassEditPurchaseOrderScreenExtension exts = new MassEditPurchaseOrderScreenExtension(stdset);
        
        ApexPages.currentPage().getParameters().put('polId', pol.id);
        
        exts.no();
        exts.UpdateLine();
        
        exts.trashIt();
        
        acctseederp__purchase_order_line__c poline = new acctseederp__purchase_order_line__c();
        
        poline.AcctSeedERP__Product__c = prod.id;
        poline.AcctSeedERP__Quantity__c = 2;
        poline.AcctSeedERP__Purchase_Order__c = po.id;
        poline.AcctSeedERP__Unit_Price__c = 1;
        
        insert poline;
        
        acctseederp__purchase_order_line__c poline2 = new acctseederp__purchase_order_line__c();
        
        poline2.AcctSeedERP__Product__c = prod.id;
        poline2.AcctSeedERP__Quantity__c = 2;
        poline2.AcctSeedERP__Purchase_Order__c = po.id;
        poline2.AcctSeedERP__Unit_Price__c = 1;
        
        insert poline2;
        
        ApexPages.currentPage().getParameters().put('polId', poline2.id);

        exts.yes(); 
        
        exts.back();
        
        exts.trashIt();

        test.stopTest();

    }
    
}
/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_AcctSeedERP_Purchase_OrderTest
{
    @IsTest
    private static void testTrigger()
    {
// accounting  variable
        list<AcctSeed__Accounting_Variable__c> avList = new list<AcctSeed__Accounting_Variable__c>();       
    	avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin China',AcctSeed__Type__c = 'GL Account Variable 1'));
        avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1'));
        insert avList;


        // create account
        list<Account> acctList = new list<Account>();  
              
        Account acct = new Account();       
        acct.Name = 'myAccount';
        acct.Type = 'Customer';
        acct.AcctSeed__Billing_Terms_Name__c = 'Example terms';
        acctList.add(acct);
        
        Account acct2 = new Account();
        acct2.Name = 'myAccount2';
        acct2.Type = 'Customer';
        acct2.billingCountry = 'Pakistan';
        acct2.billingCity = 'Rawalpindi';
        acct2.billingState = 'Punjab';
        acct2.billingPostalCode = '46000';
        acct2.billingstreet = 'Satellite Town';
        acctList.add(acct2); 

        insert acctList;


        // create contact
        Contact cont = new Contact();        
        cont.LastName = 'myLastName';
        cont.AccountId = acctList[0].Id;
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
        gl.GL_Account_Variable_1__c = avList[0].id;        
        glList.add(gl);

        // ledger creation
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = avList[0].id;
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


        // create purchase order        
        acctseederp__purchase_order__c po = new acctseederp__purchase_order__c();
        po.AcctSeedERP__Order_Date__c = date.today();
        po.AcctSeedERP__Status__c = 'Open';
        po.AcctSeedERP__Type__c = 'Drop Shipment';
        po.AcctSeedERP__Ledger__c = ledger.id;
        po.AcctSeedERP__Purchase_Order_Format__c = abfList[0].Id;
        po.GL_Account_Variable_1__c = avList[0].id;
        po.AcctSeedERP__Vendor_Contact__c = cont.id;
        po.AcctSeedERP__Vendor__c = acctList[0].id;
        //insert po;
        
        acctseederp__purchase_order__c po2 = new acctseederp__purchase_order__c();      
        po2.AcctSeedERP__Order_Date__c = date.today();
        po2.AcctSeedERP__Status__c = 'Open';
        po2.AcctSeedERP__Type__c = 'Standard';
        po2.AcctSeedERP__Ledger__c = ledger.id;
        po2.AcctSeedERP__Purchase_Order_Format__c = abfList[1].Id;
        po2.GL_Account_Variable_1__c = avList[0].id;  
        po2.AcctSeedERP__Vendor__c = acctList[0].id;    
        insert po2;
        
        test.startTest();

        APexPages.StandardController std = new ApexPages.StandardController(po);  
        AddPurchaseOrderPageExtension apop = new AddPurchaseOrderPageExtension(std);
        apop.saveOverride();

        AddPurchaseOrderPageExtension.getAccount(acctList[0].id);
        AddPurchaseOrderPageExtension.getContact(acctList[0].id);

        test.stopTest();
    }
}
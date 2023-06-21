@isTest
public class ShowBillingAgingTest{
    private static testMethod void unitTest(){
        test.startTest();
        
        Profile objProfile = [Select Id from profile where Name = 'System Administrator']; 
        String orgId = UserInfo.getOrganizationId(); 
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName = orgId + dateString + RandomId; 
        
        //Create User
        User objUser = new User(firstname = 'ABC', 
                            lastName = 'XYZ', 
                            email = uniqueName + '@test' + orgId + '.org', 
                            Username = uniqueName + '@test' + orgId + '.org', 
                            EmailEncodingKey = 'ISO-8859-1', 
                            Alias = uniqueName.substring(18, 23), 
                            TimeZoneSidKey = 'America/Los_Angeles', 
                            LocaleSidKey = 'en_US', 
                            LanguageLocaleKey = 'en_US', 
                            ProfileId = objProfile.Id
                           ); 
        
        insert objUser;
        
        //Create Sales Rep
        Sales_rep__c objSalesRep = new Sales_rep__c();
        objSalesRep.Active__c = 'Yes';
        objSalesRep.Name = 'John Doe';
        objSalesRep.User__c = objUser.id;
        insert objSalesRep;
        
        // create account
        Account objAccount = new Account();
        objAccount.Sales_Rep_O__c = objSalesRep.id;
        objAccount.Name = 'myAccount';
        objAccount.Type = 'Customer';
        objAccount.BillingStreet = 'street';
        objAccount.BillingCity = 'city';
        objAccount.BillingState = 'state';
        objAccount.BillingPostalCode = 'postalcode';
        objAccount.BillingCountry = 'country';
        insert objAccount;
        
        //Create GL Account record
        AcctSeed__GL_Account__c objGLAccount = new AcctSeed__GL_Account__c();
        objGLAccount.name = 'glaccount';
        objGLAccount.AcctSeed__Type__c = 'Expense';
        objGLAccount.AcctSeed__Sub_Type_1__c = 'Facilities';
        objGLAccount.AcctSeed__Sub_Type_2__c = 'Rent';
        objGLAccount.AcctSeed__Bank__c = true;
        insert objGLAccount;
        
        // create contact
        Contact objContact = new Contact();
        objContact.LastName = 'myLastName';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
        //Create Billing Format record
        AcctSeed__Billing_Format__c objBillingFormat = new AcctSeed__Billing_Format__c();
        objBillingFormat.Name = 'newPDF Format';
        objBillingFormat.AcctSeed__Type__c = 'Purchase Order';
        objBillingFormat.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        objBillingFormat.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        insert objBillingFormat;
        
        //Create Accouting Seed Ledger
        AcctSeed__Ledger__c objLedger = new AcctSeed__Ledger__c();
        objLedger.Name = 'myLedger';
        objLedger.AcctSeed__Type__c = 'Transactional';
        objLedger.AcctSeed__Billing_Activity_Statement_Format__c = objBillingFormat.id;
        objLedger.AcctSeed__Billing_Outstanding_Statement_Format__c = objBillingFormat.id;
        objLedger.AcctSeed__Default_Bank_Account__c = objGLAccount.id;
        objLedger.AcctSeed__Default_Billing_Format__c = objBillingFormat.id; 
        objLedger.AcctSeed__Default_Purchase_Order_Format__c = objBillingFormat.id;
        objLedger.AcctSeed__Default_Packing_Slip_Format__c = objBillingFormat.id;
        insert objLedger;
        
        // create opportunity
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'myOpportunity';
        objOpportunity.Sales_Rep_O__c = objSalesRep.id;
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.Type = 'Actual Order';
        objOpportunity.StageName = 'Closed Won';
        objOpportunity.CloseDate = system.today();
        objOpportunity.ContactPerson__c = objContact.Id;
        insert objOpportunity;
        
        // create a sales order
        /*AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c(); 
        //salesorder.name = 'testSalesOrder';
        salesorder.AcctSeedERP__Customer__c = objAccount.Id;
        salesorder.AcctSeedERP__Opportunity__c = objOpportunity.Id;
        salesorder.Contact__c = objContact.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
        salesorder.AcctSeedERP__Ledger__c = objLedger.id;
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
        insert salesorder;*/
        
        //Insert Accouting Period
        AcctSeed__Accounting_Period__c objAccoutingPeriod = new AcctSeed__Accounting_Period__c();
        objAccoutingPeriod.Name = '2019-01';
        objAccoutingPeriod.AcctSeed__Status__c = 'Open';
        objAccoutingPeriod.AcctSeed__Start_Date__c = Date.newInstance(2019, 1, 1);
        objAccoutingPeriod.AcctSeed__End_Date__c = Date.newInstance(2020, 12, 1);
        insert objAccoutingPeriod;
        
        //Create Billing Record
        AcctSeed__Billing__c objBilling = new AcctSeed__Billing__c();
        objBilling.AcctSeed__Status__c = 'Posted';
        objBilling.AcctSeed__PDF_Email_Status__c = 'Unsent';
        objBilling.AcctSeed__Billing_Format__c = objBillingFormat.id;
        objBilling.AcctSeed__Date__c = Date.Today();
        objBilling.AcctSeed__Due_Date2__c = Date.Today();
        objBilling.AcctSeed__Accounting_Period__c = objAccoutingPeriod.id;
        objBilling.AcctSeed__Opportunity__c = objOpportunity.id;
        objBilling.AcctSeed__Customer__c = objAccount.id;
        objBilling.AcctSeed__Ledger__c = objLedger.Id;
        insert objBilling;
        
        /*AcctSeed__Billing_Line__c  bline2 = new AcctSeed__Billing_Line__c();
        bline2.AcctSeed__Billing__c = objBilling.id;
        bline2.AcctSeed__Date__c = date.today();
        bline2.AcctSeed__Hours_Units__c = 1;
        //bline2.AcctSeed__Product__c = solines.AcctSeedERP__Product__c;
        //bline2.AcctSeedERP__Sales_Order_Line__c = solines.id;
        bline2.AcctSeed__Rate__c = 100;
        bline2.AcctSeed__Revenue_GL_Account__c = objGLAccount.Id;
        //bline2.Item_Description__c = solines.Item_Description__c;
        insert bline2;*/
        
        ShowBillingAging objShowBillingAging = new ShowBillingAging();
        test.stopTest();
    }
}
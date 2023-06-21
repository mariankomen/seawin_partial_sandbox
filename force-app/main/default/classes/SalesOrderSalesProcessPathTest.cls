@isTest
public class SalesOrderSalesProcessPathTest {

    static void CreateData() 
 	{

		AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c(
            Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1');
        
        insert av;
        
        // ledger creation
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = av.id;
        
        
        insert aegl;
        
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
        
        //salesorder.AcctSeedERP__Customer__c = acct.Id;
        //salesorder.AcctSeedERP__Opportunity__c = opp.Id;
        //salesorder.Contact__c = cont.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
       	salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.GL_Account_Variable_1__c = av.id;

        insert salesorder;
    }
    @isTest static void SalesOrderSalesProcessPathTest(){

        Test.setMock(HttpCalloutMock.class, new MockWebServiceCallout());
        createData();

        //Opportunity opp = [select id, recordtypeid from Opportunity where name = 'myOpportunity' limit 1];
        
        AcctSeedERP__Sales_Order__c so = [select id, recordtypeid, stage__c,
                                          AcctSeedERP__Status__c from AcctSeedERP__Sales_Order__c limit 1];
        so.AcctSeedERP__Status__c = 'Open';
        update so;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('stageNameIs', 'Received');
        
        ApexPages.StandardController std = new ApexPages.StandardController(so);
        
        SalesOrderSalesProcessPathExtension sospp = new SalesOrderSalesProcessPathExtension(std);
        
        sospp.changeStage();
        sospp.getrenderList();
        
        test.stopTest();

    }
}
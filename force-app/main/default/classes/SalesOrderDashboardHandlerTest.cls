@isTest
public with sharing class SalesOrderDashboardHandlerTest {
    
    @TestSetup
    static void makeData(){
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
        
        AcctSeed__GL_Account__c ga = new AcctSeed__GL_Account__c();
        ga.Name = 'GL Account Test';
        ga.AcctSeed__Active__c = true;
        ga.AcctSeed__Type__c = 'Revenue';
        ga.AcctSeed__Sub_Type_1__c = 'Product Revenue';
        ga.AcctSeed__Sub_Type_2__c = 'Product Family 1';
        ga.AcctSeed__Bank__c = false;
        
        insert ga;

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
        // create a sales order
        List<AcctSeedERP__Sales_Order_Line__c> solineList = new List<AcctSeedERP__Sales_Order_Line__c>();
        
        AcctSeedERP__Sales_Order_Line__c solines = new AcctSeedERP__Sales_Order_Line__c(); 
        
        solines.AcctSeedERP__Sales_Order__c = salesorder.id;
        solines.AcctSeedERP__Unit_Price__c = 1.1;
        solines.AcctSeedERP_Description__c = 'This is salesorder line item';
        solines.AcctSeedERP__Product__c = prod.id;
        solines.AcctSeedERP__Quantity_Ordered__c = 1;
        
        solineList.add(solines);
        
        AcctSeedERP__Sales_Order_Line__c solines1 = new AcctSeedERP__Sales_Order_Line__c(); 
        
        solines1.AcctSeedERP__Sales_Order__c = salesorder.id;
        solines1.AcctSeedERP__Unit_Price__c = 1.1;
        solines1.AcctSeedERP_Description__c = 'This is salesorder line item 2';
        solines1.AcctSeedERP__Product__c = prod.id;
        solines1.AcctSeedERP__Quantity_Ordered__c = 1;
        
        solineList.add(solines1);
        
        insert solineList;

    }

    @isTest
    public static void createNewRecordsTest(){
        String fields = '';
        Schema.DescribeSObjectResult r = AcctSeedERP__Sales_Order__c.sObjectType.getDescribe();

        for(String apiName : r.fields.getMap().keySet()){
            fields += apiName + ', ';
        }
        fields = fields.removeEnd(', ');

        String query = 'SELECT ' + fields + ', RecordType.Name FROM AcctSeedERP__Sales_Order__c';

        List<AcctSeedERP__Sales_Order__c> so = (List<AcctSeedERP__Sales_Order__c>)Database.query(query);
        SalesOrderDashboardHandler.createNewRecords(so);
        SalesOrderDashboardHandler.getSalesOrderDashbMap(so);
        SalesOrderDashboardHandler.getAllSalesOrderDashboardFields();
        SalesOrderDashboardHandler.updateExistingRecordsSO(so);
        SalesOrderDashboardHandler.deleteRecords(so);
    }
    
}
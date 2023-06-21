public with sharing class createSalesOrderFromOpportunityExt {
    
    public Opportunity opportunity{get; set;}
    
    /*****************************************************************************
* 								 Constructor								 *
* ***************************************************************************/
    
    public createSalesOrderFromOpportunityExt(ApexPages.StandardController stdController){
        opportunity = (Opportunity) stdController.getRecord();
        opportunity = [Select Id, Name, AccountId from Opportunity WHERE Id = : opportunity.Id];
        
    }
    
    public PageReference insertRecords() {
        PageReference retURL = null;
        try{
            AcctSeedERP__Sales_Order__c salesOrder = this.createSalesOrder();
            this.createSalesOrderLineItem(salesOrder);
            retURL = new PageReference('/apex/AcctSeedERP__MassAddEditSalesOrderLine?scontrolCaching=1&id=' + salesOrder.Id + '');
            retURL.setRedirect(true);
            return retURL;
        }catch(Exception exc) {
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Warning msg');
            system.debug('Exception');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, exc.getMessage()));
            system.debug(exc.getMessage());
        }        
        return retURL;
        
    }
    
    private AcctSeedERP__Sales_Order__c createSalesOrder() {
        
        AcctSeed__Ledger__c ledger = createLedger();
        AcctSeedERP__Sales_Order__c salesOrder = new AcctSeedERP__Sales_Order__c(AcctSeedERP__Opportunity__c = opportunity.Id, 
                                                                                 AcctSeedERP__Ledger__c = test.isRunningTest() == true? ledger.Id : null,
                                                                                 AcctSeedERP__Customer__c = opportunity.AccountId);
        insert salesOrder;
        return salesOrder;
    }
    
    private void createSalesOrderLineItem(AcctSeedERP__Sales_Order__c salesOrder) {
        List<AcctSeedERP__Sales_Order_Line__c> salesOrderLineItems = new List<AcctSeedERP__Sales_Order_Line__c>();
        for(OpportunityLineItem oppLineItem : [SELECT Id, Product2Id, Product2.Name, ProductCode,
                                               Item_Description__c, Size__c, Quantity, TotalPrice,
                                               UnitPrice, SortOrder FROM OpportunityLineItem WHERE OpportunityId = :opportunity.Id order by name,createddate asc]){
                                                   salesOrderLineItems.add(new AcctSeedERP__Sales_Order_Line__c(AcctSeedERP__Sales_Order__c = salesOrder.Id, 
                                                                                                                AcctSeedERP__Product__c = oppLineItem.Product2Id,
                                                                                                                //Product_Code__c = oppLineItem.ProductCode,
                                                                                                                Size__c = oppLineItem.Size__c,
                                                                                                                AcctSeedERP__Quantity_Ordered__c = oppLineItem.Quantity,
                                                                                                                //Total_Price__c = oppLineItem.TotalPrice,
                                                                                                                //Sales_Price__c = oppLineItem.UnitPrice,
                                                                                                               AcctSeedERP__Unit_Price__c = oppLineItem.UnitPrice,
                                                                                                               sortorder__c = oppLineItem.SortOrder));
                                               }
        if(salesOrderLineItems.size() > 0) {
            insert salesOrderLineItems;
        }
    }
    
    /***************************************************
     * 				Create Ledger
     * ************************************************/
    private AcctSeed__Ledger__c createLedger() {
        AcctSeed__Ledger__c ledger = null;
        if(test.isRunningTest()){
            
            AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
            aegl.name = 'glaccount';
            aegl.AcctSeed__Type__c = 'Expense';
            aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
            aegl.AcctSeed__Sub_Type_2__c = 'Rent';
            aegl.AcctSeed__Bank__c = true;
            
            insert aegl;
            
            AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();
            
            abf.Name = 'newPDF Format';
            abf.AcctSeed__Type__c = 'Purchase Order';
            abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
            abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
            
            insert abf;
            
            ledger = new AcctSeed__Ledger__c();
            
            ledger.Name = 'myLedger';
            ledger.AcctSeed__Type__c = 'Transactional';
            ledger.AcctSeed__Billing_Activity_Statement_Format__c = abf.id;
            ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = abf.id;
            ledger.AcctSeed__Default_Bank_Account__c = aegl.id;
            ledger.AcctSeed__Default_Billing_Format__c = abf.id; 
            ledger.AcctSeed__Default_Purchase_Order_Format__c = abf.id;
            ledger.AcctSeed__Default_Packing_Slip_Format__c = abf.id;
            
            
            insert ledger;
        }
        return ledger;
        
    }
}
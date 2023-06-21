public with sharing class SalesOrderDashboardHandler {
    
    public static final String year_month = system.today().month() + '-' + system.today().year();

    public static void createNewRecords(List<AcctSeedERP__Sales_Order__c> trigger_new){

        List<Sales_Order_Dashboard__c> so_dashboards = new List<Sales_Order_Dashboard__c>();

        for(AcctSeedERP__Sales_Order__c so: trigger_new){

            Sales_Order_Dashboard__c so_dashb = new Sales_Order_Dashboard__c();

            so_dashb.Applied_Amount__c = so.Applied_Amount__c;
            so_dashb.Inserting_Date__c = date.today();     
            so_dashb.Approval_Date__c = so.Approval_Date__c;
            so_dashb.Balance__c = so.Balance__c;
            so_dashb.Billed_Amount__c = so.Billed_Amount__c;
            so_dashb.Billing_Account__c = so.Billing_Account__c;
            so_dashb.Billing_Balances__c = so.Billing_Balances__c;
            so_dashb.Billing_City__c = so.AcctSeedERP__Billing_City__c;
            so_dashb.Billing_Country__c = so.AcctSeedERP__Billing_Country__c;
            so_dashb.Billing_Days_Due__c = so.Billing_Days_Due__c;
            so_dashb.Billing_Deposit__c = so.Billing_Deposit__c;
            so_dashb.Billing_Name__c = so.Billing_Name__c;
            so_dashb.Billing_PostalCode__c = so.AcctSeedERP__Billing_PostalCode__c;
            so_dashb.Billing_State__c = so.AcctSeedERP__Billing_State__c;
            so_dashb.Billing_Street__c = so.AcctSeedERP__Billing_Street__c;
            so_dashb.Billing_Terms_Name__c = so.Billing_Terms_Name__c;
            so_dashb.Commissions_Balance__c = so.Commissions_Balance__c;
            so_dashb.Commissions_Paid_New__c = so.Total_Commissions_Paid__c;
            so_dashb.Commissions_Total_New__c = so.Commissions_Total_Custom__c;
            so_dashb.Commissions_Unpaid_New__c = so.Total_Commissions_Unpaid__c;
            so_dashb.Contact__c = so.Contact__c;
            so_dashb.Credit_Card_Fee_Sales_Order__c = so.Sales_Order_Credit_Card_Fee__c;
            so_dashb.Customer__c = so.AcctSeedERP__Customer__c;
            so_dashb.Customer_s_ETA__c = so.Customer_s_ETA__c;
            so_dashb.Deposit__c = String.valueOf(so.Deposit__c);
            so_dashb.Estimated_Shipping_Date__c = so.Estimated_Shipping_Date__c;
            so_dashb.GL_Account_Variable_1__c = so.GL_Account_Variable_1__c;
            so_dashb.GL_Address__c = so.GL_Address__c;
            so_dashb.Import_Information__c = so.Import_Information__c;
            so_dashb.LeadSource__c = so.LeadSource__c;
            so_dashb.Ledger__c = so.AcctSeedERP__Ledger__c;
            so_dashb.Manufacturer_Rep__c = so.Manufacturer_Rep__c;
            so_dashb.Note__c = so.Notes__c;
            so_dashb.Opportunity__c = so.AcctSeedERP__Opportunity__c;
            so_dashb.OtherAmountIsGreaterThanTotal__c = so.OtherAmountIsGreaterThanTotal__c;
            so_dashb.Owner_Custom__c = so.Owner_Custom__c;
            so_dashb.Paid_Amount__c = so.Paid_Amount__c;
            so_dashb.PO_Count__c = so.PO_Count__c;
            so_dashb.PO_Date__c = so.PO_Date__c;
            so_dashb.PO_Number__c = so.PO_Number__c;
            so_dashb.Price_Level__c = so.Price_Level__c;
            so_dashb.Project__c = so.Project__c;
            so_dashb.Received_Amount__c = so.Paid_Amount_Formula__c;
            so_dashb.RecordTypeName__c = so.RecordType.Name;
            so_dashb.Referral_Sales_Rep__c = so.Referral_Sales_Rep__c;
            so_dashb.Returned_Order__c = so.Returned_Order__c;
            so_dashb.Sales_Order__c = so.Id;
            so_dashb.Name = so.Name + system.today().format();
            so_dashb.Sales_Order_Format__c = so.Sales_Order_Format__c;
            so_dashb.Sales_Rep_Team__c = so.Sales_Rep_O__c;
            so_dashb.Sales_Rep_Shadow__c = so.Sales_Rep_Shadow__c;
            so_dashb.Salesrep_Is_Owner__c = so.Salesrep_Is_Owner__c;
            so_dashb.Shipment_Count__c = so.AcctSeedERP__Shipment_Count__c;
            so_dashb.Shipping_Account__c = so.Shipping_Account__c;
            so_dashb.Shipping_City__c = so.AcctSeedERP__Shipping_City__c;
            so_dashb.Shipping_Country__c = so.AcctSeedERP__Shipping_Country__c;
            so_dashb.Shipping_Name__c = so.Shipping_Name__c;
            so_dashb.Shipping_PostalCode__c = so.AcctSeedERP__Shipping_PostalCode__c;
            so_dashb.Shipping_State__c = so.AcctSeedERP__Shipping_State__c;
            so_dashb.Shipping_Street__c = so.AcctSeedERP__Shipping_Street__c;
            so_dashb.Shipping_Term__c = so.Shipping_Term__c;
            so_dashb.Special_Instruction__c = so.Special_Instruction__c;
            so_dashb.Specified_Rep__c = so.Specified_Rep__c;
            so_dashb.Stage__c = so.Stage__c;
            so_dashb.Status__c = so.AcctSeedERP__Status__c;
            so_dashb.Sum_of_Bills__c = so.Sum_of_Bills__c;
            so_dashb.Total_Adjustment_Amount__c = so.Total_Adjustment_Amount__c;
            so_dashb.Total_Credit_Memo__c = so.Total_Credit_Memo__c;
            so_dashb.Total_Product_Received__c = so.Total_Product_Received__c;
            so_dashb.Total_Products_Quantity__c = so.Total_Products_Quantity__c;
            so_dashb.Total_Quantity_Shipped__c = so.Total_Quantity_Shipped__c;
            so_dashb.Total_Sales_Tax__c = so.Total_Sales_Tax__c;
            so_dashb.Total_With_Fee__c = so.AcctSeedERP__Total__c;
            so_dashb.Total_Without_Fee__c = so.Total_Actual__c;
            so_dashb.Visible_in_Dashboard__c = so.Visible__c;


            so_dashboards.add(so_dashb);
        }

        try{
            insert so_dashboards;
        }catch(Exception ex){
            System.debug('Error at SalesOrderDashboardHandler. Error msg: '+ex.getMessage());
        }
    }

    public static void deleteRecords(List<AcctSeedERP__Sales_Order__c> sales_orders){
        List<Sales_Order_Dashboard__c> so_d = [SELECT Id, Sales_Order__c 
                                               FROM Sales_Order_Dashboard__c 
                                               WHERE Sales_Order__c IN:sales_orders
                                               AND Month_Year__c =:year_month];
        try{
            delete so_d;
        }catch(Exception e){
            System.debug('Error during deleting: '+e.getMessage());
        }                                                                       
    }

    public static void updateExistingRecordsSO(List<AcctSeedERP__Sales_Order__c> so){
        //We run in update opportunity loop and check does iterable opportunity
        //has children OPD record in map. If it have, then update to current values from opp
        if(!Test.isRunningTest()){
            try{
                SalesOrderDashboardUpdateBatch batch = new SalesOrderDashboardUpdateBatch(so);
                Database.executeBatch(batch,1);
            }catch(Exception e){
                system.debug('Can not execute SalesOrderDashboardHandler.updateExistingRecordsSO');
            }
            
        }
        
    }

    public static String getAllSalesOrderDashboardFields(){
        String fields = '';
        Schema.DescribeSObjectResult r = Sales_Order_Dashboard__c.sObjectType.getDescribe();

        for(String apiName : r.fields.getMap().keySet()){
            fields += apiName + ', ';
        }
        fields = fields.removeEnd(', ');
        return fields;
    }

    /***********************************************************************************************************
    *   @method      : getOpportunityOPDMap
    *   @description : public method, which return map of Opportunity Id and OpportunityDashboard record
    *   @return      : Map<Id, Opportunity_Dashboard__c>
    *   @author      : Marian Lyzhychka ©Peeklogic
    ***********************************************************************************************************/
    public static Map<Id, Sales_Order_Dashboard__c> getSalesOrderDashbMap(List<AcctSeedERP__Sales_Order__c> sales_orders){
        String fields = getAllSalesOrderDashboardFields();
        String soql = 'SELECT ' + fields + ' FROM Sales_Order_Dashboard__c WHERE Sales_Order__c IN:sales_orders AND Month_Year__c =:year_month'; 
        List<Sales_Order_Dashboard__c> op_d = (List<Sales_Order_Dashboard__c>)Database.query(soql);
        Map<Id, Sales_Order_Dashboard__c> so_opd = new Map<Id, Sales_Order_Dashboard__c>();
        for(Sales_Order_Dashboard__c opd :op_d){
            so_opd.put(opd.Sales_Order__c, opd);
        }
        return so_opd;
    }
}
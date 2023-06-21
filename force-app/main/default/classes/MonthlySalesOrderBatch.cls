public with sharing class MonthlySalesOrderBatch implements Database.Batchable<sObject>{
    
    public static List<ErrorWrapper> errWrapper = new List<ErrorWrapper>();

    public Database.QueryLocator start(Database.BatchableContext bc) {

        String fieldsApiNames = getSalesOrderFields();
        
        String query = 'SELECT ' + fieldsApiNames + ' FROM AcctSeedERP__Sales_Order__c';

        return Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext bc, List<AcctSeedERP__Sales_Order__c> records){
        AcctSeedERP__Sales_Order__c so = records[0];

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

        try{
            insert so_dashb;
            System.debug('AcctSeedERP__Sales_Order__c record has been created successfully with id: '+ so_dashb.Id + ', cloned AcctSeedERP__Sales_Order__c Id: '+so.Id);
        } catch(Exception e){
            errWrapper.add(new ErrorWrapper(so.Id, e.getMessage()));

            System.debug('AcctSeedERP__Sales_Order__c record has not been created successfully. Error: ' + e.getMessage());
        }
    }


    public void finish(Database.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status,
                                 NumberOfErrors,
                                 JobItemsProcessed,
                                 TotalJobItems,
                                 CreatedBy.Email,
                                 ExtendedStatus
                         FROM AsyncApexJob
                         WHERE Id = :bc.getJobId()];

        // Check did batch finished and send email with result                
        if(a.Status == 'Completed') {
            finalBatchResult(a.Status, a.TotalJobItems);
        }
    }

     /***********************************************************************************************************
    *   @method      : getSalesOrderFields
    *   @description : public method, which return string of all Opportunity fields api names, separated by comma
    *   @return      : String
    *   @author      : Marian Lyzhychka ©Peeklogic
    ***********************************************************************************************************/

    public static String getSalesOrderFields(){
        String fields = '';
        Schema.DescribeSObjectResult r = AcctSeedERP__Sales_Order__c.sObjectType.getDescribe();

        for(String apiName : r.fields.getMap().keySet()){
            fields += apiName + ', ';
        }
        fields += ' RecordType.Name ';
        return fields;
    }


    public static void finalBatchResult(String status, Integer TotalJobItems ){
        //Generation csv file
        String header = 'Opportunity Id, Error \n';

        String finalstr = header;
        if(errWrapper.size() > 0){
            for(ErrorWrapper err: errWrapper){
                String recordString = err.oppId+','+err.errMessage +'\n';
                finalstr = finalstr +recordString;
            }
        }
        
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Blob csvBlob = Blob.valueOf(finalstr);
        String csvname= 'Monthly_SO_Batch_Errors_'+ date.today().format()+'.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);

        //Sending email
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {'testsalesforce840@gmail.com'};
        email.setSubject('MonthlySOBatch - Status: ' + status + ' - ' + date.today().format());
        email.setSenderDisplayName('SeaWin Batch Processing');
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('The batch Apex job processed ' + TotalJobItems +
                              ' batches with '+ errWrapper.size() + ' failures.');
        if(errWrapper.size() > 0){
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        }
        Messaging.SendEmailResult [] r = !Test.isRunningTest() ? Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}) : null;
    }

    public class ErrorWrapper{
        public Id oppId {get; set;}
        public String errMessage {get; set;}

        public ErrorWrapper(Id opportunityId, String errorMessage){
            oppId = opportunityId;
            errMessage = errorMessage;
        }

    }
}
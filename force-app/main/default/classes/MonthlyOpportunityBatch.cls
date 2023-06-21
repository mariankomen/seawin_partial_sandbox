/***********************************************************************************************************
*   @class       : MonthlyOpportunityBatch
*   @description : public class used to monthly creating copy of opportunity records, which will use
*                  in dashboards rendering. Records copy to: Opportunity Dashboard (Opportunity_Dashboard__c)
*   @return      : -
*   @author      : Marian Lyzhychka ©Peeklogic
***********************************************************************************************************/

public class MonthlyOpportunityBatch implements Database.Batchable<sObject>, Database.stateful{


    public static List<ErrorWrapper> errWrapper = new List<ErrorWrapper>();

    public MonthlyOpportunityBatch(){
        //errWrapper = new List<ErrorWrapper>();
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {

        String fieldsApiNames = getOpportunityFields();
        
        String query = 'SELECT ' + fieldsApiNames + ' FROM Opportunity';

        return Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext bc, List<Opportunity> records){
        //Batch class will be executed with iteration number 1, and we will destruct list to one record
        Opportunity opp = records[0];

        Opportunity_Dashboard__c opp_dashb = new Opportunity_Dashboard__c();
        
        opp_dashb.Amount__c = opp.Amount;                
        opp_dashb.Approval_Status__c = opp.Approval_Status__c;                
        opp_dashb.Approve_Date__c = opp.Approve_Date__c;                
        opp_dashb.Awarded_Owner__c = opp.Awarded_Owner__c;                
        opp_dashb.Billing_Terms_Name__c = opp.Billing_Terms_Name__c; 
        opp_dashb.Billing_Deposit__c = opp.Billing_Deposit__c;                
        opp_dashb.Braking_Ground_Date__c = opp.Braking_Ground_Date__c;                
        opp_dashb.Close_Date__c = opp.CloseDate;                
        opp_dashb.Closed_Date__c = opp.Closed_Date__c;                
        opp_dashb.HasOpenActivities__c = checkOpenActivities(opp.Id);
        opp_dashb.HasOverdueTask__c = checkOverdueTask(opp.Id);                
        opp_dashb.Inserting_Date__c = date.today();                
        opp_dashb.Invited__c = opp.Invited__c;                
        opp_dashb.IsApproved__c = opp.IsApproved__c;                
        opp_dashb.Newly_Submitted_Quote_First_Date__c = opp.Newly_Submitted_Quote_First_Date__c;                
        opp_dashb.Opportunity_Balance__c = opp.Balance__c;                
        opp_dashb.Opportunity_Bill_Paid_Amount__c = opp.Bill_Paid_Amount__c;                
        opp_dashb.Opportunity_Billed_Amount__c = opp.Billed_Amount__c;                
        opp_dashb.Opportunity_Billing_Balances__c = opp.Billing_Balances__c;                
        opp_dashb.Opportunity_Expected_Revenue__c = opp.ExpectedRevenue;
        opp_dashb.Opportunity_Forecast_Category__c = opp.ForecastCategoryName;
        opp_dashb.Opportunity_Lead_Source__c = opp.LeadSource;
        opp_dashb.Opportunity_Locked__c = opp.Locked__c;
        opp_dashb.Opportunity_Loss_Reason__c = opp.Loss_Reason__c;
        opp_dashb.Opportunity_Neglected_Days__c = checkOverdueTask(opp.Id) == true ?  checkNeglectedDays(opp.Id) : 0;
        opp_dashb.Opportunity_Price_Level__c = opp.Price_Level__c;
        opp_dashb.Opportunity_StageName__c = opp.StageName;
        opp_dashb.Opportunity_Type__c = opp.Type;
        opp_dashb.Probability__c = opp.Probability;
        opp_dashb.Sent_for_Approval__c = opp.Sent_for_Approval__c;
        opp_dashb.Special_Instruction__c = opp.Description;
        opp_dashb.Opportunity_Created_Date__c = opp.CreatedDate;
        opp_dashb.Last_Activity_Date__c = opp.LastActivityDate;
        opp_dashb.isNeglected__c = checkNeglect(opp.Id);
        opp_dashb.IsWon__c = opp.IsWon;
        opp_dashb.Last_Modified_By_Copy__c = opp.LastModifiedById;
        opp_dashb.RecordTypeName__c = opp.RecordType.Name;
        opp_dashb.Has_Activity_In_Last_Month__c = checkActivity(opp.Id);
        opp_dashb.Specified__c = opp.Specified_del__c;
        opp_dashb.Sub_Stage__c = opp.Sub_Stage__c;
        
        /* Refferences */
        opp_dashb.Opportunity__c = opp.Id;                
        opp_dashb.LastModifiedDate_Copy__c = opp.LastModifiedDate;
        opp_dashb.Referral_Sales_Rep__c = opp.Referral_Sales_Rep__c;
        opp_dashb.Sales_Rep_Team__c = opp.Sales_Rep_O__c;
        opp_dashb.Parent_Opportunity__c = opp.Parent_Opportunity__c;
        opp_dashb.Opportunity_Contract__c = opp.ContractId;                
        opp_dashb.Opportunity_ContactPerson__c = opp.ContactPerson__c;                
        opp_dashb.Contact_Owner_Developer__c = opp.Contact_Owner_Developer__c;               
        opp_dashb.Opportunity_GL_Var_1__c = opp.GL_Account_Variable_1__c;                
        opp_dashb.Manufacturer_Rep__c = opp.Manufacturer_Rep__c;                
        opp_dashb.Architect__c = opp.Architect__c;                
        opp_dashb.Account__c = opp.AccountId;
        opp_dashb.Specified_Rep__c = opp.Specified_Rep__c;

        try{
            insert opp_dashb;
            System.debug('Opportunity_Dashboard__c record has been created successfully with id: '+ opp_dashb.Id + ', cloned Opportunity Id: '+opp.Id);
        } catch(Exception e){
            errWrapper.add(new ErrorWrapper(opp.Id, e.getMessage()));

            System.debug('Opportunity_Dashboard__c record has not been created successfully. Error: ' + e.getMessage());
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
    *   @method      : getOpportunityFields
    *   @description : public method, which return string of all Opportunity fields api names, separated by comma
    *   @return      : String
    *   @author      : Marian Lyzhychka ©Peeklogic
    ***********************************************************************************************************/

    public static String getOpportunityFields(){
        String fields = '';
        Schema.DescribeSObjectResult r = Opportunity.sObjectType.getDescribe();

        for(String apiName : r.fields.getMap().keySet()){
            fields += apiName + ', ';
        }
        fields += ' RecordType.Name ';
        return fields;
    }

    /***********************************************************************************************************
    *   @method      : checkOverdueTask
    *   @description : public method, which check does opportunity has overdue task
    *   @return      : Boolean
    *   @author      : Marian Lyzhychka ©Peeklogic
    ***********************************************************************************************************/
    
    public static Boolean checkOverdueTask(Id oppId){
        List<Task> relatedTasks = [SELECT Id, 
                                          ActivityDate,
                                          Status, 
                                          WhatID 
                                    FROM Task 
                                    WHERE Status='Open' 
                                        AND ActivityDate < TODAY 
                                        AND WhatId =:oppId LIMIT 10];
        
        return relatedTasks.size() > 0 ? true : false;
    }

    /***********************************************************************************************************
    *   @method      : checkOpenActivities
    *   @description : public method, which check does opportunity has open Activities
    *   @return      : Boolean
    *   @author      : Marian Lyzhychka ©Peeklogic
    ***********************************************************************************************************/

    public static Boolean checkOpenActivities(Id oppId){
        Opportunity opportunityActivity = [SELECT (SELECT ActivityDate,
                                                          Description,
                                                          Subject
                                                   FROM OpenActivities ORDER BY ActivityDate ASC, LastModifiedDate DESC LIMIT 500 )
                                                FROM Opportunity
                                                WHERE Id=:oppId LIMIT 1];

        return !opportunityActivity.OpenActivities.isEmpty() ? true : false;
    }

    /***********************************************************************************************************
    *   @method      : checkNeglect
    *   @description : public method, which check does opportunity is Neglected
    *   @return      : Boolean
    *   @author      : Marian Lyzhychka ©Peeklogic
    ***********************************************************************************************************/

    public static Boolean checkNeglect(Id oppId){
        Opportunity opp = [SELECT Id, ForecastCategory FROM Opportunity WHERE Id=:oppId];
        Boolean hasOverdueTask = checkOverdueTask(oppId);
        Integer neglection_days = checkNeglectedDays(oppId);
        /*
            NOTE: Opportunity is Neglected if: ForecastCategory equal 'Pipeline'
                  and days from LastModifyDate till today is more than 30
                  and Opportunity dont have not overdue, open Task
        */

        return opp.ForecastCategory == 'Pipeline' && neglection_days > 30 && hasOverdueTask == true ? true : false;
    }
    /***********************************************************************************************************
    *   @method      : checkActivity
    *   @description : public method, which check does opportunity has at least one activity in last 30 days
    *   @return      : Boolean
    *   @author      : Marian Lyzhychka ©Peeklogic
    ***********************************************************************************************************/
    public static Boolean checkActivity(Id oppId){
        Opportunity opp = [SELECT Id, LastActivityDate FROM Opportunity WHERE Id=:oppId];
        Date today = date.today(); 

        return opp.LastActivityDate != null && opp.LastActivityDate.daysBetween(today) < 30 ? true : false;

    }

    /***********************************************************************************************************
    *   @method      : checkNeglectedDays
    *   @description : public method, which return count of neglection days.
    *   @return      : Integer
    *   @author      : Marian Lyzhychka ©Peeklogic
    ***********************************************************************************************************/

    public static Integer checkNeglectedDays(Id oppId){
        Opportunity opp = [SELECT Id, LastModifiedDate, LastActivityDate, ForecastCategory FROM Opportunity WHERE Id=:oppId LIMIT 100];
        Datetime DT = opp.LastModifiedDate;
        Date lastModDate = Date.NewInstance(dT.year(), dT.month(), dT.day());

        Integer days_from_last_activity = opp.LastActivityDate != null ? opp.LastActivityDate.daysBetween(date.today()) : 0;
        Integer days_from_last_modify = lastModDate.daysBetween(date.today());

        Integer neglection_days = days_from_last_activity > days_from_last_modify ? days_from_last_activity : days_from_last_modify;

        return neglection_days;
    }


    /***********************************************************************************************************
    *   @method      : finalBatchResult
    *   @description : public method, send email in final of batch with csv file of failures records
    *   @return      : void
    *   @author      : Marian Lyzhychka ©Peeklogic
    ***********************************************************************************************************/

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
        String csvname= 'Monthly_Opportunity_Batch_Errors_'+ date.today().format()+'.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);

        //Sending email
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {'testsalesforce840@gmail.com'};
        email.setSubject('MonthlyOpportunityBatch - Status: ' + status + ' - ' + date.today().format());
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
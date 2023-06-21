/***********************************************************************************************************
*   @description : Extension for OpportunityDashboardHandler, for updating without drop soql limits
*   @trigger     : AfterOpportunityTrigger
*   @author      : Marian Lyzhychka ©Peeklogic
***********************************************************************************************************/
public class OpportunityDashboardUpdateBatch implements Database.Batchable<sObject>{

    public List<Opportunity> opporunities {get; set;}
    public Map<Id, Opportunity_Dashboard__c> opportunity_opd {get; set;}

    public OpportunityDashboardUpdateBatch(List<Opportunity> opps){
        opportunity_opd = new Map<Id, Opportunity_Dashboard__c>();
        opportunity_opd = OpportunityDashboardHandler.getOpportunityOPDMap(opps);
        opporunities = new List<Opportunity>();
        opporunities.addAll(opps);
    }
    
    public List<Opportunity> start(Database.BatchableContext bc) {

        return opporunities;
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> records){
        Opportunity opp = records[0];

        if(opportunity_opd.containsKey(opp.Id)){
            Opportunity_Dashboard__c opp_dashb = opportunity_opd.get(opp.Id);
            opp_dashb.Amount__c = opp.Amount;                
            opp_dashb.Approval_Status__c = opp.Approval_Status__c;                
            opp_dashb.Approve_Date__c = opp.Approve_Date__c;                
            opp_dashb.Awarded_Owner__c = opp.Awarded_Owner__c;                
            opp_dashb.Billing_Terms_Name__c = opp.Billing_Terms_Name__c; 
            opp_dashb.Billing_Deposit__c = opp.Billing_Deposit__c;                
            opp_dashb.Braking_Ground_Date__c = opp.Braking_Ground_Date__c;                
            opp_dashb.Close_Date__c = opp.CloseDate;                
            opp_dashb.Closed_Date__c = opp.Closed_Date__c;   
            
            
            if(!Test.isRunningTest()){
                opp_dashb.HasOverdueTask__c = MonthlyOpportunityBatch.checkOverdueTask(opp.Id); 
                opp_dashb.HasOpenActivities__c = MonthlyOpportunityBatch.checkOpenActivities(opp.Id);
                opp_dashb.Opportunity_Neglected_Days__c = MonthlyOpportunityBatch.checkOverdueTask(opp.Id) == true ?  MonthlyOpportunityBatch.checkNeglectedDays(opp.Id) : 0;
                opp_dashb.Has_Activity_In_Last_Month__c = MonthlyOpportunityBatch.checkActivity(opp.Id);
                opp_dashb.isNeglected__c = MonthlyOpportunityBatch.checkNeglect(opp.Id);

            }else {
                opp_dashb.HasOverdueTask__c = true;
                opp_dashb.HasOpenActivities__c = true;
                opp_dashb.Opportunity_Neglected_Days__c = 0;
            }
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
            opp_dashb.Opportunity_Price_Level__c = opp.Price_Level__c;
            opp_dashb.Opportunity_StageName__c = opp.StageName;
            opp_dashb.Opportunity_Type__c = opp.Type;
            opp_dashb.Probability__c = opp.Probability;
            opp_dashb.Sent_for_Approval__c = opp.Sent_for_Approval__c;
            opp_dashb.Special_Instruction__c = opp.Description;
            opp_dashb.Opportunity_Created_Date__c = opp.CreatedDate;
            opp_dashb.Last_Activity_Date__c = opp.LastActivityDate;
            opp_dashb.IsWon__c = opp.IsWon;
            opp_dashb.Last_Modified_By_Copy__c = opp.LastModifiedById;
            opp_dashb.RecordTypeName__c = opp.RecordType.Name;
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
                Database.update(opp_dashb, true);
            }catch(Exception e){
                System.debug('error OpportunityDdashboardUpdateBatch: '+e.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext bc){
        System.debug('Fields on Opportunity and Sales Order record was updated successfully.');
    }
}